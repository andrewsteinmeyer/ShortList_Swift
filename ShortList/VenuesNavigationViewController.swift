//
//  VenuesNavigationViewController.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 12/24/15.
//  Copyright © 2015 Andrew Steinmeyer. All rights reserved.
//

import UIKit

class VenuesNavigationViewController: UINavigationController {

  override func viewDidLoad() {
    super.viewDidLoad()
    
    let textColor = Theme.NavigationBarTintColor.toUIColor()
    self.navigationBar.titleTextAttributes =   ([NSFontAttributeName: UIFont(name: "Lato", size: 23)!, NSForegroundColorAttributeName: textColor])
  }
  
  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return .LightContent
  }

}
