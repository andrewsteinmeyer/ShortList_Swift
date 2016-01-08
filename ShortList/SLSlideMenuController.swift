//
//  SLSlideMenuController.swift
//  SlideMenuControllerSwift
//
//  Created by Andrew Steinmeyer on 12/14/15.
//  Copyright © 2015 Andrew Steinmeyer. All rights reserved.
//

import UIKit

class SLSlideMenuController : SlideMenuController {

  override func isTargetViewController() -> Bool {
    if let vc = UIApplication.topViewController() {
      if vc is HomeViewController ||
        vc is ContactsViewController ||
        vc is ListsViewController ||
        vc is VenuesViewController ||
        vc is EventsViewController {
          return true
      }
    }
    return false
  }
}
