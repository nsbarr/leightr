//
//  InboxViewController.swift
//  l8r_hell
//
//  Created by nick barr on 1/24/15.
//  Copyright (c) 2015 poemsio. All rights reserved.
//

import Foundation
import UIKit

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate {
    
    
    var inboxButton: UIButton!
    var libraryButton: UIButton!
    var circleView: UIImageView!
    let circleRadius:CGFloat = 40
    var originalCirclePoint:CGPoint!
    
    let imagePickerController = UIImagePickerController()
    var imageView: UIView!
    var tappedPoint:CGPoint!
    var tappedView:UIView!
    
    var scheduleText:UILabel!
    
    var snap:UISnapBehavior!
    var animator:UIDynamicAnimator!
    
    var didTakePicture = false
    var isSavingPictures = false
    
    var calendarPickerLabel:UILabel!
    var calendarPicker:UIView!
    var okButton: UIButton!



    
    @IBOutlet var handlePan: UIPanGestureRecognizer!
    @IBOutlet var handleTap: UITapGestureRecognizer!
    
    
    
    override func viewDidLoad() {
        println(self.parentViewController)
        super.viewDidLoad()
        animator = UIDynamicAnimator(referenceView: view)
        self.addMenuButtons()
        self.addCircleViewAndScheduleText()
        self.showCameraView()
        self.showImagePickerForSourceType(UIImagePickerControllerSourceType.Camera)
        self.setUpCalendar()
        
        
        println(self.view.gestureRecognizers)
        println(self.parentViewController?.view.gestureRecognizers)
        
        


    }
    
    @IBAction func handleTap(sender: UITapGestureRecognizer) {
        sender.delegate = self
        println("tap")
        tappedPoint = sender.locationInView(view)
        tappedView = view.hitTest(tappedPoint, withEvent: nil)

        if (tappedView == circleView && !didTakePicture){
            println("circleview was tapped")
            self.takePicture()
        }
    }
    
    @IBAction func handlePan(sender: UIPanGestureRecognizer) {
        
        sender.delegate = self
        
        if (sender.state == .Began){
            tappedPoint = sender.locationInView(view)
            tappedView = view.hitTest(tappedPoint, withEvent: nil)
            println("began")
            if (snap != nil) {
                animator.removeBehavior(snap)
            }
        }
        
        if (tappedView == circleView && sender.state == .Changed) {
            
            
            print("y position is \(circleView.frame.origin.y)")
            
            let translation = sender.translationInView(view)
            circleView.center = CGPointMake(circleView.center.x, circleView.center.y + translation.y)
            sender.setTranslation(CGPointMake(0,0), inView: view)
            if didTakePicture{
                self.imageView.center = self.circleView.center
            }
            self.updateScheduleText()
            if ((circleView.frame.origin.y > 460 || circleView.frame.origin.y < 380) && !didTakePicture){
                
                println("takingPicture")
                self.takePicture()
            }
            
            if (CGRectIntersectsRect(circleView.frame, calendarPicker.frame)) {
                println("overlap")
                self.growCalendarPicker()
            }
            else {
                self.shrinkCalendarPicker()
            }
            
        }
        
        if (tappedView == circleView && sender.state == .Ended) {
            
            println("ended")
            
            if (snap != nil) {
                animator.removeBehavior(snap)
            }
            
            if (CGRectIntersectsRect(circleView.frame, calendarPicker.frame) == true){
                snap = UISnapBehavior(item: circleView, snapToPoint: CGPointMake(0 + circleView.frame.width/2, view.frame.height - circleView.frame.height/2))
                snap.damping = 0.8
                animator.addBehavior(snap)
                
                okButton = UIButton(frame: CGRectMake(calendarPicker.frame.width-64,calendarPicker.frame.height-44, 44, 44))
                okButton.addTarget(self, action: Selector("schedulePhoto:"), forControlEvents:UIControlEvents.TouchUpInside)
                okButton.backgroundColor = UIColor.blackColor()
                okButton.titleLabel?.font = UIFont(name: "ArialRoundedMTBold", size: 18.0)
                okButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
                okButton.setTitle("Ok", forState: UIControlState.Normal)
                calendarPicker.addSubview(okButton)
            }
                
            
            else if (circleView.frame.origin.y < 370) { //schedule
                println("snapping up")
                
                snap = UISnapBehavior(item: circleView, snapToPoint: CGPointMake(view.frame.width-44, scheduleText.frame.origin.y+circleView.frame.height/2))
                snap.damping = 0.8
                animator.addBehavior(snap)
                self.confirmSchedule()
                
            }
                
            else {
                snap = UISnapBehavior(item: circleView, snapToPoint: originalCirclePoint)
                snap.damping = 0.8
                animator.addBehavior(snap)
            }
            
        }
        
    }
    
    func setUpCalendar(){
        calendarPicker = UIView(frame: CGRect(x:0, y:view.frame.height-60, width:self.view.frame.width, height:60))
        calendarPicker.backgroundColor = UIColor.blackColor()
        calendarPicker.alpha = 1.0
        
        calendarPickerLabel = UILabel(frame: CGRect(x:self.view.frame.width/2, y:12, width:0, height:0))
        calendarPickerLabel.font = UIFont(name: "ArialRoundedMTBold", size: 18.0)
        calendarPickerLabel.text = "Calendar"
        calendarPickerLabel.textColor = UIColor.whiteColor()
        println(calendarPickerLabel.center)
        calendarPickerLabel.sizeToFit()
        calendarPickerLabel.center.x = calendarPicker.center.x
    }
    
    func shrinkCalendarPicker(){
        
        var newFrame = calendarPicker.frame
        newFrame.origin.y = view.frame.height-60
        calendarPicker.frame = newFrame
        
        
        calendarPickerLabel.text = "Calendar"
        calendarPickerLabel.sizeToFit()
        calendarPickerLabel.textAlignment = NSTextAlignment.Center
        calendarPickerLabel.center.x = calendarPicker.center.x
        
    }
    
    
    func growCalendarPicker(){
        println("growing")
        var newFrame = CGRect(x:0, y:view.frame.height-200, width:self.view.frame.width, height:200)
        calendarPicker.frame = newFrame
        
        calendarPickerLabel.text = "Release to Pick Date"
        calendarPickerLabel.sizeToFit()
        calendarPickerLabel.textAlignment = NSTextAlignment.Center
        calendarPickerLabel.center.x = calendarPicker.center.x
        
        scheduleText.text = ""
        
    }
    
    func schedulePhoto(sender: UIButton){
        println("scheduling")
        if (snap != nil) {
            animator.removeBehavior(snap)
        }
        self.shrinkCalendarPicker()

        
        didTakePicture = false
        self.addCircleViewAndScheduleText()
        self.showCameraView()
        
    }
    
    func updateScheduleText(){
        
        if circleView.frame.origin.y < 260 {
            scheduleText.text = "In a year"
        }
        else if circleView.frame.origin.y < 300 {
            scheduleText.text = "Next Month"
        }
        else if circleView.frame.origin.y < 340 {
            scheduleText.text = "Next Week"
        }
        else if circleView.frame.origin.y < 380 {
            scheduleText.text = "Tomorrow"
        }
        else if circleView.frame.origin.y < 420 {
            scheduleText.text = ""
        }
        

        scheduleText.sizeToFit()
        
    }

    
    
    func addMenuButtons(){
        inboxButton = UIButton(frame: CGRectMake(20,self.view.frame.height-80, 50, 50))
        inboxButton.addTarget(self, action: Selector("swipeView:"), forControlEvents:UIControlEvents.TouchUpInside)
        let inboxButtonImage = UIImage(named: "inboxButtonImage")
        inboxButton.setImage(inboxButtonImage, forState: .Normal)
        view.addSubview(inboxButton)
        
        libraryButton = UIButton(frame: CGRectMake(self.view.frame.width-70,self.view.frame.height-80, 50, 50))
        inboxButton.addTarget(self, action: Selector("swipeView:"), forControlEvents:UIControlEvents.TouchUpInside)
        let libraryButtomImage = UIImage(named: "libraryButtonImage")
        libraryButton.setImage(libraryButtomImage, forState: .Normal)
        view.addSubview(libraryButton)
        
    }
    
    func addCircleViewAndScheduleText(){
        
        if (circleView? != nil){
            circleView.removeFromSuperview()
        }
        
        if (scheduleText? != nil){
            scheduleText.removeFromSuperview()
        }
        if (okButton? != nil){
            okButton.removeFromSuperview()
        }
        if (calendarPicker? != nil){
            calendarPicker.removeFromSuperview()
        }
        if (calendarPickerLabel? != nil){
            calendarPickerLabel.removeFromSuperview()
        }

        scheduleText = UILabel(frame: CGRect(x: 10, y: 40, width: 100, height: 40))
        scheduleText.alpha = 1
        scheduleText.font = UIFont(name: "ArialRoundedMTBold", size: 40.0)
        scheduleText.textColor = UIColor.blackColor()
        view.addSubview(scheduleText)
        
        circleView = UIImageView(frame: CGRect(x: self.view.frame.width/2-circleRadius, y: self.view.frame.height-240, width: circleRadius*2, height: circleRadius*2))
        circleView.clipsToBounds = true
        circleView.image = UIImage(named: "snapbuttonvector")
        circleView.layer.cornerRadius = circleRadius
        circleView.userInteractionEnabled = true
        circleView.layer.zPosition = 10
        circleView.alpha = 1
        originalCirclePoint = circleView.center
        view.addSubview(circleView)
        
    }
    
    func showCameraView(){
        
       // self.showImagePickerForSourceType(UIImagePickerControllerSourceType.Camera)

        
        let imagePickerControllerFrame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.width)
        imagePickerController.view.frame = imagePickerControllerFrame;
        imageView = imagePickerController.view
        imageView.layer.cornerRadius = 0

        
        self.view.addSubview(imageView)
        
        libraryButton.alpha = 1
        inboxButton.alpha = 1

        
    }
    
    func showImagePickerForSourceType(sourceType: UIImagePickerControllerSourceType){
        
        imagePickerController.modalPresentationStyle = UIModalPresentationStyle.CurrentContext
        imagePickerController.sourceType = sourceType
        imagePickerController.delegate = self
        
        if (sourceType == UIImagePickerControllerSourceType.Camera){
            
            imagePickerController.showsCameraControls = false
            
            
            
            println(imagePickerController.view)
            
            println(imagePickerController.view.superview)
            

            
            
            
        }
        self.presentViewController(self.imagePickerController, animated: true, completion: nil)
        
        
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        //   let image = info(valueForKeyPath(UIImagePickerControllerOriginalImage))
        let tempImage = info[UIImagePickerControllerOriginalImage] as UIImage
        
        if isSavingPictures {
            UIImageWriteToSavedPhotosAlbum(tempImage, nil, nil, nil);
        }
        circleView.image = tempImage
        circleView.alpha = 1.0
        imageView.removeFromSuperview()
        
    }
    
    func takePicture(){
        self.imagePickerController.takePicture()
        self.imageView.layer.cornerRadius = self.circleRadius
        self.imageView.clipsToBounds = true
        self.view.bringSubviewToFront(self.imageView)
        self.view.sendSubviewToBack(self.circleView)
        println(self.view.subviews)
       // self.imageView.opaque = true
       // self.imageView.alpha = 1
       // self.circleView.alpha = 0
        //    circleView.alpha = 0.0
        
        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            
            self.imageView.frame.size = self.circleView.frame.size
            self.imageView.center = self.circleView.center
            
            }, completion:nil)
        didTakePicture = true
        
        
        view.addSubview(calendarPicker)
        calendarPicker.addSubview(calendarPickerLabel)
        
        libraryButton.alpha = 0
        inboxButton.alpha = 0
    }
    
    func confirmSchedule(){
        var scheduleTextNewFrame = self.scheduleText.frame
        scheduleTextNewFrame.origin.y = -scheduleTextNewFrame.size.height
        
        
        UIView.animateWithDuration(0.6, delay: 0.8, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
            
//            
//                        if (self.snap != nil) {
//                            self.animator.removeBehavior(self.snap)
//                        }
            
            self.circleView.alpha = 0
            self.scheduleText.frame = scheduleTextNewFrame
            self.scheduleText.alpha = 0.3
            
            }, completion: {(value: Bool) in

                self.showCameraView()
                self.addCircleViewAndScheduleText()
                self.didTakePicture = false
                
        })
    }
    
    
    func swipeView(sender: UIButton){
        let pvc = self.storyboard!.instantiateViewControllerWithIdentifier("PageViewController") as PageViewController
        let ivc = self.storyboard!.instantiateViewControllerWithIdentifier("InboxViewController") as InboxViewController
       //   ivc.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
       // pvc.setViewControllers([ivc], direction: UIPageViewControllerNavigationDirection.Reverse, animated: true, completion: nil)
       self.presentViewController(ivc, animated: true, completion: nil)
        
    }
}