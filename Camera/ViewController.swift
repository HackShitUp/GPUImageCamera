//
//  ViewController.swift
//  Camera
//
//  Created by Joshua Choi on 9/1/17.
//  Copyright © 2017 Joshua Choi. All rights reserved.
//

import UIKit
import GPUImage

class ViewController: UIViewController {
    /*
     // FOCUS
     https://www.google.com/search?q=gpuimage+camera+focus+ios&oq=gpuimage+camera+focus+ios&aqs=chrome..69i57.4925j0j7&sourceid=chrome&ie=UTF-8
     https://stackoverflow.com/questions/33109501/gpuimage-focusing-and-exposure-on-tap-does-not-work-properly-missing-somethi
     https://github.com/BradLarson/GPUImage/issues/254
     
     // Open source apps
     https://medium.mybridge.co/21-amazing-open-source-ios-apps-written-in-swift-5e835afee98e
     
     
     
     */

    var videoCamera: GPUImageVideoCamera!
    let filteredVideoView = GPUImageView(frame: UIScreen.main.bounds)
    let defaultFilter = GPUImageFilter()
    
    @IBAction func capture(_ sender: Any) {
        defaultFilter.useNextFrameForImageCapture()
        
        let capturedVC = self.storyboard?.instantiateViewController(withIdentifier: "capturedVC") as! Captured
        capturedVC.capturedImage = defaultFilter.imageFromCurrentFramebuffer()
        self.navigationController?.pushViewController(capturedVC, animated: true)
        
        
    }

//    if (tgr.state == UIGestureRecognizerStateRecognized) {
//    CGPoint location = [tgr locationInView:self.photoView];
//    
//    AVCaptureDevice *device = videoCamera.inputCamera;
//    CGPoint pointOfInterest = CGPointMake(.5f, .5f);
//    NSLog(@"taplocation x = %f y = %f", location.x, location.y);
//    CGSize frameSize = [[self photoView] frame].size;
//    
//    if ([videoCamera cameraPosition] == AVCaptureDevicePositionFront) {
//    location.x = frameSize.width - location.x;
//    }
//    
//    pointOfInterest = CGPointMake(location.y / frameSize.height, 1.f - (location.x / frameSize.width));
//    
//    
//    if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
//    NSError *error;
//    if ([device lockForConfiguration:&error]) {
//    [device setFocusPointOfInterest:pointOfInterest];
//    
//    [device setFocusMode:AVCaptureFocusModeAutoFocus];
//    
//    if([device isExposurePointOfInterestSupported] && [device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure])
//    {
//    
//    
//    [device setExposurePointOfInterest:pointOfInterest];
//    [device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
//    }
//    
//    [device unlockForConfiguration];
//    
//    NSLog(@"FOCUS OK");
//    } else {
//    NSLog(@"ERROR = %a", error);
//    }  
//    }
//    }
//    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touchPoint = touches.first! as UITouch
        let screenSize = view.bounds.size
        let focusPoint = CGPoint(x: touchPoint.location(in: view).y / screenSize.height, y: 1.0 - touchPoint.location(in: view).x / screenSize.width)
        
        let focusView = UIImageView(frame: CGRect(x: 0.0, y: 0.0, width: 30.0, height: 30.0))
        focusView.image = UIImage(named: "Camera")
        focusView.center.x = touchPoint.location(in: view).x
        focusView.center.y = touchPoint.location(in: view).y
        view.addSubview(focusView)
        // Animate focusView
        UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseInOut, animations: {
            focusView.alpha = 1.0
            focusView.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
        }, completion: { (success) in
            UIView.animate(withDuration: 0.15, delay: 0.5, options: .curveEaseInOut, animations: {
                focusView.alpha = 0.0
                focusView.transform = CGAffineTransform(translationX: 0.6, y: 0.6)
            }, completion: { (success) in
                focusView.removeFromSuperview()
            })
        })
        
        if let device = videoCamera?.inputCamera {
            do {
                try device.lockForConfiguration()
                if device.isFocusPointOfInterestSupported {
                    device.focusPointOfInterest = focusPoint
                    device.focusMode = AVCaptureFocusMode.autoFocus
                }
                if device.isExposurePointOfInterestSupported {
                    device.exposurePointOfInterest = focusPoint
                    device.exposureMode = AVCaptureExposureMode.autoExpose
                }
                device.unlockForConfiguration()
                
            } catch {
                // Handle errors here
            }
        }
    }
    
    func switchCamera() {
        videoCamera?.rotateCamera()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        UIApplication.shared.isStatusBarHidden = false
        UIApplication.shared.statusBarStyle = .lightContent
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        videoCamera = GPUImageVideoCamera(sessionPreset: AVCaptureSessionPresetHigh, cameraPosition: .front)
        videoCamera?.horizontallyMirrorRearFacingCamera = false
        videoCamera?.horizontallyMirrorFrontFacingCamera = true
        videoCamera?.outputImageOrientation = .portrait
        

        videoCamera?.addTarget(defaultFilter)
        defaultFilter.addTarget(filteredVideoView)
        videoCamera?.startCapture()
        
        
        view.insertSubview(filteredVideoView, at: 0)
        
        view.isUserInteractionEnabled = true
        
        // Double tap to switch.
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(switchCamera))
        doubleTap.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleTap)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

