//
//  ViewController.swift
//  Camera
//
//  Created by Joshua Choi on 9/1/17.
//  Copyright © 2017 Joshua Choi. All rights reserved.
//

import UIKit
import GPUImage

/*
 • Capture photo [X]
 • Record video []
 • Flash for front camera []
 • Flash for back camera []
 
 • Zoom for front camera []
 • Zoom for back camera []
 
 
 
 */

class ViewController: UIViewController {

    var videoCamera: GPUImageVideoCamera!
    let filteredVideoView = GPUImageView(frame: UIScreen.main.bounds)
    let defaultFilter = GPUImageFilter()
    
    let pinchGesture = UIPinchGestureRecognizer()
    
    @IBAction func capture(_ sender: Any) {
        defaultFilter.useNextFrameForImageCapture()
        
        let capturedVC = self.storyboard?.instantiateViewController(withIdentifier: "capturedVC") as! Captured
        capturedVC.capturedImage = defaultFilter.imageFromCurrentFramebuffer()
        self.navigationController?.pushViewController(capturedVC, animated: true)
        
        
    }
    
    func switchCamera() {
        videoCamera?.rotateCamera()
    }
    
    /// ZOOM ON THE CAMERA.
    func zoom(sender: UIPinchGestureRecognizer) {
//        let zoomScale = min(maxZoomScale, max(1.0, min(beginZoomScale * pinch.scale,  captureDevice!.activeFormat.videoMaxZoomFactor)))
        
        

    }

    /// FOCUS ON THE CAMERA.
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
        
        // Pinch to zoom
        pinchGesture.addTarget(self, action: #selector(zoom))
        view.addGestureRecognizer(pinchGesture)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

