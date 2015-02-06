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
    
    var originalImageViewCenter:CGPoint!
    var originalImageViewFrameSize:CGRect!
    
    var scheduleText:UILabel!
    
    var tappedPoint:CGPoint!
    var tappedView:UIView!
    
    var snap:UISnapBehavior!
    var animator:UIDynamicAnimator!
    
    var imageViewDidShrink = false
    
    
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
        
        animator = UIDynamicAnimator(referenceView: view)

    
        datePicker.hidden = true
        datePicker.frame = self.view.frame
        datePicker.center = self.view.center


        
        let panGesture = UIPanGestureRecognizer(target: self, action: Selector("inboxImageWasPanned:"))
        view.addGestureRecognizer(panGesture)
       
    }
    
    func setUpInbox(){

        
     //   imageView.frame = CGRectMake(0,83,320,568)
     //   let stretchRatio = 1.333333
        originalImageViewFrameSize = imageView.frame
        imageView.image = imageToShow
    //    imageView.image = imageWithImage(imageToShow!, scaledToSize: CGSizeMake(imageView.frame.size.width,imageView.frame.size.height))
        imageView.alpha = 1
        imageView.layer.cornerRadius = 0
     //   view.addSubview(imageView)
        originalImageViewCenter = CGPointMake(self.view.frame.width/2, self.view.frame.height-210)
        imageViewDidShrink = false
        let tapGesture = UITapGestureRecognizer(target: self, action: Selector("inboxImageWasTapped:"))
        
        imageView.userInteractionEnabled = true
        imageView.addGestureRecognizer(tapGesture)

    }
    
    func inboxImageWasTapped(sender: UITapGestureRecognizer){
        println("tap")
        sender.delegate = self
        
        

        
        
        if !imageViewDidShrink {
            
            self.shrinkImageViewWithCenter(originalImageViewCenter)
        }
        //doesn't make the image bigger
//        else {
//            imageView.layer.cornerRadius = 0
//            imageView.clipsToBounds = false
//            
//            UIView.animateWithDuration(0.1, animations: { () -> Void in
//                
//                self.imageView.frame.size = self.originalImageViewFrameSize.size
//                self.imageView.center = self.originalImageViewCenter
//                //    self.imageView.center = self.pointInView
//                
//                }, completion: {(value: Bool) in
//                    self.imageViewDidShrink = false
//            })
//
//
//        }
    }
    
    func inboxImageWasPanned(sender: UIPanGestureRecognizer){
        
        sender.delegate = self
        
        if (sender.state == .Began){
            
            if (snap != nil) {
                animator.removeBehavior(snap)
            }
        
            println("pan began")
            tappedPoint = sender.locationInView(view)
            tappedView = view.hitTest(tappedPoint, withEvent: nil)
        
        }
        
        if (tappedView == imageView && sender.state == .Changed && imageViewDidShrink) {
            
            println("changed")
            let translation = sender.translationInView(view)
            imageView.center = CGPointMake(imageView.center.x, imageView.center.y + translation.y)
            sender.setTranslation(CGPointMake(0,0), inView: view)
            self.updateScheduleText()

        }
        
        if (tappedView == imageView && sender.state == .Changed && !imageViewDidShrink) {
            
            tappedPoint = sender.locationInView(view)
            self.shrinkImageViewWithCenter(CGPointMake(self.view.center.x, tappedPoint.y))
            
        }

        
        
        
        if (tappedView == imageView && sender.state == .Ended && imageViewDidShrink) {
            println("ended")
            
            if (snap != nil) {
                animator.removeBehavior(snap)
            }
            
            
            if (imageView.frame.origin.y < 370) { // l8r it
                snap = UISnapBehavior(item: imageView, snapToPoint: CGPointMake(originalImageViewCenter.x+100, 70))
                snap.damping = 0.8
                animator.addBehavior(snap)
                imageView.userInteractionEnabled = false
              //  self.scheduleLocalNotification()
                calButton.hidden = true
                cyaButton.hidden = true
                self.disappearImageTwo()
            }
            else { // snap back
                snap = UISnapBehavior(item: imageView, snapToPoint: originalImageViewCenter)
                snap.damping = 0.8
                animator.addBehavior(snap)
            }
        }
        
    }
    
    func shrinkImageViewWithCenter(center: CGPoint){
        
        cameraButton.hidden = true
        imageView.layer.cornerRadius = circleViewFrameSize.width/2
        imageView.clipsToBounds = true
        
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            
            self.imageView.frame.size = self.circleViewFrameSize
            self.imageView.center = center
            //    self.imageView.center = self.pointInView
            
            }, completion: {(value: Bool) in
                self.imageViewDidShrink = true
        })
    }
    
    func disappearImageTwo(){
        
        var scheduleTextNewFrame = self.scheduleText.frame
        scheduleTextNewFrame.origin.y = -scheduleTextNewFrame.size.height
        
        
        UIView.animateWithDuration(0.6, delay: 0.8, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
            
            //
            //                        if (self.snap != nil) {
            //                            self.animator.removeBehavior(self.snap)
            //                        }
            
            self.imageView.alpha = 0
            self.scheduleText.frame = scheduleTextNewFrame
            self.scheduleText.alpha = 0.3
            
            }, completion: {(value: Bool) in
                
                self.scheduleLocalNotification()
                self.setUpInbox()
                self.addActionButtons()
                
                
        })
        
        
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
        
        if cameraButton != nil {
            cameraButton.removeFromSuperview()
        }
        
        if scheduleText != nil {
            scheduleText.removeFromSuperview()
        }
        
        scheduleText = UILabel(frame: CGRect(x: 10, y: 40, width: 100, height: 40))
        scheduleText.alpha = 1
        scheduleText.font = UIFont(name: "ArialRoundedMTBold", size: 40.0)
        scheduleText.textColor = UIColor.blackColor()
        scheduleText.textAlignment = .Center
       // scheduleText.center.x = view.center.x
        scheduleText.sizeToFit()
        scheduleText.text = ""
        view.addSubview(scheduleText)
        
        cyaButton = UIButton(frame: CGRectMake(20,self.view.frame.height-60, actionButtonWidth, actionButtonWidth))
        cyaButton.addTarget(self, action: Selector("trashImage:"), forControlEvents:UIControlEvents.TouchUpInside)
        let cyaButtonImage = UIImage(named: "cyaButtonImage")
     //   cyaButton.setImage(cyaButtonImage, forState: .Normal)
        cyaButton.setTitle("CYA", forState: UIControlState.Normal)
        cyaButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        cyaButton.alpha = 1
        view.addSubview(cyaButton)
        view.sendSubviewToBack(cyaButton)
        
        calButton = UIButton(frame: CGRectMake(self.view.frame.width-70,self.view.frame.height-60, actionButtonWidth, actionButtonWidth))
        calButton.addTarget(self, action: Selector("openCalendar:"), forControlEvents:UIControlEvents.TouchUpInside)
        let calButtonImage = UIImage(named: "calButtonImage")
     //   calButton.setImage(calButtonImage, forState: .Normal)
        calButton.setTitle("CAL", forState: UIControlState.Normal)
        calButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        calButton.alpha = 1
        view.addSubview(calButton)
        view.sendSubviewToBack(calButton)
        
        scheduleButton = UIButton(frame: CGRectMake(self.view.frame.width/2,self.view.frame.height-100, actionButtonWidth,actionButtonWidth))
        scheduleButton.center.x = self.view.center.x
        scheduleButton.addTarget(self, action: Selector("scheduleImage:"), forControlEvents: UIControlEvents.TouchUpInside)
        scheduleButton.setTitle("L8R", forState: UIControlState.Normal)
        scheduleButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        scheduleButton.hidden = true
        view.addSubview(scheduleButton)
        
        
        cameraButton = UIButton(frame: CGRectMake(self.view.frame.width-70,self.view.frame.height-60, 30, 30))
        cameraButton.addTarget(self, action: Selector("swipeView:"), forControlEvents:UIControlEvents.TouchUpInside)
        let cameraButtonImage = UIImage(named: "cameraButtonImage")
        cameraButton.setImage(cameraButtonImage, forState: .Normal)
        cameraButton.alpha = 1
        view.addSubview(cameraButton)
        view.bringSubviewToFront(cameraButton)
        
        
    }
    
    func trashImage(sender: UIButton){
        
    }
    
    func swipeView(sender: UIButton){
        
        let cvc = self.storyboard!.instantiateViewControllerWithIdentifier("CameraViewController") as CameraViewController
        self.presentViewController(cvc, animated: true, completion: nil)
        
    }
    
    func openCalendar(sender: UIButton){
        
        //animate up imageView
        
        if (snap != nil) {
            animator.removeBehavior(snap)
        }
        
        var imageViewNewFrame = imageView.frame
        imageViewNewFrame.origin.y = imageView.frame.origin.y-300
        imageView.userInteractionEnabled = false
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
    
    func updateScheduleText(){
        
        if imageView.frame.origin.y < 81 {
            scheduleText.text = "Someday"
        }
        else if imageView.frame.origin.y < 160 {
            scheduleText.text = "In a year"
        }
        else if imageView.frame.origin.y < 220 {
            scheduleText.text = "Next Month"
        }
        else if imageView.frame.origin.y < 300 {
            scheduleText.text = "Next Week"
        }
        else if imageView.frame.origin.y < 380 {
            scheduleText.text = "Tomorrow"
        }
        else if imageView.frame.origin.y < 420 {
            scheduleText.text = ""
        }
        
        
        scheduleText.sizeToFit()
        
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