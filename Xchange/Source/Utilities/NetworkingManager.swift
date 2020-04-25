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

///--------------------------------
/// - TODO:
///
///
///
///--------------------------------


final class NetworkingManager: NSObject, NetworkManaging {
    
    static var shared: NetworkingManager = NetworkingManager()
    
    
    // MARK: - Properties
    
    weak var delegate: NetworkingManagerDelegate?

    var monitorQueue = DispatchQueue(label: "com.xchange.NetworkingManager.networkMonitorQueue", qos: .utility)
    var notifyQueue = DispatchQueue.main
    
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
    
    private func parse(text: String) -> Void {
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
}


// MARK: - CaptureVideoDataOutputSampleBufferDelegate

extension NetworkingManager {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        if let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
            CVPixelBufferLockBaseAddress(imageBuffer, CVPixelBufferLockFlags(rawValue: 0))
            
            let bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer)
            let height = CVPixelBufferGetHeight(imageBuffer)
            let src_buff = CVPixelBufferGetBaseAddress(imageBuffer)
            
            let data = NSData(bytes: src_buff, length: bytesPerRow * height) as Data
            CVPixelBufferUnlockBaseAddress(imageBuffer, CVPixelBufferLockFlags(rawValue: 0))
            
            socket?.write(data: data)
        }
        
    }
}


// MARK: - WebSocket Delegate

extension NetworkingManager: WebSocketDelegate {

    func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
            
        case let .connected(headers):
            let json: [String: Any] = [
                "command": [
                    "name": "connect_request"
                ],
                "client_info": [
                    "type": "ios"
                ],
                "identifier": UIDevice.current.identifierForVendor!.uuidString
            ]
            if let data = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) {
                client.write(data: data)
                delegate?.networkManager(self, didConnectTo: client, with: headers)
            }
            
        case .disconnected(_ , _):
            print("Disconected.")
            delegate?.networkManager(self, didDisconnectFrom: client)
            
        case let .text(string):
            //parse(text: string)
            print(string)
            
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
