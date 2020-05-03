//
//  NetworkManaging.swift
//  Xchange
//
//  Created by Yehor Sorokin on 2/26/20.
//  Copyright © 2020 Yehor Sorokin. All rights reserved.
//

import Foundation
import AVFoundation
import Network
import Starscream
import MapKit


protocol NetworkManaging: AVCaptureVideoDataOutputSampleBufferDelegate {
    var locationManager: CLLocationManager { get }
    
    var monitorQueue: DispatchQueue { get }
    var notifyQueue: DispatchQueue { get }
    
    var monitor: NWPathMonitor { get }
    var serverURL: URL? { get set }
    var socket: WebSocket? { get }
    var delegate: NetworkingManagerDelegate? { get set }
    
    func setupConnection() -> Void
    func terminateConnection() -> Void
    func setupLocationManager() -> Void
    
}


protocol NetworkingManagerDelegate: class {
    
    var wasDisconnected: Bool { get set }
    func networkManager(_ manager: NetworkingManager, didChangeNetworkState state: NetworkState)
    func networkManager(_ manager: NetworkingManager, didConnectTo client: WebSocket, with headers: [String : String]?)
    func networkManager(_ manager: NetworkingManager, didDisconnectFrom client: WebSocket)
    
}


enum NetworkState {
    case connected
    case disconnected
}
