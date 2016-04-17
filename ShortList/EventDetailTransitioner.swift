//
//  EventDetailTransitioner.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 3/28/16
//  Copyright © 2016 Andrew Steinmeyer. All rights reserved.
//

import UIKit

class EventDetailTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
  var selectedObject: SelectionObject?
  
  init(selectedObject: SelectionObject) {
    super.init()
    self.selectedObject = selectedObject
  }
  
  func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController? {
    let presentationController = EventDetailPresentationController(presentedViewController: presented, presentingViewController: presenting)
    presentationController.configureWithSelectionObject(selectedObject!)
    
    return presentationController
  }
  
  func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    let animationController = EventDetailAnimatedTransitioning(selectedObject: selectedObject!, isPresentation: true)
    
    return animationController
  }
  
  func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    let animationController = EventDetailAnimatedTransitioning(selectedObject: selectedObject!, isPresentation: false)
    
    return animationController
  }
}

class EventDetailAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
  var isPresentation: Bool = false
  var selectedObject: SelectionObject?
  
  init(selectedObject: SelectionObject, isPresentation: Bool) {
    self.selectedObject = selectedObject
    self.isPresentation = isPresentation
  }
  
  func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
    return 0.3
  }
  
  func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
    let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)
    let fromView = fromViewController!.view
    let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)
    let toView = toViewController!.view
    
    let containerView: UIView = transitionContext.containerView()!
    
    if isPresentation {
      containerView.addSubview(toView)
    }
    
    let animatingViewController = isPresentation ? toViewController : fromViewController
    let animatingView = animatingViewController!.view
    
    animatingView.frame = transitionContext.finalFrameForViewController(animatingViewController!)
    
    let revealVC = (isPresentation ? fromViewController : toViewController) as! SWRevealViewController
    let eventsNavigationVC = revealVC.frontViewController as! EventsNavigationViewController
    let eventsViewController = eventsNavigationVC.topViewController as! EventsViewController
    
    // hide cell's image view if a dismissal
    // ticket will shrink back down to the area where the cell was displayed
    if !isPresentation {
      eventsViewController.hideImage(true, indexPath: selectedObject!.selectedCellIndexPath)
    }
    
    let delay = isPresentation ? 0.3 : 0.0
    
    UIView.animateWithDuration(transitionDuration(transitionContext),
      delay: delay,
      options: [UIViewAnimationOptions.AllowUserInteraction, UIViewAnimationOptions.BeginFromCurrentState],
      animations: {
        if self.isPresentation {
          let eventNavVC = toViewController as! EventDetailNavigationViewController
          let eventDetailVC = eventNavVC.topViewController as! EventDetailCollectionViewController
          
          // fade in event detail view controller
          eventDetailVC.view.alpha = 1.0
        }
        else {
          // if dismissal, unhide the ticket cell in the collection view
          //eventsViewController.hideImage(false, indexPath: self.selectedObject!.selectedCellIndexPath)
          
          // fade out event detail view controller
          fromView.alpha = 0.0
        }
        
      }, completion: { _ in
        if !self.isPresentation {
          
          // if dismissal, unhide the ticket collection view cell
          eventsViewController.hideImage(false, indexPath: self.selectedObject!.selectedCellIndexPath)
          
          // fade out the fromView
          UIView.animateWithDuration(0.3, animations: {
            //fromView.alpha = 0.0
            }, completion: { _ in
              fromView.removeFromSuperview()
              transitionContext.completeTransition(true)
          })
        } else {
          transitionContext.completeTransition(true)
        }
    })
  }
  
}
