//
//  ViewController.swift
//  MarksheetReader
//
//  Created by Nakayama on 2016/05/26.
//  Copyright © 2016年 Nakayama. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var shutterButton: UIButton!
    
    var mySession : AVCaptureSession!
    var myDevice : AVCaptureDevice!
    var myOutput : AVCaptureVideoDataOutput!
    
    let detector = Detector()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if initCamera() {
            mySession.startRunning()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initCamera() -> Bool {
        mySession = AVCaptureSession()
        mySession.sessionPreset = AVCaptureSessionPresetHigh
        
        let devices = AVCaptureDevice.devices()
        for device in devices {
            if (device.position == AVCaptureDevicePosition.Back) {
                myDevice = device as! AVCaptureDevice
            }
        }
        if myDevice == nil {
            return false
        }
        
        do {
            let myInput = try AVCaptureDeviceInput(device: myDevice)
            if mySession.canAddInput(myInput) {
                mySession.addInput(myInput)
            } else {
                return false
            }
            
            myOutput = AVCaptureVideoDataOutput()
            myOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey: Int(kCVPixelFormatType_32BGRA)]
            
            try myDevice.lockForConfiguration()
            
            myDevice.activeVideoMinFrameDuration = CMTimeMake(1, 15)
            myDevice.unlockForConfiguration()
            
        } catch let error as NSError {
            print("Error:\(error)")
            return false
        }
        
        let queue: dispatch_queue_t = dispatch_queue_create("myqueue", nil)
        myOutput.setSampleBufferDelegate(self, queue: queue)
        
        myOutput.alwaysDiscardsLateVideoFrames = true
        
        if mySession.canAddOutput(myOutput) {
            mySession.addOutput(myOutput)
        } else {
            return false
        }
        
        for connection in myOutput.connections {
            if let myAVConnection = connection as? AVCaptureConnection {
                if myAVConnection.supportsVideoOrientation {
                    myAVConnection.videoOrientation = AVCaptureVideoOrientation.Portrait
                }
            }
        }
        
        return true
    }
    
    func captureOutput(caputreOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!){
        dispatch_sync(dispatch_get_main_queue(), {
            let image = CameraUtil.imageFromSampleBuffer(sampleBuffer)
            let faceImage = self.detector.recognizeFace(image)
            self.imageView.image = faceImage
        })
    }
 

}

