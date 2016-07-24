//
//  CreateInvitationViewController.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 7/18/16.
//  Copyright © 2016 Andrew Steinmeyer. All rights reserved.
//

import UIKit

class CreateInvitationViewController: UIViewController {
  
  @IBOutlet weak var containerView: UIView!
  
  weak var currentViewController: UIViewController?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
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
    
}


