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
    didSet {
      if foreignController != nil {
        let reducedHeight = foreignController.view.frame.size.height - self.tabBar.frame.size.height
        foreignController.view.frame = CGRectMake(0.0, 0.0, self.view.bounds.width, reducedHeight);
        
        self.addChildViewController(foreignController)
        self.view.addSubview(foreignController.view)
        foreignController.didMoveToParentViewController(self)
      } else {
        oldValue.willMoveToParentViewController(nil)
        oldValue.view.removeFromSuperview()
        oldValue.removeFromParentViewController()
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
  
  func contactsRowPressed() {
    // add contacts view controller
    let storyboard = UIStoryboard(name: "Contacts", bundle: nil)
    
    // load contacts controller
    let contactsViewController = storyboard.instantiateViewControllerWithIdentifier("ContactsViewController") as! ContactsViewController
    let contactsNavigationVC = ContactsNavigationViewController(rootViewController: contactsViewController)
    
    // set contacts controller as the foreign controller
    // this controller will be loaded in the tabBarControllerView
    foreignController = contactsNavigationVC
    
    // close the right side view menu
    self.revealViewController().rightRevealToggleAnimated(true)
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
  
  func clearForeignViewController() {
  
  }
  
  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return UIStatusBarStyle.LightContent
  }
  
  override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
    return .Fade
  }
  
  // MARK: Notification observers
  
  private func addObservers() {
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MainTabBarController.venuesRowPressed), name: Constants.MenuNotification.VenuesRowPressed, object: nil)
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MainTabBarController.contactsRowPressed), name: Constants.MenuNotification.ContactsRowPressed, object: nil)
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MainTabBarController.profileRowPressed), name: Constants.MenuNotification.ProfileRowPressed, object: nil)
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
      if foreignController != nil {
        foreignController = nil
      }
      return true
    }
  }
}

