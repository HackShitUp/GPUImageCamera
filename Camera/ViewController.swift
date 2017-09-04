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
    var movieWriter: GPUImageMovieWriter!
    var movieFile: GPUImageMovie!
    
    let filteredVideoView = GPUImageView(frame: UIScreen.main.bounds)
    let defaultFilter = GPUImageFilter()
    
    
    let pinchGesture = UIPinchGestureRecognizer()
    
    @IBOutlet weak var captureButton: UIButton!
    
    
    /// Function: Record video
    func recordVideo(sender: UILongPressGestureRecognizer) {
        
        
//        let outputFileName = UUID().uuidString
//        let outputFilePath = (NSTemporaryDirectory() as NSString).appendingPathComponent((outputFileName as NSString).appendingPathExtension("mov")!)
        
//        let moviePath = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathExtension("mov")
//        unlink((moviePath as NSString).utf8String)
        
//        // Create movieWriter
//        movieWriter = GPUImageMovieWriter(movieURL: moviePath, size: UIScreen.main.bounds.size)
//        movieWriter?.encodingLiveVideo = true
//        movieWriter?.shouldPassthroughAudio = true
//        // Create movieFiler
//        movieFile = GPUImageMovie.init(url: moviePath)
//        movieFile?.runBenchmark = true
//        movieFile?.playAtActualSpeed = true
//        movieFile?.audioEncodingTarget = movieWriter
//        movieFile?.enableSynchronizedEncoding(using: movieWriter)
        
        
        var pathToMovie: String = URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Documents/Movie.m4v").absoluteString
        unlink((pathToMovie as NSString).utf8String)
        // If a file already exists, AVAssetWriter won't let you record new frames, so delete the old movie
//        var movieURL = URL.fileURL(withPath: pathToMovie)
        var movieURL = URL(fileURLWithPath: pathToMovie)
        movieWriter = GPUImageMovieWriter(movieURL: movieURL, size: CGSize(width: 480.0, height: 640.0))
        movieWriter.encodingLiveVideo = true
        
//        [filter addTarget:movieWriter];
//        [filter addTarget:filterView];
        defaultFilter.addTarget(movieWriter)
        defaultFilter.addTarget(filteredVideoView)

        
        
        
        movieWriter?.startRecording()
        movieFile?.startProcessing()
        
        if sender.state == .ended {
            movieWriter?.finishRecording(completionHandler: {
                let capturedVC = self.storyboard?.instantiateViewController(withIdentifier: "capturedVC") as! Captured
                // file:///private/var/mobile/Containers/Data/Application/F86B1236-2700-4E87-96C4-7740B5954D9C/tmp/E59C9D55-67A0-4740-89C3-F0613BEC9966.mov
                // file:///var/mobile/Containers/Data/Application/C2142F8F-1E68-4047-A71C-5E65939FC283/Documents/movie.mp4

                capturedVC.capturedURL = movieURL
                self.navigationController?.pushViewController(capturedVC, animated: true)
            })
        }
    }
    
    /// Function: Take the photo.
    func takePhoto() {
        defaultFilter.useNextFrameForImageCapture()
        
        let capturedVC = self.storyboard?.instantiateViewController(withIdentifier: "capturedVC") as! Captured
        capturedVC.capturedImage = defaultFilter.imageFromCurrentFramebuffer()
        self.navigationController?.pushViewController(capturedVC, animated: true)
    }
    
    /// Function: Switch the GPUImageVideoCamera's device camera.
    func switchCamera() {
        videoCamera?.rotateCamera()
    }
    
    /// Function: Zoom in on the frame.
    // TODO:
    func zoom(sender: UIPinchGestureRecognizer) {
//        let zoomScale = min(maxZoomScale, max(1.0, min(beginZoomScale * pinch.scale,  captureDevice!.activeFormat.videoMaxZoomFactor)))
        
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        UIApplication.shared.isStatusBarHidden = false
        UIApplication.shared.statusBarStyle = .lightContent
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        /// Create GPUImageVideoCamera
        videoCamera = GPUImageVideoCamera(sessionPreset: AVCaptureSessionPresetHigh, cameraPosition: .front)
        videoCamera?.horizontallyMirrorRearFacingCamera = false
        videoCamera?.horizontallyMirrorFrontFacingCamera = true
        videoCamera?.outputImageOrientation = .portrait
        // Add the camera to GPUImageView
        videoCamera?.addTarget(defaultFilter)
        defaultFilter.addTarget(filteredVideoView)
        videoCamera?.startCapture()

        view.insertSubview(filteredVideoView, at: 0)
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
        // Dispose of any resources that can be recreated.
    }


}

