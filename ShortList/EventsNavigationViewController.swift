//
//  EventsNavigationViewController.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 1/4/15.
//  Copyright © 2015 Andrew Steinmeyer. All rights reserved.
//

import UIKit

class EventsNavigationViewController: UINavigationController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let textColor = Theme.NavigationBarTintColor.toUIColor()
    self.navigationBar.titleTextAttributes =   ([NSFontAttributeName: UIFont(name: "Lato", size: 23)!, NSForegroundColorAttributeName: textColor])
  }
  
  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return .LightContent
  }

}
