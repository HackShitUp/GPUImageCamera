//
//  Captured.swift
//  Camera
//
//  Created by Joshua Choi on 9/1/17.
//  Copyright © 2017 Joshua Choi. All rights reserved.
//

import UIKit

class Captured: UIViewController {

    var capturedImage: UIImage?
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBAction func exit(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)

        if capturedImage != nil {
            imageView.image = capturedImage!
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
