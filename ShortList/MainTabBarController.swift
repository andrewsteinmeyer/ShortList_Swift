//
//  MainTabBarController.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 7/14/16.
//  Copyright © 2016 Andrew Steinmeyer. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {
  
  private enum TabBarItem: Int {
    case Events = 0
    case Lists
    case Scan
    case More
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // make controller the delegate of itself
    self.delegate = self
    
    // set tab bar color and font
    self.tabBar.tintColor = Theme.TabBarButtonTintColor.toUIColor()
    self.tabBarItem.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Lato-Regular", size: 5)!], forState: .Normal)
    
  }
  
  // present scanViewController when scan tabBarItem is tapped
  private func scanTabItemSelected() {
    let storyboard = UIStoryboard(name: "Scan", bundle: nil)
    
    let scanViewController = storyboard.instantiateViewControllerWithIdentifier("ScanViewController") as! ScanViewController
    
    scanViewController.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
    scanViewController.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
    self.presentViewController(scanViewController, animated: false, completion: nil)
  }
  
  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return UIStatusBarStyle.LightContent
  }
  
  override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
    return .Fade
  }
  
  
}

extension MainTabBarController: UITabBarControllerDelegate {
  
  func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
    switch viewController {
    case is ScanViewController:
      scanTabItemSelected()
      return false
    default:
      return true
    }
  }
}

