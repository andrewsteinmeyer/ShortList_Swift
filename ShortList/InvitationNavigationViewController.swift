//
//  InvitationNavigationViewController.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 1/28/16.
//  Copyright © 2016 Andrew Steinmeyer. All rights reserved.
//

import UIKit

class InvitationNavigationViewController: UINavigationController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.navigationBarHidden = true
  }
  
  override func prefersStatusBarHidden() -> Bool {
    return true
  }
  
  override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
    return .None
  }
  
  
}