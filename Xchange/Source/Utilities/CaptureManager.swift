//
//  CameraViewController.swift
//  Xchange
//
//  Created by Yehor Sorokin on 19.02.2020.
//  Copyright © 2020 Yehor Sorokin. All rights reserved.
//

import UIKit
import AVFoundation


///--------------------------------
/// - TODO:
///
///   - Test on real device
///   - Trigger start capture
///
///
///--------------------------------

final class CaptureManager: CaptureManaging {
    
    static var shared: CaptureManager = CaptureManager()
    
    
    // MARK: - Properties
    
    internal var device: AVCaptureDevice!
    internal var input: AVCaptureDeviceInput!
    internal var session: AVCaptureSession!
    internal var output: AVCaptureVideoDataOutput!
    internal var videoConnection: AVCaptureConnection!
    
    internal var captureQueue = DispatchQueue(label: "com.xchange.CaptureManager.captureQueue", qos: .background)
    
    
    // MARK: - Auxilaries
    
    func requestAuthorization() -> Void {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupCaptureSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted {
                    self?.setupCaptureSession()
                }
            }
        default:
            return
        }
        
    }
    
    func startCapture() -> Void {
        captureQueue.async { [weak self] in
            self?.session.startRunning()
        }
    }
    
    func stopCapture() -> Void {
        captureQueue.async { [weak self] in
            self?.session.stopRunning()
        }
    }
    
    
    // MARK: - Capture session setup
    
    @discardableResult
    func setupCaptureSession() -> Bool {
        session = AVCaptureSession()
        session.beginConfiguration()
        do {
            if let device = AVCaptureDevice.default(for: .video) {
                input = try AVCaptureDeviceInput(device: device)
                output = AVCaptureVideoDataOutput()
                
                if session.canAddInput(input) && session.canAddOutput(output) {
                    session.addInput(input)
                    session.addOutput(output)
                    
                    videoConnection = output.connection(with: .video)
                    session.commitConfiguration()
                    
                    return true
                }
            }
            return false
        } catch let error {
            print(error.localizedDescription)
            return false
        }
    }
    
    deinit {
        stopCapture()
    }

}
