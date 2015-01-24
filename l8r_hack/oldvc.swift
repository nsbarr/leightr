////
////  ViewController.swift
////  l8r_hack
////
////  Created by nick barr on 10/26/14.
////  Copyright (c) 2014 poemsio. All rights reserved.
////
//
//import UIKit
//
//class ViewController: UIViewController, UIGestureRecognizerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//    
//    
//    var circleView:UIImageView!
//    let circleRadius:CGFloat = 30
//    let scheduleRadius:CGFloat = 15
//    var originalCirclePoint:CGPoint!
//    var tappedPoint:CGPoint!
//    var tappedView:UIView!
//    var snap:UISnapBehavior!
//    var animator:UIDynamicAnimator!
//    var scheduleText:UILabel!
//    var calendarPicker:UIView!
//    var imageView:UIView!
//    var calendarPickerLabel:UILabel!
//    let imagePickerController = UIImagePickerController()
//    var didTakePicture = false
//    
//    
//    
//    @IBOutlet var cameraButton: UIButton!
//    @IBOutlet var handlePan: UIPanGestureRecognizer!
//    
//    @IBOutlet var overlayView: UIView!
//    @IBOutlet var snapButton: UIButton!
//    
//    
//    @IBAction func showImagePicker(sender: UIButton) {
//        
//        self.showImagePickerForSourceType(UIImagePickerControllerSourceType.Camera)
//    }
//    
//    
//    @IBAction func snapPhoto(sender: UIButton){
//        // [self.imagePickerController takePicture];
//        //   self.imagePickerController.takePicture()
//    }
//    
//    
//    @IBAction func handlePan(sender: UIPanGestureRecognizer) {
//        
//        sender.delegate = self
//        
//        if (sender.state == .Began){
//            tappedPoint = sender.locationInView(view)
//            tappedView = view.hitTest(tappedPoint, withEvent: nil)
//            println("began")
//            if (snap != nil) {
//                animator.removeBehavior(snap)
//            }
//        }
//        
//        if (tappedView == circleView && sender.state == .Changed) {
//            let translation = sender.translationInView(view)
//            circleView.center = CGPointMake(circleView.center.x, circleView.center.y + translation.y)
//            sender.setTranslation(CGPointMake(0,0), inView: view)
//            if !didTakePicture{
//                self.takePicture()
//            }
//            self.updateScheduleText()
//            
//            if (CGRectIntersectsRect(circleView.frame, calendarPicker.frame)) {
//                println("overlap")
//                self.growCalendarPicker()
//            }
//            else {
//                self.shrinkCalendarPicker()
//            }
//            
//        }
//        
//        if (tappedView == circleView && sender.state == .Ended) {
//            println("ended")
//            if (snap != nil) {
//                animator.removeBehavior(snap)
//            }
//            if (CGRectIntersectsRect(circleView.frame, calendarPicker.frame) == false && circleView.frame.origin.y > view.frame.height-400) {
//                snap = UISnapBehavior(item: circleView, snapToPoint: originalCirclePoint)
//                scheduleText.text = ""
//            }
//                
//            else if (CGRectIntersectsRect(circleView.frame, calendarPicker.frame) == false){
//                snap = UISnapBehavior(item: circleView, snapToPoint: CGPointMake(view.frame.width - circleView.frame.width, circleView.frame.height))
//            }
//                
//            else {
//                snap = UISnapBehavior(item: circleView, snapToPoint: CGPointMake(0 + circleView.frame.width, view.frame.height - circleView.frame.height))
//                scheduleText.text = ""
//            }
//            snap.damping = 0.8
//            animator.addBehavior(snap)
//            
//        }
//        
//        
//    }
//    
//    
//    func showImagePickerForSourceType(sourceType: UIImagePickerControllerSourceType){
//        
//        
//        
//        imagePickerController.modalPresentationStyle = UIModalPresentationStyle.CurrentContext
//        imagePickerController.sourceType = sourceType
//        imagePickerController.delegate = self
//        
//        
//        if (sourceType == UIImagePickerControllerSourceType.Camera){
//            
//            //            let imagePickerControllerFrame = CGRectMake(0, self.view.frame.width, self.view.frame.width, self.view.frame.height-self.view.frame.width)
//            //            let imageView = imagePickerController.view
//            //            imageView.frame = imagePickerControllerFrame;
//            //    view.addSubview(imageView)
//            
//            imagePickerController.showsCameraControls = false
//            NSBundle.mainBundle().loadNibNamed("OverlayView", owner: self, options: nil)
//            self.overlayView.frame = CGRectMake(0, imagePickerController.cameraOverlayView!.frame.width, imagePickerController.cameraOverlayView!.frame.width, imagePickerController.cameraOverlayView!.frame.height-self.view.frame.width)
//            
//            imagePickerController.cameraOverlayView = self.overlayView
//            self.overlayView = nil
//            
//            
//            
//            //imagePickerController.view = handlePan.view
//            
//            
//            
//            
//            
//            
//            
//            
//            //
//            //            let overlayView = UIView(frame: CGRectMake(0, self.view.frame.width, self.view.frame.width, self.view.frame.height-self.view.frame.width))
//            //            overlayView.backgroundColor = UIColor.whiteColor()
//            //            overlayView.userInteractionEnabled = true
//            //            overlayView.alpha = 1.0 // tried this to make sure subview wasn't hiding behind
//            //            println(overlayView)
//            //
//            
//            //            let snapButton = UIButton(frame: CGRectMake(self.view.frame.width/2-22, self.view.frame.height-200, 44, 44))
//            //            snapButton.addTarget(self, action: Selector("snapPhoto:"), forControlEvents:UIControlEvents.TouchUpInside)
//            //            snapButton.backgroundColor = UIColor.blackColor()
//            //            snapButton.setTitle("Snap", forState: UIControlState.Normal)
//            //            overlayView.addSubview(snapButton)
//            
//            //            let snapButton = UIButton(frame: CGRectMake(self.view.frame.width/2-22, self.view.frame.height-200, 44, 44))
//            //            snapButton.layer.cornerRadius = 22
//            //            snapButton.userInteractionEnabled = true
//            //            snapButton.backgroundColor = UIColor.blackColor()
//            
//            
//            
//        }
//        self.presentViewController(self.imagePickerController, animated: true, completion: nil)
//        
//        
//        
//    }
//    
//    func takePicture(){
//        self.imagePickerController.takePicture()
//        self.imageView.layer.cornerRadius = self.circleRadius
//        self.imageView.clipsToBounds = true
//        //circleView.alpha = 0.0
//        
//        UIView.animateWithDuration(0.15, animations: { () -> Void in
//            self.imageView.alpha = 1.0
//            self.imageView.center = self.circleView.center
//            self.imageView.frame.size = self.circleView.frame.size
//            
//            }, completion:nil)
//        didTakePicture = true
//    }
//    
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        
//        
//        // Do any additional setup after loading the view, typically from a nib.
//        
//        circleView = UIImageView(frame: CGRect(x: self.view.frame.width/2-circleRadius, y: self.view.frame.height-180, width: circleRadius*2, height: circleRadius*2))
//        circleView.clipsToBounds = true
//        circleView.image = UIImage(named: "snapbutton.png")
//        circleView.layer.cornerRadius = circleRadius
//        circleView.userInteractionEnabled = true
//        circleView.layer.zPosition = 10
//        originalCirclePoint = circleView.center
//        view.addSubview(circleView)
//        
//        scheduleText = UILabel(frame: CGRect(x: 10, y: 40, width: 100, height: 40))
//        view.addSubview(scheduleText)
//        
//        calendarPicker = UIView(frame: CGRect(x:0, y:view.frame.height-60, width:self.view.frame.width, height:60))
//        calendarPicker.backgroundColor = UIColor.blackColor()
//        calendarPicker.alpha = 0.8
//        
//        calendarPickerLabel = UILabel(frame: CGRect(x:self.view.frame.width/2, y:12, width:0, height:0))
//        calendarPickerLabel.font = UIFont(name: "ArialRoundedMTBold", size: 18.0)
//        calendarPickerLabel.text = "Calendar"
//        calendarPickerLabel.textColor = UIColor.whiteColor()
//        println(calendarPickerLabel.center)
//        calendarPickerLabel.sizeToFit()
//        calendarPickerLabel.center.x = calendarPicker.center.x
//        
//        
//        
//        view.addSubview(calendarPicker)
//        calendarPicker.addSubview(calendarPickerLabel)
//        
//        
//        animator = UIDynamicAnimator(referenceView: view)
//        
//        //  [[[[UIApplication sharedApplication] delegate] window] addSubview:controllerView];
//        
//        let imagePickerControllerFrame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.width)
//        imageView = imagePickerController.view
//        imageView.frame = imagePickerControllerFrame;
//        
//        view.addSubview(imageView)
//        self.showImagePickerForSourceType(UIImagePickerControllerSourceType.Camera)
//    }
//    
//    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
//        //   let image = info(valueForKeyPath(UIImagePickerControllerOriginalImage))
//        let tempImage = info[UIImagePickerControllerOriginalImage] as UIImage
//        UIImageWriteToSavedPhotosAlbum(tempImage, nil, nil, nil);
//        
//        circleView.image = tempImage
//        circleView.alpha = 1.0
//        imageView.removeFromSuperview()
//        
//    }
//    
//    
//    
//    func updateScheduleText(){
//        
//        
//        
//        if circleView.frame.origin.y > view.frame.height-300 {
//            
//            
//            
//            //            var transform = CGAffineTransformMakeTranslation(0, 500)
//            //            transform = CGAffineTransformScale(transform, 0.1, 0.1)
//            //            imageView.transform = CGAffineTransformMakeScale(0.5, 0.5)
//            
//            
//        }
//            
//        else if circleView.frame.origin.y > view.frame.height - 400 {
//            scheduleText.text = "Tomorrow"
//        }
//        else if circleView.frame.origin.y > view.frame.height - 500 {
//            scheduleText.text = "Next Week"
//        }
//        else if circleView.frame.origin.y > view.frame.height - 600 {
//            scheduleText.text = "Next Month"
//        }
//        else {
//            scheduleText.text = "In a year"
//        }
//        
//        
//        scheduleText.font = UIFont(name: "ArialRoundedMTBold", size: 40.0)
//        scheduleText.textColor = UIColor.blackColor()
//        scheduleText.sizeToFit()
//        
//    }
//    
//    func shrinkCalendarPicker(){
//        
//        var newFrame = calendarPicker.frame
//        newFrame.origin.y = view.frame.height-60
//        calendarPicker.frame = newFrame
//        
//        
//        calendarPickerLabel.text = "Calendar"
//        calendarPickerLabel.sizeToFit()
//        calendarPickerLabel.textAlignment = NSTextAlignment.Center
//        calendarPickerLabel.center.x = calendarPicker.center.x
//        
//        
//    }
//    
//    
//    func growCalendarPicker(){
//        println("growing")
//        var newFrame = CGRect(x:0, y:view.frame.height-200, width:self.view.frame.width, height:200)
//        calendarPicker.frame = newFrame
//        
//        calendarPickerLabel.text = "Release to Pick Date"
//        calendarPickerLabel.sizeToFit()
//        calendarPickerLabel.textAlignment = NSTextAlignment.Center
//        calendarPickerLabel.center.x = calendarPicker.center.x
//        
//        
//    }
//    
//    
//    
//    
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//    
//    
//}
//
