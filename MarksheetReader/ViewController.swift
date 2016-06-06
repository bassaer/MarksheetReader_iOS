//
//  ViewController.swift
//  MarksheetReader
//
//  Created by Nakayama on 2016/05/26.
//  Copyright © 2016年 Nakayama. All rights reserved.
//

import UIKit
import AVFoundation
import MRProgress

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var shutterButton: UIButton!
    @IBOutlet weak var settingButton: UIButton!
    
    var mySession : AVCaptureSession!
    var myDevice : AVCaptureDevice!
    var myOutput : AVCaptureVideoDataOutput!
    
    let detector = Detector()
    let patternImage = UIImage(named: "pattern")
    let patternImage2 = UIImage(named: "pattern_part1_2")
    let marksheetImage = UIImage(named: "mark_sheet")
    let patternImageA = UIImage(named: "pattern_a")
    let patternImageB = UIImage(named: "pattern_b")
    let patternImage42 = UIImage(named: "pattern_42")
    let patternImagePart1 = UIImage(named: "pattern_part1")
    let patternImageBrank = UIImage(named: "brank")
    
    var launchScreenLabel: UILabel!
    
    var mrprogress: MRProgressOverlayView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setLaunchScreen()
        
        if initCamera() {
            mySession.startRunning()
        }
    }
    
    
    func setLaunchScreen(){
        let screenWidth = UIScreen.mainScreen().nativeBounds.width
        let screenHeight = UIScreen.mainScreen().nativeBounds.height
        
        self.launchScreenLabel = UILabel(frame: CGRectMake(0,0,screenWidth,screenHeight))
        self.launchScreenLabel.backgroundColor = UIColor(red: 0, green: CGFloat(80)/255.0, blue: CGFloat(127)/255.0, alpha: 1.0)
        self.launchScreenLabel.text = "R"
        self.launchScreenLabel.textColor = UIColor.whiteColor()
        self.launchScreenLabel.font = UIFont(name: "Avenir-Black",size: 200)
        self.launchScreenLabel.center = self.view.center
        self.launchScreenLabel.textAlignment = NSTextAlignment.Center
        self.view.addSubview(self.launchScreenLabel)
        
    }
    
    @IBAction func pushedShutterButton(sender: UIButton) {
        mrprogress = MRProgressOverlayView()
        
    }
    override func viewDidAppear(animated: Bool) {
        UIView.animateWithDuration(
            0.3,
            delay: 1.0,
            options: UIViewAnimationOptions.CurveEaseOut,
            animations: { () in
                self.launchScreenLabel.transform = CGAffineTransformMakeScale(0.9, 0.9)
            },
            completion: { (Bool) in }
        )
        
        UIView.animateWithDuration(
            0.8,
            delay: 1.3,
            options: UIViewAnimationOptions.CurveEaseInOut,
            animations: { () in
                self.launchScreenLabel.transform = CGAffineTransformMakeScale(1.2, 1.2)
                self.launchScreenLabel.alpha = 0
            },
            completion: { (Bool) in }
        )
        
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
            var image = CameraUtil.imageFromSampleBuffer(sampleBuffer)
            //var image = self.marksheetImage
            if self.settingButton.highlighted {
                //image = self.detector.recognizeFace(image)
                //image = self.detector.matchImage(image, templateImage: self.patternImageA)
                image = self.detector.doMachingShape(image, templateImage: self.patternImageBrank)
                //image = UIImage(CGImage: image.CGImage!, scale: 1.0, orientation: UIImageOrientation.Right)
            }
            self.imageView.image = image
        })
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
 

}

