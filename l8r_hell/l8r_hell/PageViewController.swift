import Foundation
import UIKit

class PageViewController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    var index = 1
    var identifiers: NSArray = ["InboxViewController", "CameraViewController"]
    override func viewDidLoad() {
        
        
        println("view loaded")
        self.delegate = self
        self.dataSource = self

        
        let startingViewController = self.viewControllerAtIndex(self.index)
        let viewControllers: NSArray = [startingViewController]
        self.setViewControllers(viewControllers, direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)
        
        
        
        // Change the size of page view controller
        self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 30);
        
        self.didMoveToParentViewController(self)

        
        
    }
    
    func turnPage(){
        let startingViewController = self.viewControllerAtIndex(0)
        let viewControllers: NSArray = [startingViewController]
        self.setViewControllers(viewControllers, direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)
    }
    
    func viewControllerAtIndex(index: Int) -> UIViewController! {
        println("a")
        
        //first view controller = firstViewControllers navigation controller
        if index == 0 {
            
            return self.storyboard!.instantiateViewControllerWithIdentifier("InboxViewController") as UIViewController
            
        }
        
        //second view controller = secondViewController's navigation controller
        if index == 1 {
            
            return self.storyboard!.instantiateViewControllerWithIdentifier("CameraViewController") as UIViewController
        }
        
        return nil
    }
        func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
            println("b")
        
        let identifier = viewController.restorationIdentifier
        let index = self.identifiers.indexOfObject(identifier!)
        
        //if the index is the end of the array, return nil since we dont want a view controller after the last one
        if index == identifiers.count - 1 {
            
            return nil
        }
        
        //increment the index to get the viewController after the current index
        self.index = self.index + 1
        return self.viewControllerAtIndex(self.index)
        
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        println("c")
        let identifier = viewController.restorationIdentifier
        let index = self.identifiers.indexOfObject(identifier!)
        
        //if the index is 0, return nil since we dont want a view controller before the first one
        if index == 0 {
            
            return nil
        }
        
        //decrement the index to get the viewController before the current one
        self.index = self.index - 1
        return self.viewControllerAtIndex(self.index)
        
    }
    
    
//    func presentationCountForPageViewController(pageViewController: UIPageViewController!) -> Int {
//        return self.identifiers.count
//    }
//    
//    func presentationIndexForPageViewController(pageViewController: UIPageViewController!) -> Int {
//        return 0
//}
}
