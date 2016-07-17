//
//  NotificationsNavigationViewController.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 7/16/16.
//  Copyright © 2016 Andrew Steinmeyer. All rights reserved.
//

import UIKit

class NotificationsNavigationViewController: UINavigationController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let textColor = Theme.NavigationBarTintColor.toUIColor()
    self.navigationBar.titleTextAttributes =   ([NSFontAttributeName: UIFont(name: "Lato", size: 23)!, NSForegroundColorAttributeName: textColor])
  }
  
  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return .LightContent
  }
  
}