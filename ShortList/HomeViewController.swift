//
//  HomeViewController.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 12/14/15.
//  Copyright © 2015 Andrew Steinmeyer. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

  @IBOutlet weak var menuButton: UIBarButtonItem!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // present sign in screen if user is not already logged in
    if !AccountManager.defaultAccountManager.isUserLoggedIn {
      SignInViewController.presentSignInViewController()
    }
    
    if self.revealViewController() != nil {
      self.revealViewController().bounceBackOnOverdraw = false
      
      menuButton.target = self.revealViewController()
      menuButton.action = "revealToggle:"
      self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
}
