//
//  Networking.swift
//  Xchange
//
//  Created by Yehor Sorokin on 19.02.2020.
//  Copyright © 2020 Yehor Sorokin. All rights reserved.
//

import Foundation
import AVFoundation
import Network
import Starscream
import MapKit

///--------------------------------
/// - TODO:
///
///
///
///--------------------------------

final class NetworkingManager: NSObject, NetworkManaging {
    
    static var shared: NetworkingManager = NetworkingManager()
    
    let locationManager = CLLocationManager()
    
    // MARK: - Properties
    
    weak var delegate: NetworkingManagerDelegate?

    var monitorQueue = DispatchQueue(label: "com.xchange.NetworkingManager.networkMonitorQueue", qos: .utility)
    var notifyQueue = DispatchQueue.main
    
    var buffer: Data?
    var location: CLLocationCoordinate2D?
    
    internal var serverURL: URL?
    internal var socket: WebSocket?
    internal var monitor: NWPathMonitor = NWPathMonitor()
    
    // MARK: - Initialization
    
    override init() {
        super.init()
        
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }
            switch path.status {
            case .satisfied:
                self.notifyQueue.async {
                    self.setupConnection()
                    self.delegate?.networkManager(self, didChangeNetworkState: .connected)
                }
            default:
                self.notifyQueue.async {
                    self.terminateConnection()
                    self.delegate?.networkManager(self, didChangeNetworkState: .disconnected)
                }
            }
        }
        monitor.start(queue: monitorQueue)
    }
    
    func setupLocationManager() {
        locationManager.requestAlwaysAuthorization()
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLHeadingFilterNone
        
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
    }
    
    private func processMessage(_ message: [String: Any], _ client: WebSocket) -> Void {
        if let command = message["command"] as? [String: String], let name = command["name"] {
            if name.contains("record_video_request") {
                let json: [String: Any] = [
                    "command": [
                        "name": "record_video_response"
                    ],
                    "client_info": [
                        "type": "ios"
                    ],
                    "command_parameters" : [
                        "base64_string_video" : buffer?.base64EncodedString() as Any,
                        "request_user_id" : "1234567"
                    ],
                    //"identifier": UIDevice.current.identifierForVendor!.uuidString
                    "identifier" : "7654321"
                ]
                if let data = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) {
                    client.write(data: data)
                }
            } else if name.contains("get_location_request") {
                let json: [String: Any] = [
                    "command": [
                        "name": "get_location_response"
                    ],
                    "client_info": [
                        "type": "ios"
                    ],
                    "command_parameters" : [
                        "location_latitude" : location?.latitude.description,
                        "location_longitude" : location?.longitude.description,
                        "request_user_id" : "1234567"
                    ],
                    //"identifier": UIDevice.current.identifierForVendor!.uuidString
                    "identifier" : "7654321"
                ]
                if let data = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) {
                    client.write(data: data)
                }
            }
        }
    }
    
    public func setupConnection() -> Void {
        if let url = URL(string: Config.serverURLString) {
            let request = URLRequest(url: url)
            let pinner = FoundationSecurity(allowSelfSigned: true)
            
            socket = WebSocket(request: request, certPinner: pinner)
            socket?.delegate = self
            socket?.connect()
        }
    }
    
    public func terminateConnection() -> Void {
        socket?.disconnect(closeCode: CloseCode.normal.rawValue)
    }
    
    public func connectToServer(_ client: WebSocket, _ headers: [String: String]? = nil) {
        let json: [String: Any] = [
            "command": [
                "name": "connect_request"
            ],
            "client_info": [
                "type": "ios"
            ],
            //"identifier": UIDevice.current.identifierForVendor!.uuidString
            "identifier" : "7654321"
        ]
        if let data = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) {
            client.write(data: data)
            delegate?.networkManager(self, didConnectTo: client, with: headers)
        }
    }
}


// MARK: - CaptureVideoDataOutputSampleBufferDelegate

extension NetworkingManager {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) -> Data? {
        
        if let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
            CVPixelBufferLockBaseAddress(imageBuffer, CVPixelBufferLockFlags(rawValue: 0))
            
            let bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer)
            let height = CVPixelBufferGetHeight(imageBuffer)
            let src_buff = CVPixelBufferGetBaseAddress(imageBuffer)
            
            let data = NSData(bytes: src_buff, length: bytesPerRow * height) as Data
            CVPixelBufferUnlockBaseAddress(imageBuffer, CVPixelBufferLockFlags(rawValue: 0))
            
            buffer = data
        }
        return nil
    }
}


// MARK: - WebSocket Delegate

extension NetworkingManager: WebSocketDelegate {

    func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
            
        case let .connected(headers):
            connectToServer(client, headers)
            
        case .disconnected(_ , _):
            print("Disconected.")
            delegate?.networkManager(self, didDisconnectFrom: client)
            
        case let .text(string):
            print(string)
            if let data = string.data(using: .utf8) {
                if let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] {
                    processMessage(json, client)
                }
            }
            
        case .cancelled:
            print("Connection terminated.")
            delegate?.networkManager(self, didDisconnectFrom: client)
            
        case .binary(_):
            print("Binary")
            
        case .pong(_):
            print("Pong")
            
        case .ping(_):
            print("Ping")
            
        case let .error(error):
            print("\n\nError: \(error.debugDescription)\n\n")
            
        case let .viablityChanged(msg):
            print("\(msg) 1")
            
        case let .reconnectSuggested(msg):
            print("\(msg) 2")
        }
    }
    
}

extension NetworkingManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let lastLocation = locations.first {
            location = lastLocation.coordinate
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                if CLLocationManager.isRangingAvailable() {
                    locationManager.requestLocation()
                }
            }
        }
    }
}
