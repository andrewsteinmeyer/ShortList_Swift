//
//  ExSlideMenuController.swift
//  SlideMenuControllerSwift
//
//  Created by Andrew Steinmeyer on 12/14/15.
//  Copyright © 2015 Andrew Steinmeyer. All rights reserved.
//

import UIKit

class ExSlideMenuController : SlideMenuController {

  override func isTagetViewController() -> Bool {
    if let vc = UIApplication.topViewController() {
      if vc is HomeViewController ||
        vc is ListsViewController {
          return true
      }
    }
    return false
  }
}
