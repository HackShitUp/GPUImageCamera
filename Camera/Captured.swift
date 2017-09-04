//
//  Captured.swift
//  Camera
//
//  Created by Joshua Choi on 9/1/17.
//  Copyright © 2017 Joshua Choi. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class Captured: UIViewController {

    var capturedImage: UIImage?
    var capturedURL: URL?
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBAction func exit(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        view.backgroundColor = UIColor.black

        if capturedImage != nil {
            imageView.image = capturedImage!
            
        } else {
            print(capturedURL!)
            // MARK: - AVPlayer
            let player = AVPlayer(url: self.capturedURL!)
            let playerLayer = AVPlayerLayer(player: player)
            playerLayer.frame = self.imageView.bounds
            playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
            self.imageView.contentMode = .scaleAspectFit
            self.imageView.layer.addSublayer(playerLayer)
            player.isMuted = false
            player.play()
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
