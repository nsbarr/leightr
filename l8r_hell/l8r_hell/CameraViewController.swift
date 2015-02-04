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
    var isSavingPictures = true
    
    var calendarPickerLabel:UILabel!
    var calendarPicker:UIView!
    var okButton: UIButton!
    
    var scheduledDate: NSDate!
    
    var backgroundImageView: UIImageView!
    
    var timeComponent = NSDateComponents()
    
    var tempImage:UIImage!

    var pointInView:CGPoint!


    
    @IBOutlet var handlePan: UIPanGestureRecognizer!
    @IBOutlet var handleTap: UITapGestureRecognizer!
    
    
    
    override func viewDidLoad() {
        println(self.parentViewController)
        super.viewDidLoad()
        animator = UIDynamicAnimator(referenceView: view)
        
        self.showImagePickerForSourceType(UIImagePickerControllerSourceType.Camera)
        self.resetCameraViewAndMenu()
        
        self.setUpCalendar()
        self.addGestureRecognizerToOverlayView()
        
        setupNotificationSettings()
        
        
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
            backgroundImageView.center = CGPointMake(backgroundImageView.center.x, backgroundImageView.center.y - translation.y*2.7)
            sender.setTranslation(CGPointMake(0,0), inView: view)
            if didTakePicture{
                self.imageView.center = self.circleView.center
            }
            else {
                self.takePicture()
            }
            self.updateScheduleText()
            if ((circleView.frame.origin.y > 460 || circleView.frame.origin.y < 380) && !didTakePicture){
                
                println("takingPicture")
           //     self.takePicture()
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
                okButton.addTarget(self, action: Selector("dismissCalendar:"), forControlEvents:UIControlEvents.TouchUpInside)
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
                self.animateScheduleText()
                
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
    
    func addGestureRecognizerToOverlayView(){
        let swipeUp = UITapGestureRecognizer(target: self, action: Selector("takePictureTwo:"))
        
        var overlayView = UIView(frame:self.view.frame)
        overlayView.alpha = 0.1
        overlayView.backgroundColor = UIColor.clearColor()
        overlayView.userInteractionEnabled = true
        overlayView.addGestureRecognizer(swipeUp)
        imagePickerController.cameraOverlayView = overlayView
        
    }
    

    
    func animateImageViewWithCenter(center: CGPoint){
        //  imagePickerController.view.layer.cornerRadius = 30
        //   self.imagePickerController.view.clipsToBounds = true
        
        UIView.animateWithDuration(1, animations: { () -> Void in
            self.imageView.frame.size = CGSizeMake(40, 40)
            self.imageView.center = center
            
            }, completion:nil)
        
        println(self.view)
        // println(self.imagePickerController)
        // println(imagePickerController.view)
        //  println(imagePickerController.view.subviews)
        
    }

    
    func dismissCalendar(sender: UIButton){
        println("scheduling")
        if (snap != nil) {
            animator.removeBehavior(snap)
        }
        
        self.shrinkCalendarPicker()
        
        self.schedulePhoto()
        
        self.resetCameraViewAndMenu()
        
    }
    
    func updateScheduleText(){
        
        if circleView.frame.origin.y < 81 {
            scheduleText.text = "Someday"
        }
        else if circleView.frame.origin.y < 160 {
            scheduleText.text = "In a year"
        }
        else if circleView.frame.origin.y < 220 {
            scheduleText.text = "Next Month"
        }
        else if circleView.frame.origin.y < 300 {
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


    
    func resetCameraViewAndMenu(){
        
        
        self.didTakePicture = false
        
        if (circleView? != nil){
            circleView.removeFromSuperview()
        }
        
        if (imageView? != nil){
            imageView.removeFromSuperview()
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
        
        if (backgroundImageView? != nil){
            backgroundImageView.removeFromSuperview()
        }
        
        if (inboxButton? != nil){
            inboxButton.removeFromSuperview()
        }
        
        if (libraryButton? != nil) {
            libraryButton.removeFromSuperview()
        }
        
        let imagePickerControllerFrame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height+20)
        imagePickerController.view.frame = imagePickerControllerFrame;

                let translate = CGAffineTransformMakeTranslation(0, 83.0)
                self.imagePickerController.cameraViewTransform = translate
        
                let scale = CGAffineTransformScale(translate, 1.333333, 1.333333)
              //  let scale = CGAffineTransformMakeScale(1.3, 1.3)
                self.imagePickerController.cameraViewTransform = scale
        imageView = imagePickerController.view
        imageView.layer.cornerRadius = 0
        self.view.addSubview(imageView)
        
        inboxButton = UIButton(frame: CGRectMake(20,self.view.frame.height-60, 30, 30))
        inboxButton.addTarget(self, action: Selector("swipeView:"), forControlEvents:UIControlEvents.TouchUpInside)
        let inboxButtonImage = UIImage(named: "inboxButtonImage")
        inboxButton.setImage(inboxButtonImage, forState: .Normal)
        inboxButton.alpha = 1
        view.addSubview(inboxButton)
        
        libraryButton = UIButton(frame: CGRectMake(self.view.frame.width-70,self.view.frame.height-60, 30, 30))
        inboxButton.addTarget(self, action: Selector("swipeView:"), forControlEvents:UIControlEvents.TouchUpInside)
        let libraryButtomImage = UIImage(named: "libraryButtonImage")
        libraryButton.setImage(libraryButtomImage, forState: .Normal)
        libraryButton.alpha = 1
        view.addSubview(libraryButton)
        
        scheduleText = UILabel(frame: CGRect(x: 10, y: 40, width: 100, height: 40))
        scheduleText.alpha = 1
        scheduleText.font = UIFont(name: "ArialRoundedMTBold", size: 40.0)
        scheduleText.textColor = UIColor.blackColor()
        view.addSubview(scheduleText)
        
        circleView = UIImageView(frame: CGRect(x: self.view.frame.width/2-circleRadius, y: self.view.frame.height-210, width: circleRadius*2, height: circleRadius*2))
        circleView.clipsToBounds = true
        circleView.image = UIImage(named: "snapbuttonvector")
        circleView.layer.cornerRadius = circleRadius
        circleView.userInteractionEnabled = true
        circleView.layer.zPosition = 10
        circleView.alpha = 1
        originalCirclePoint = circleView.center
        view.addSubview(circleView)
        
        backgroundImageView = UIImageView(frame: CGRectMake(0,667-1836,375,1836))
        backgroundImageView.image = UIImage(named: "whiteBackgroundImage")
        backgroundImageView.alpha = 0
        self.view.addSubview(backgroundImageView)

        

        
    }
    
    func showImagePickerForSourceType(sourceType: UIImagePickerControllerSourceType){
        
        imagePickerController.modalPresentationStyle = UIModalPresentationStyle.CurrentContext
        imagePickerController.sourceType = sourceType
        imagePickerController.delegate = self
        
        if (sourceType == UIImagePickerControllerSourceType.Camera){
            
            imagePickerController.showsCameraControls = false
            imagePickerController.cameraFlashMode = UIImagePickerControllerCameraFlashMode.Off
            
            
            println(imagePickerController.view)
            
            println(imagePickerController.view.superview)
            
            
        }
        self.presentViewController(self.imagePickerController, animated: true, completion: nil)
        
        
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        //   let image = info(valueForKeyPath(UIImagePickerControllerOriginalImage))
        tempImage = info[UIImagePickerControllerOriginalImage] as UIImage
        

        
        
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
        

        backgroundImageView.alpha = 1
        view.bringSubviewToFront(scheduleText)
        println(view.frame)
        
        
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            
            self.imageView.frame.size = self.circleView.frame.size
            self.imageView.center = self.circleView.center
            
            }, completion:nil)
        didTakePicture = true
        
        
        view.addSubview(calendarPicker)
        calendarPicker.addSubview(calendarPickerLabel)
        
        libraryButton.alpha = 0
        inboxButton.alpha = 0
    }
    
    func takePictureTwo(sender: UITapGestureRecognizer){
        self.imagePickerController.takePicture()
        

        pointInView = sender.locationInView(sender.view)
        
        
        self.imageView.layer.cornerRadius = self.circleRadius
        self.imageView.clipsToBounds = true
        self.view.bringSubviewToFront(self.imageView)
        self.view.sendSubviewToBack(self.circleView)
        println(self.view.subviews)
        // self.imageView.opaque = true
        // self.imageView.alpha = 1
        // self.circleView.alpha = 0
        //    circleView.alpha = 0.0
        
        
        backgroundImageView.alpha = 1
        view.bringSubviewToFront(scheduleText)
        println(view.frame)
        
        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            
            self.imageView.frame.size = self.circleView.frame.size
           self.imageView.center = self.circleView.center
        //    self.imageView.center = self.pointInView
            
            }, completion:nil)
        didTakePicture = true

        
        view.addSubview(calendarPicker)
        calendarPicker.addSubview(calendarPickerLabel)
        
        libraryButton.alpha = 0
        inboxButton.alpha = 0
    }

    
    func savePicture(){
        let imageData = UIImageJPEGRepresentation(tempImage, 1.0)
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
        let imagePath = paths.stringByAppendingPathComponent("cached.png")
        
        println(imagePath)
        if !imageData.writeToFile(imagePath, atomically: false){
            println("not saved")
        }
        else {
            println("saved")
            NSUserDefaults.standardUserDefaults().setObject(imagePath, forKey: "imagePath")
        }
        
        if isSavingPictures {
            UIImageWriteToSavedPhotosAlbum(tempImage, nil, nil, nil);
        }
    }
    
    func setFireDate(){
        
        timeComponent = NSDateComponents()
        
        if scheduleText.text == "Someday" {
            timeComponent.second = 10
        }
        else if scheduleText.text == "In a year" {
            timeComponent.year = 1
        }
        else if scheduleText.text == "Next Month" {
            timeComponent.month = 1
        }
        else if scheduleText.text == "Next Week" {
            timeComponent.day = 7
        }
        else if scheduleText.text == "Tomorrow" {
            timeComponent.day = 1
        }
        else {
            println("no schedule text?")
        }
        println(timeComponent)
        
        
    }
    
    func schedulePhoto(){
        
        self.savePicture()
        self.setFireDate()
        self.scheduleLocalNotification()
        
        
    }
    
    func animateScheduleText(){
        
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
                
                self.schedulePhoto()
                self.resetCameraViewAndMenu()
                
                
        })
        
        
    }
    
 
    
    func setupNotificationSettings() {
        
        let notificationSettings: UIUserNotificationSettings! = UIApplication.sharedApplication().currentUserNotificationSettings()
        
        if (notificationSettings.types == UIUserNotificationType.None){

            var notificationTypes: UIUserNotificationType = UIUserNotificationType.Alert | UIUserNotificationType.Sound
            
            var ignoreAction = UIMutableUserNotificationAction()
            ignoreAction.identifier = "ignore"
            ignoreAction.title = "Ignore"
            ignoreAction.activationMode = UIUserNotificationActivationMode.Background
            ignoreAction.destructive = false
            ignoreAction.authenticationRequired = false
            
            var modifyListAction = UIMutableUserNotificationAction()
            modifyListAction.identifier = "view"
            modifyListAction.title = "View"
            modifyListAction.activationMode = UIUserNotificationActivationMode.Foreground
            modifyListAction.destructive = false
            modifyListAction.authenticationRequired = true
            
            let actionsArray = NSArray(objects: ignoreAction, modifyListAction)
            let actionsArrayMinimal = NSArray(objects: ignoreAction, modifyListAction)
            
            var shoppingListReminderCategory = UIMutableUserNotificationCategory()
            shoppingListReminderCategory.identifier = "shoppingListReminderCategory"
            shoppingListReminderCategory.setActions(actionsArray, forContext: UIUserNotificationActionContext.Default)
            shoppingListReminderCategory.setActions(actionsArrayMinimal, forContext: UIUserNotificationActionContext.Minimal)
        

        //   convenience init(forTypes allowedUserNotificationTypes: UIUserNotificationType, categories actionSettings: NSSet?)
        
        
            let categoriesForSettings = NSSet(objects: shoppingListReminderCategory)
        
        
            let newNotificationSettings = UIUserNotificationSettings(forTypes: notificationTypes, categories: categoriesForSettings)
        
            UIApplication.sharedApplication().registerUserNotificationSettings(newNotificationSettings)
        }
    }
    
    func scheduleLocalNotification() {
        
        var currentTime = NSDate()
        var theCalendar = NSCalendar.currentCalendar()
        var scheduledDate = theCalendar.dateByAddingComponents(timeComponent, toDate: currentTime, options: NSCalendarOptions(0))
        
        var localNotification = UILocalNotification()
        localNotification.fireDate = scheduledDate
        localNotification.repeatInterval = NSCalendarUnit.YearCalendarUnit //this is just an evil way to not expire the notification
        localNotification.alertBody = "Your l8r is now"
        localNotification.alertAction = "View"
        localNotification.category = "shoppingListReminderCategory"
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
            
    }


    
    func swipeView(sender: UIButton){
        let pvc = self.storyboard!.instantiateViewControllerWithIdentifier("PageViewController") as PageViewController
        let ivc = self.storyboard!.instantiateViewControllerWithIdentifier("InboxViewController") as InboxViewController
       //   ivc.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
       // pvc.setViewControllers([ivc], direction: UIPageViewControllerNavigationDirection.Reverse, animated: true, completion: nil)
       self.presentViewController(ivc, animated: true, completion: nil)
        
    }
}