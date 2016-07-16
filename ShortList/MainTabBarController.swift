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
  
  // extra view controller that will not have a traditional tab item
  // the user will access these controllers from the right side menu
  // the foreignController is used to load the selected controller
  // into the tab bar controller view
  var foreignController: UIViewController! {
    willSet {
      if newValue != nil {
        let reducedHeight = newValue.view.frame.size.height - self.tabBar.frame.size.height
        newValue.view.frame = CGRectMake(0.0, 0.0, self.view.bounds.width, reducedHeight);
        
        self.view.addSubview(newValue.view)
      } else {
        foreignController.view.removeFromSuperview()
      }
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // make controller the delegate of itself
    self.delegate = self
    
    // set tab bar color and font
    self.tabBar.tintColor = Theme.TabBarButtonTintColor.toUIColor()
    self.tabBarItem.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Lato-Regular", size: 5)!], forState: .Normal)
    
    // add pan gesture for right menu bar
    self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
    
    // register observers
    addObservers()
  }
  
  deinit {
    // remove observers
    removeObservers()
  }
  
  // present right menu bar
  private func moreTabItemSelected() {
    guard self.revealViewController() != nil else { return }
    
    // toggle right menu bar
    self.revealViewController().rightRevealToggle(self)
  }
  
  // present scanViewController when scan tabBarItem is tapped
  private func scanTabItemSelected() {
    let storyboard = UIStoryboard(name: "Scan", bundle: nil)
    
    let scanViewController = storyboard.instantiateViewControllerWithIdentifier("ScanViewController") as! ScanViewController
    
    scanViewController.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
    scanViewController.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
    self.presentViewController(scanViewController, animated: false, completion: nil)
  }
  
  func profileRowPressed() {
    // add profile view controller
    let storyboard = UIStoryboard(name: "Profile", bundle: nil)
    
    // load profile controller
    let profileTableViewController = storyboard.instantiateViewControllerWithIdentifier("ProfileTableViewController") as! ProfileTableViewController
    let profileNavigationVC = ProfileNavigationViewController(rootViewController: profileTableViewController)
    
    // set profile controller as the foreign controller
    // this controller will be loaded in the tabBarControllerView
    foreignController = profileNavigationVC
    
    // close the right side view menu
    self.revealViewController().rightRevealToggleAnimated(true)
  }
  
  func venuesRowPressed() {
    // add venues view controller
    let storyboard = UIStoryboard(name: "Venues", bundle: nil)
    
    // load venues controller
    let venuesViewController = storyboard.instantiateViewControllerWithIdentifier("VenuesViewController") as! VenuesViewController
    let venuesNavigationVC = VenuesNavigationViewController(rootViewController: venuesViewController)
    
    // set venues controller as the foreign controller
    // this controller will be loaded in the tabBarControllerView
    foreignController = venuesNavigationVC
    
    // close the right side view menu
    self.revealViewController().rightRevealToggleAnimated(true)
  }
  
  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return UIStatusBarStyle.LightContent
  }
  
  override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
    return .Fade
  }
  
  override func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
    guard foreignController != nil else { return }
    
    // clear out foreign controller when a regular tab bar item is selected
    foreignController = nil
  }
  
  // MARK: Notification observers
  
  private func addObservers() {
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MainTabBarController.profileRowPressed), name: Constants.MenuNotification.ProfileRowPressed, object: nil)
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MainTabBarController.venuesRowPressed), name: Constants.MenuNotification.VenuesRowPressed, object: nil)
  }
  
  private func removeObservers() {
    NSNotificationCenter.defaultCenter().removeObserver(self, name: Constants.MenuNotification.ProfileRowPressed, object: self)
  }
  
}

extension MainTabBarController: UITabBarControllerDelegate {
  
  func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
    switch viewController {
    case is ScanViewController:
      scanTabItemSelected()
      return false
    case is MoreViewController:
      moreTabItemSelected()
      return false
    default:
      return true
    }
  }
}

