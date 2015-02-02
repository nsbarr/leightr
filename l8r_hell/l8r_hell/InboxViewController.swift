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
        theImageView.frame = CGRectMake(0,83,320,568)
        let imageToShow = UIImage(contentsOfFile: theImagePath)
        let stretchRatio = 1.333333
        println(stretchRatio)
        
      //  theImageView.image = imageToShow

        theImageView.image = imageWithImage(imageToShow!, scaledToSize: CGSizeMake(theImageView.frame.size.width,theImageView.frame.size.height))
        
//        var newFrame = theImageView.frame
//        newFrame.origin.y = view.frame.height-140
//        theImageView.frame = newFrame
        

        view.addSubview(theImageView)
        view.addSubview(cameraButton)
        view.bringSubviewToFront(cameraButton)
       
    }
    func imageWithImage(image:UIImage, scaledToSize newSize:CGSize) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
        image.drawInRect(CGRectMake(0, 0, newSize.width, newSize.height))
        var newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}