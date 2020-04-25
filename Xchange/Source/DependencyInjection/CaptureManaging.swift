//
//  CaptureManager.swift
//  Xchange
//
//  Created by Yehor Sorokin on 2/26/20.
//  Copyright © 2020 Yehor Sorokin. All rights reserved.
//

import Foundation
import AVFoundation


public protocol CaptureManaging: class {
    
    var device: AVCaptureDevice! { get }
    var input: AVCaptureDeviceInput! { get }
    var session: AVCaptureSession! { get }
    var output: AVCaptureVideoDataOutput! { get }
    var videoConnection: AVCaptureConnection! { get }
    var captureQueue: DispatchQueue { get }
    
    func requestAuthorization() -> Void
    func setupCaptureSession() -> Bool
    func startCapture() -> Void
    func stopCapture() -> Void
    
}
