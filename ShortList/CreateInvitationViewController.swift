//
//  CreateInvitationViewController.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 7/18/16.
//  Copyright © 2016 Andrew Steinmeyer. All rights reserved.
//

import UIKit
import CoreData

class CreateInvitationViewController: UIViewController {
  
  @IBOutlet weak var invitationProgressView: InvitationProgressView!
  @IBOutlet weak var containerView: UIView!
  
  // controller being displayed in the containerView
  weak var currentViewController: InvitationViewController?
  var settingsViewController: InvitationSettingsViewController!
  var detailsViewController: InvitationDetailsViewController!
  
  var eventDetails: EventDetails!
  
  enum ButtonType: Int {
    case Settings
    case Details
    
    private var AssociatedViewControllerName: String {
      switch self {
      case .Settings: return "InvitationSettingsViewController"
      case .Details:  return "InvitationDetailsViewController"
      }
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // initialize event details
    self.eventDetails = EventDetails()
    
    settingsViewController = self.storyboard?.instantiateViewControllerWithIdentifier(ButtonType.Settings.AssociatedViewControllerName) as! InvitationSettingsViewController
    detailsViewController = self.storyboard?.instantiateViewControllerWithIdentifier(ButtonType.Details.AssociatedViewControllerName) as! InvitationDetailsViewController
    
    // set this controller as the delegate
    invitationProgressView.delegate = self
    
    populateContainerView()
  }
  
  func populateContainerView() {
    self.currentViewController = settingsViewController
    self.currentViewController?.eventDetails = self.eventDetails
    self.currentViewController?.view.translatesAutoresizingMaskIntoConstraints = false
    self.addChildViewController(self.currentViewController!)
    self.addSubview(self.currentViewController!.view, toView: self.containerView)
  }
  
  func addSubview(subView:UIView, toView parentView:UIView) {
    parentView.addSubview(subView)
    
    // set view constraints
    subView.leadingAnchor.constraintEqualToAnchor(parentView.leadingAnchor).active = true
    subView.trailingAnchor.constraintEqualToAnchor(parentView.trailingAnchor).active = true
    subView.topAnchor.constraintEqualToAnchor(parentView.topAnchor).active = true
    subView.bottomAnchor.constraintEqualToAnchor(parentView.bottomAnchor).active = true
  }
  
  func cycleFromViewController(oldViewController: UIViewController, toViewController newViewController: UIViewController) {
    oldViewController.willMoveToParentViewController(nil)
    self.addChildViewController(newViewController)
    self.addSubview(newViewController.view, toView:self.containerView!)
    newViewController.view.alpha = 0
    newViewController.view.layoutIfNeeded()
    UIView.animateWithDuration(0, animations: {
      newViewController.view.alpha = 1
      oldViewController.view.alpha = 0
      },
           completion: { finished in
            oldViewController.view.removeFromSuperview()
            oldViewController.removeFromParentViewController()
            newViewController.didMoveToParentViewController(self)
    })
  }
  
}

extension CreateInvitationViewController: InvitationProgressViewDelegate {
  
  func invitationProgressViewDidPressButton(buttonType: Int) {
    if let type = ButtonType(rawValue: buttonType) {
      switch type {
      case .Settings:
        let newViewController = settingsViewController
        newViewController.view.translatesAutoresizingMaskIntoConstraints = false
        newViewController.eventDetails = self.eventDetails
        self.cycleFromViewController(self.currentViewController!, toViewController: newViewController)
        self.currentViewController = newViewController
      case .Details:
        let newViewController = detailsViewController
        newViewController.view.translatesAutoresizingMaskIntoConstraints = false
        newViewController.eventDetails = self.eventDetails
        self.cycleFromViewController(self.currentViewController!, toViewController: newViewController)
        self.currentViewController = newViewController
      }
    }
  }
}


