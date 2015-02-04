//
//  InboxViewController.swift
//  l8r_hell
//
//  Created by nick barr on 1/24/15.
//  Copyright (c) 2015 poemsio. All rights reserved.
//

import Foundation
import UIKit

class InboxViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet var cameraButton: UIButton!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var datePicker: UIDatePicker!
    
    var imageToShow: UIImage!
    var cyaButton: UIButton!
    var calButton: UIButton!
    var scheduleButton: UIButton!
    
    var tappedPoint:CGPoint!
    var tappedView:UIView!
    
    
    let circleViewFrameSize:CGSize = CGSizeMake(80, 80)
    let actionButtonWidth:CGFloat = 60
    
    
    @IBAction func cameraButtonTapped(sender: UIButton){
        
        let cvc = self.storyboard!.instantiateViewControllerWithIdentifier("CameraViewController") as CameraViewController
        self.presentViewController(cvc, animated: true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        println("inboxViewLoaded")
        
        let theImagePath = NSUserDefaults.standardUserDefaults().objectForKey("imagePath") as NSString
        imageToShow = UIImage(contentsOfFile: theImagePath)
        if imageToShow != nil { //load inbox
            self.addActionButtons()
            self.setUpInbox()
        }
        else {
            println("no image to show")
        }
    
        datePicker.hidden = true
        datePicker.frame = self.view.frame
        datePicker.center = self.view.center

        view.addSubview(cameraButton)
        view.bringSubviewToFront(cameraButton)
        println(imageView.superview)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: Selector("inboxImageWasPanned:"))
        view.addGestureRecognizer(panGesture)
       
    }
    
    func setUpInbox(){
        

        
     //   imageView.frame = CGRectMake(0,83,320,568)
     //   let stretchRatio = 1.333333
        imageView.image = imageToShow
    //    imageView.image = imageWithImage(imageToShow!, scaledToSize: CGSizeMake(imageView.frame.size.width,imageView.frame.size.height))
        imageView.alpha = 1
        imageView.layer.cornerRadius = 0
     //   view.addSubview(imageView)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: Selector("inboxImageWasTapped:"))
        
        imageView.userInteractionEnabled = true
        imageView.addGestureRecognizer(tapGesture)

    }
    
    func inboxImageWasTapped(sender: UITapGestureRecognizer){
        println("tap")
        sender.delegate = self
        
        imageView.layer.cornerRadius = circleViewFrameSize.width/2
        imageView.clipsToBounds = true
        
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            
            self.imageView.frame.size = self.circleViewFrameSize
            self.imageView.center = self.view.center
            //    self.imageView.center = self.pointInView
            
            }, completion:nil)
    }
    
    func inboxImageWasPanned(sender: UIPanGestureRecognizer){
        
        sender.delegate = self
        
        if (sender.state == .Began){
        
            println("pan began")
            tappedPoint = sender.locationInView(view)
            tappedView = view.hitTest(tappedPoint, withEvent: nil)
        
        }
        
        if (tappedView == imageView && sender.state == .Changed) {
            
            println("changed")
            let translation = sender.translationInView(view)
            imageView.center = CGPointMake(imageView.center.x, imageView.center.y + translation.y)
            sender.setTranslation(CGPointMake(0,0), inView: view)

        }
        
        if (tappedView == imageView && sender.state == .Ended) {
            println("ended")
        }
        
    }
        

    
    func addActionButtons(){
        
        if cyaButton != nil {
            cyaButton.removeFromSuperview()
        }
        
        if calButton != nil {
            calButton.removeFromSuperview()
        }
        
        if scheduleButton != nil {
            scheduleButton.removeFromSuperview()
        }
        
        cyaButton = UIButton(frame: CGRectMake(20,self.view.frame.height-60, actionButtonWidth, actionButtonWidth))
        cyaButton.addTarget(self, action: Selector("trashImage:"), forControlEvents:UIControlEvents.TouchUpInside)
        let cyaButtonImage = UIImage(named: "cyaButtonImage")
        cyaButton.setImage(cyaButtonImage, forState: .Normal)
        cyaButton.alpha = 1
        view.addSubview(cyaButton)
        view.sendSubviewToBack(cyaButton)
        
        calButton = UIButton(frame: CGRectMake(self.view.frame.width-70,self.view.frame.height-60, actionButtonWidth, actionButtonWidth))
        calButton.addTarget(self, action: Selector("openCalendar:"), forControlEvents:UIControlEvents.TouchUpInside)
        let calButtonImage = UIImage(named: "calButtonImage")
        calButton.setImage(calButtonImage, forState: .Normal)
        calButton.alpha = 1
        view.addSubview(calButton)
        view.sendSubviewToBack(calButton)
        
        scheduleButton = UIButton(frame: CGRectMake(self.view.frame.width/2,self.view.frame.height-100, actionButtonWidth,actionButtonWidth))
        scheduleButton.center.x = self.view.center.x
        scheduleButton.addTarget(self, action: Selector("scheduleImage:"), forControlEvents: UIControlEvents.TouchUpInside)
        scheduleButton.setTitle("Ok", forState: UIControlState.Normal)
        scheduleButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        scheduleButton.hidden = true
        view.addSubview(scheduleButton)
    }
    
    func trashImage(sender: UIButton){
        
    }
    
    func openCalendar(sender: UIButton){
        
        //animate up imageView
        
        var imageViewNewFrame = imageView.frame
        imageViewNewFrame.origin.y = imageView.frame.origin.y-200
        calButton.hidden = true
        cyaButton.hidden = true
        self.scheduleButton.hidden = false
        
        UIView.animateWithDuration(0.4, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
            
            self.imageView.frame = imageViewNewFrame
            self.datePicker.hidden = false
            
            }, completion: {(value: Bool) in
                println("complete")
                
                
                //add confirmButton
                

                
        })
        

        
    }
    
    func scheduleImage(sender: UIButton){
        datePicker.hidden = true
        self.disappearImage()
        //show next image in the inbox, if there is one.
        println("scheduled")
    }
    
    func disappearImage(){
        self.scheduleButton.hidden = true
        var imageViewNewFrame = imageView.frame
        imageViewNewFrame.origin.y = imageView.frame.origin.y-300
        
        UIView.animateWithDuration(0.7, delay: 0.2, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
            
            self.imageView.alpha = 0.2
            self.imageView.frame = imageViewNewFrame
            
            }, completion: {(value: Bool) in
                println("complete")
                
                //add confirmButton
                
                self.scheduleLocalNotification()
                self.setUpInbox()
                self.addActionButtons()
                
        })

    }
    
    func scheduleLocalNotification() {
        
        var currentTime = NSDate()
        var theCalendar = NSCalendar.currentCalendar()
        var scheduledDate = datePicker.date
        var localNotification = UILocalNotification()
        
        localNotification.fireDate = scheduledDate
        localNotification.repeatInterval = NSCalendarUnit.YearCalendarUnit //this is just an evil way to not expire the notification
        localNotification.alertBody = "Your l8r is now"
        localNotification.alertAction = "View"
        localNotification.category = "shoppingListReminderCategory"
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
        
    }

    
    func imageWithImage(image:UIImage, scaledToSize newSize:CGSize) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
        image.drawInRect(CGRectMake(0, 0, newSize.width, newSize.height))
        var newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}