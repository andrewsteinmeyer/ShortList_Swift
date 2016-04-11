//
//  EventDetailPresentationController.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 3/28/16
//  Copyright © 2016 Andrew Steinmeyer. All rights reserved.
//

import UIKit

class EventDetailPresentationController: UIPresentationController {
  
  var dimmingView: UIView = UIView()
  var ticketView: UIView = UIView()
  var selectionObject: SelectionObject?
  var isAnimating = false
  
  override init(presentedViewController: UIViewController, presentingViewController: UIViewController) {
    super.init(presentedViewController: presentedViewController, presentingViewController: presentingViewController)
    
    dimmingView.backgroundColor = UIColor(white: 0.0, alpha: 0.7)
    
    //do not want visible initially
    dimmingView.alpha = 0.0
    
    ticketView.clipsToBounds = true
  }
  
  func configureWithSelectionObject(selectionObject: SelectionObject) {
    self.selectionObject = selectionObject
    
    ticketView = selectionObject.snapshot
    ticketView.frame = selectionObject.originalCellPosition
  }
  
  //allows views under presentedView to be visible
  func adaptivePresentationStyleForPresentationController(controller: UIPresentationController!) -> UIModalPresentationStyle {
    return UIModalPresentationStyle.OverFullScreen
  }
  
  //make sure it fits screen
  override func frameOfPresentedViewInContainerView() -> CGRect {
    var bounds = containerView!.bounds
    bounds.size.width -= Constants.EventDetailCollection.Padding
    bounds.size.height -= Constants.EventDetailCollection.Padding
    
    bounds.origin.x = (containerView!.frame.width / 2) - (bounds.size.width / 2)
    bounds.origin.y = (containerView!.frame.height / 2) - (bounds.size.height / 2)
    
    return bounds
  }
  
  //make sure it maintains bounds after orientation changes
  override func containerViewDidLayoutSubviews() {
    dimmingView.frame = containerView!.bounds
  }
  
  func scaleAndPositionTicket() {
    var ticketFrame = ticketView.frame
    
    let ratio = ticketFrame.size.width / ticketFrame.size.height
    
    ticketFrame.size.width = containerView!.frame.size.width - Constants.EventDetailCollection.Padding
    ticketFrame.size.height = ticketFrame.size.width / ratio
    
    let offset = Constants.EventDetailCollection.Padding / 2
    
    ticketFrame.origin.x = offset
    ticketFrame.origin.y = offset
    
    ticketView.frame = ticketFrame
  }
  
  func moveTicketToPresentedPosition(presentedPosition: Bool) {
    
    if presentedPosition {
      // Expand ticket and move to header view position
      // show dimming background
      self.dimmingView.alpha = 1.0
      scaleAndPositionTicket()
    } else {
      // Move ticket back to original position
      // hide dimming background
      self.dimmingView.alpha = 0.0
      var ticketFrame = ticketView.frame
      ticketFrame = selectionObject!.originalCellPosition
      ticketView.frame = ticketFrame
    }
  }
  
  func animateTicketWithBounceToPresentedPosition(presentedPosition: Bool) {
    UIView.animateWithDuration(0.5,
      delay: 0.1,
      usingSpringWithDamping: 300.0,
      initialSpringVelocity: 8.0,
      options: UIViewAnimationOptions.CurveLinear,
      animations: {
        self.moveTicketToPresentedPosition(presentedPosition)
      }, completion: { _ in
        self.isAnimating = false
    })
  }
  
  override func presentationTransitionWillBegin() {
    super.presentationTransitionWillBegin()
    
    dimmingView.frame = self.containerView!.bounds
    dimmingView.alpha = 0.0
    
    isAnimating = true
    moveTicketToPresentedPosition(false)
    
    dimmingView.addSubview(ticketView)
    containerView!.addSubview(dimmingView)
    
    animateTicketWithBounceToPresentedPosition(true)
  }
  
  override func dismissalTransitionWillBegin() {
    super.dismissalTransitionWillBegin()
    
    isAnimating = true
    animateTicketWithBounceToPresentedPosition(false)
  }
  
  
}
