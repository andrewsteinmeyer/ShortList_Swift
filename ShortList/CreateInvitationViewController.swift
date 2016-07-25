//
//  CreateInvitationViewController.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 7/18/16.
//  Copyright © 2016 Andrew Steinmeyer. All rights reserved.
//

import UIKit

class CreateInvitationViewController: UIViewController {
  
  @IBOutlet weak var invitationProgressView: InvitationProgressView!
  @IBOutlet weak var containerView: UIView!
  
  weak var currentViewController: UIViewController?
  
  enum ButtonType: Int {
    case Settings
    case Details
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // set this controller as the delegate
    invitationProgressView.delegate = self
    
    populateContainerView()
  }
  
  func populateContainerView() {
    self.currentViewController = self.storyboard?.instantiateViewControllerWithIdentifier("InvitationSettingsViewController")
    self.currentViewController!.view.translatesAutoresizingMaskIntoConstraints = false
    self.addChildViewController(self.currentViewController!)
    self.addSubview(self.currentViewController!.view, toView: self.containerView)
  }
  
  func addSubview(subView:UIView, toView parentView:UIView) {
    parentView.addSubview(subView)
    
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
    UIView.animateWithDuration(0.3, animations: {
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
        let newViewController = self.storyboard?.instantiateViewControllerWithIdentifier("InvitationSettingsViewController")
        newViewController!.view.translatesAutoresizingMaskIntoConstraints = false
        self.cycleFromViewController(self.currentViewController!, toViewController: newViewController!)
        self.currentViewController = newViewController
      case .Details:
        let newViewController = self.storyboard?.instantiateViewControllerWithIdentifier("InvitationDetailsViewController")
        newViewController!.view.translatesAutoresizingMaskIntoConstraints = false
        self.cycleFromViewController(self.currentViewController!, toViewController: newViewController!)
        self.currentViewController = newViewController
      }
    }
  }
}


