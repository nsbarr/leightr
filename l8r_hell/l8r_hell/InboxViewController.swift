//
//  InboxViewController.swift
//  l8r_hell
//
//  Created by nick barr on 1/24/15.
//  Copyright (c) 2015 poemsio. All rights reserved.
//

import Foundation
import UIKit

class InboxViewController: UIViewController {
    
    @IBOutlet var cameraButton: UIButton!
    
    @IBOutlet var theImageView: UIImageView!
    
    
    @IBAction func cameraButtonTapped(sender: UIButton){
        
        let cvc = self.storyboard!.instantiateViewControllerWithIdentifier("CameraViewController") as CameraViewController
        //   ivc.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        // pvc.setViewControllers([ivc], direction: UIPageViewControllerNavigationDirection.Reverse, animated: true, completion: nil)
        self.presentViewController(cvc, animated: true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        println("inboxViewLoaded")
        
        
        let theImagePath = NSUserDefaults.standardUserDefaults().objectForKey("imagePath") as NSString
        
        theImageView.image = UIImage(contentsOfFile: theImagePath)
        
        view.addSubview(theImageView)
       
        
        
    }
}