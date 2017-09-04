//
//  ViewController.swift
//  Camera
//
//  Created by Joshua Choi on 9/1/17.
//  Copyright © 2017 Joshua Choi. All rights reserved.
//

import UIKit
import AVFoundation

import GPUImage

/*
 • Capture photo [X]
 • Record video []
 • Flash for front camera []
 • Flash for back camera []
 
 • Zoom for front camera []
 • Zoom for back camera []
 
 https://github.com/BradLarson/GPUImage/issues/2119
 
 */

class ViewController: UIViewController {

    // MARK: - GPUImage
    /// Initialized GPUImageVideoCamera. Used to capture photos and record videos.
    var videoCamera: GPUImageVideoCamera!
    /// Initialized GPUImageMovie object to filter movies.
    var movieFile: GPUImageMovie!
    /// Initialized GPUImageMovieWriter to store the new processed video recording to a temporary directory.
    var movieWriter: GPUImageMovieWriter!
    
    
    var movieURL: URL?
    var pathToMovie: String?
    
    /// Declared GPUImageView to manage the preview of the GPUImageVideoCamera.
    let gpuImageView = GPUImageView(frame: UIScreen.main.bounds)
    /// Declared default GPUImageFilter (no filter) for the preview of the GPUImageVideoCamera. This must be attached to the videoCamera or the preview will not show.
    let defaultFilter = GPUImageFilter()
    
    
    /// Declared UIPinchGestureRecognizer.
    let pinchGesture = UIPinchGestureRecognizer()
    
    @IBOutlet weak var captureButton: UIButton!
    
    
    /// Function: Record video
    func recordVideo(sender: UILongPressGestureRecognizer) {

        
        switch sender.state {
        case .began:
            print("Began...")
            
            
        case .ended:
            print("Ended...")
            
//            let capturedVC = self.storyboard?.instantiateViewController(withIdentifier: "capturedVC") as! Captured
//            capturedVC.capturedURL = movieURL!
//            self.navigationController?.pushViewController(capturedVC, animated: false)
        default:
            break;
        }
    }
    
    /// Function: Take the photo.
    func takePhoto() {
        // Play system camera shutter sound.
        AudioServicesPlaySystemSoundWithCompletion(SystemSoundID(1108), nil)
        // Capture the next frame of the current GPUImageVideoCamera.
        defaultFilter.useNextFrameForImageCapture()
        // Pass the captured image to the next UIViewController.
        let capturedVC = self.storyboard?.instantiateViewController(withIdentifier: "capturedVC") as! Captured
        capturedVC.capturedImage = defaultFilter.imageFromCurrentFramebuffer()
        self.navigationController?.pushViewController(capturedVC, animated: false)
    }
    
    /// Function: Switch the GPUImageVideoCamera's device camera.
    func switchCamera() {
        videoCamera?.rotateCamera()
    }
    
    /// Function: Zoom in on the frame.
    func zoom(sender: UIPinchGestureRecognizer) {
        // TODO:
//        let zoomScale = min(maxZoomScale, max(1.0, min(beginZoomScale * pinch.scale,  captureDevice!.activeFormat.videoMaxZoomFactor)))
    }
    
    // MARK: - UIView Life Cycle
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Hide UINavigationBar
        navigationController?.setNavigationBarHidden(true, animated: false)
        // Hide UIStatusBar
        UIApplication.shared.isStatusBarHidden = true
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        // MARK: - GPUImage; GPUImageVideoCamera
        videoCamera = GPUImageVideoCamera(sessionPreset: AVCaptureSessionPresetHigh, cameraPosition: .front)
        videoCamera!.horizontallyMirrorRearFacingCamera = false
        videoCamera!.horizontallyMirrorFrontFacingCamera = true
        videoCamera!.outputImageOrientation = .portrait
        
        
        
        
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let pathToMovie = documentsPath + "/movie.mov"
        print("pathToMovie \(pathToMovie)")
        unlink((pathToMovie as NSString).utf8String)
        let movieURL = NSURL.fileURL(withPath: pathToMovie)
        movieWriter = GPUImageMovieWriter(movieURL: movieURL, size: self.view.bounds.size)
        movieWriter!.encodingLiveVideo = true

        
        
        // Add targets
        videoCamera!.addTarget(defaultFilter)
        defaultFilter.addTarget(movieWriter)
        defaultFilter.addTarget(gpuImageView)

        // Start GPUImageVideoCamera capture
        videoCamera!.startCapture()
        

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
            print("RECORDING!!!")
            self.videoCamera!.audioEncodingTarget = self.movieWriter
            self.movieWriter!.startRecording()
//            self.movieFile!.startProcessing()
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 10.00, execute: {
                print("ENDING RECORDING!!!")
                self.defaultFilter.removeTarget(self.movieWriter)
                self.videoCamera!.audioEncodingTarget = nil
                self.movieWriter!.finishRecording()
                
                print(pathToMovie)
                let videoURL = URL(fileURLWithPath: pathToMovie)
              
                let capturedVC = self.storyboard?.instantiateViewController(withIdentifier: "capturedVC") as! Captured
                capturedVC.capturedURL = videoURL
                self.navigationController?.pushViewController(capturedVC, animated: false)

            })
        }
        
        // Insert the GPUImageView to the view.
        view.insertSubview(gpuImageView, at: 0)
        view.isUserInteractionEnabled = true
        
        // Long tap to record video
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(recordVideo))
        longPress.minimumPressDuration = 0.30
        captureButton.addGestureRecognizer(longPress)
        
        // Tap to capture image
        let captureTap = UITapGestureRecognizer(target: self, action: #selector(takePhoto))
        captureTap.numberOfTapsRequired = 1
        captureButton.isUserInteractionEnabled = true
        captureButton.addGestureRecognizer(captureTap)
        
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
        
    }

    
    /// Function: Focus on the camera's view.
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

}

