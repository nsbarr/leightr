//
//  ViewController.swift
//  l8r_hack
//
//  Created by nick barr on 10/26/14.
//  Copyright (c) 2014 poemsio. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIGestureRecognizerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    
    var circleView:UIImageView!
    let circleRadius:CGFloat = 30
    let scheduleRadius:CGFloat = 15
    var originalCirclePoint:CGPoint!
    var tappedPoint:CGPoint!
    var tappedView:UIView!
    var snap:UISnapBehavior!
    var animator:UIDynamicAnimator!
    var scheduleText:UILabel!
    var calendarPicker:UIView!
    var imageView:UIView!
    var calendarPickerLabel:UILabel!
    let imagePickerController = UIImagePickerController()
    var didTakePicture = false
    var okButton: UIButton!
    var isSavingPictures = false
    
    
    @IBOutlet var handlePan: UIPanGestureRecognizer!
    @IBOutlet var handleTap: UITapGestureRecognizer!
    
    @IBOutlet var overlayView: UIView!
    
    
    @IBAction func showImagePicker(sender: UIButton) {

        self.showImagePickerForSourceType(UIImagePickerControllerSourceType.Camera)
    }
    
    
    
    
    @IBAction func handleTap(sender: UITapGestureRecognizer) {
        sender.delegate = self
        println("tap")
        tappedPoint = sender.locationInView(view)
        tappedView = view.hitTest(tappedPoint, withEvent: nil)
        if (snap != nil) {
            animator.removeBehavior(snap)
        }
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

            view.addSubview(calendarPicker)
            calendarPicker.addSubview(calendarPickerLabel)
            
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
                snap = UISnapBehavior(item: circleView, snapToPoint: CGPointMake(0 + circleView.frame.width, view.frame.height - circleView.frame.height))
                snap.damping = 0.8
                animator.addBehavior(snap)
                
                okButton = UIButton(frame: CGRectMake(calendarPicker.frame.width-44,calendarPicker.frame.height-44, 44, 44))
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
    
    func confirmSchedule(){
        println("confirmingSchedule")
        var scheduleTextNewFrame = self.scheduleText.frame
        scheduleTextNewFrame.origin.y = -scheduleTextNewFrame.size.height
        
//        var circleViewNewFrame = CGRect(x: view.frame.width-44, y: scheduleText.frame.origin.y+circleView.frame.height/2, width: circleRadius*2, height: circleRadius*2)
//        circleViewNewFrame.origin.y = -500
//        

        UIView.animateWithDuration(0.6, delay: 0.8, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
            
            
//            if (self.snap != nil) {
//                self.animator.removeBehavior(self.snap)
//            }

            
       //     self.circleView.frame.origin.y = -100
            self.circleView.alpha = 0
            
            
            self.scheduleText.frame = scheduleTextNewFrame
            self.scheduleText.alpha = 0.3
            
            }, completion: {(value: Bool) in
            self.calendarPicker.removeFromSuperview()
            self.calendarPickerLabel.removeFromSuperview()
            self.showCameraView()
            self.scheduleText.alpha = 1
            self.didTakePicture = false
        
                })
    }
    


    
    func schedulePhoto(sender: UIButton){
        println("scheduling")
        if (snap != nil) {
            animator.removeBehavior(snap)
        }
        self.shrinkCalendarPicker()
        circleView.removeFromSuperview()
        okButton.removeFromSuperview()
        calendarPicker.removeFromSuperview()
        calendarPickerLabel.removeFromSuperview()


        didTakePicture = false
        
        self.showCameraView()
        
    }
    
    func showImagePickerForSourceType(sourceType: UIImagePickerControllerSourceType){
        
        
        
        imagePickerController.modalPresentationStyle = UIModalPresentationStyle.CurrentContext
        imagePickerController.sourceType = sourceType
        imagePickerController.delegate = self
        
        
        if (sourceType == UIImagePickerControllerSourceType.Camera){
            
            
            imagePickerController.showsCameraControls = false
            
            self.overlayView.frame = CGRectMake(0, imagePickerController.cameraOverlayView!.frame.width, imagePickerController.cameraOverlayView!.frame.width, imagePickerController.cameraOverlayView!.frame.height)//-self.view.frame.width)
            self.overlayView.backgroundColor = UIColor.redColor()
        
            imagePickerController.cameraOverlayView = self.overlayView
            self.overlayView = nil

            
        }
        self.presentViewController(self.imagePickerController, animated: true, completion: nil)
        
        

    }
    
    func takePicture(){
            self.imagePickerController.takePicture()
            self.imageView.layer.cornerRadius = self.circleRadius
            self.imageView.clipsToBounds = true
            circleView.alpha = 0.0
        
        
            
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.imageView.frame.size = self.circleView.frame.size
            self.imageView.center = self.circleView.center
            
                }, completion:nil)
           didTakePicture = true
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSBundle.mainBundle().loadNibNamed("OverlayView", owner: self, options: nil)
        
        
        // Do any additional setup after loading the view, typically from a nib.
        

        

        
        calendarPicker = UIView(frame: CGRect(x:0, y:view.frame.height-60, width:self.view.frame.width, height:60))
        calendarPicker.backgroundColor = UIColor.blackColor()
        calendarPicker.alpha = 0.8
        
        calendarPickerLabel = UILabel(frame: CGRect(x:self.view.frame.width/2, y:12, width:0, height:0))
        calendarPickerLabel.font = UIFont(name: "ArialRoundedMTBold", size: 18.0)
        calendarPickerLabel.text = "Calendar"
        calendarPickerLabel.textColor = UIColor.whiteColor()
        println(calendarPickerLabel.center)
        calendarPickerLabel.sizeToFit()
        calendarPickerLabel.center.x = calendarPicker.center.x
        
        
        
        
        
        
        animator = UIDynamicAnimator(referenceView: view)
        
      //  [[[[UIApplication sharedApplication] delegate] window] addSubview:controllerView];
        
        view.backgroundColor = UIColor.whiteColor()
        view.alpha = 1.0
        
        self.showCameraView()
        self.showImagePickerForSourceType(UIImagePickerControllerSourceType.Camera)

        

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
    
    func showCameraView(){
        
        if (scheduleText != nil){
            scheduleText.removeFromSuperview()
        }
        
        if (circleView != nil){
            circleView.removeFromSuperview()
        }
        
        println("showing cam")
        let imagePickerControllerFrame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.width)
        imageView = imagePickerController.view
        imageView.frame = imagePickerControllerFrame;
        imageView.layer.cornerRadius = 0
        
        circleView = UIImageView(frame: CGRect(x: self.view.frame.width/2-circleRadius, y: self.view.frame.height-240, width: circleRadius*2, height: circleRadius*2))
        circleView.clipsToBounds = true
        circleView.image = UIImage(named: "snapbutton.png")
        circleView.layer.cornerRadius = circleRadius
        circleView.userInteractionEnabled = true
        circleView.layer.zPosition = 10
        circleView.alpha = 1
        originalCirclePoint = circleView.center
        
        scheduleText = UILabel(frame: CGRect(x: 10, y: 40, width: 100, height: 40))
        
        
        view.addSubview(circleView)
        view.addSubview(imageView)
        view.addSubview(scheduleText)
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


        scheduleText.font = UIFont(name: "ArialRoundedMTBold", size: 40.0)
        scheduleText.textColor = UIColor.blackColor()
        scheduleText.sizeToFit()

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


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

