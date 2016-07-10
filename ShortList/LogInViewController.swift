//
//  LogInViewController.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 7/9/16.
//  Copyright © 2016 Andrew Steinmeyer. All rights reserved.
//

import UIKit
import CoreData
import Crashlytics
import FBSDKLoginKit


class LogInViewController: UIViewController {
  
  @IBOutlet weak var errorMessageLabel: UILabel!
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  @IBOutlet weak var facebookLoginButton: FBSDKLoginButton!
  
  // MARK: View Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupAppearance()
    
    // setup Facebook for login
    configureFacebook()
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    clearErrors()
  }
  
  //MARK: Helper functions
  
  private func configureFacebook() {
    // set read permissions
    facebookLoginButton.readPermissions = ["public_profile", "email", "user_friends"]
    
    // set view controller as facebook login delegate
    facebookLoginButton.delegate = self
  }
  
  private func toggleIndicator() {
    if activityIndicator.hidden {
      activityIndicator.startAnimating()
      activityIndicator.hidden = false
    }
    else {
      activityIndicator.stopAnimating()
      activityIndicator.hidden = true
    }
  }
  
  private func setupAppearance() {
    // set background color
    view.backgroundColor = Theme.SignInViewBackgroundColor.toUIColor()
    
    // configure facebook button text
    facebookLoginButton.titleLabel?.font = UIFont(name: "Lato-Regular", size: 18)
    
    activityIndicator.hidden = true
  }
  
  private func displayError(message: String) {
    // clear out previous errors
    clearErrors()
    
    errorMessageLabel.text = message
    errorMessageLabel.alpha = 1
    
    // display error for set duration
    UIView.animateWithDuration(5) {
      self.errorMessageLabel.alpha = 0
    }
  }
  
  private func clearErrors() {
    errorMessageLabel.text = " "
  }
  
  //MARK: Status Bar
  
  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return .LightContent
  }
  
  //MARK: - Static methods
  
  static func presentLogInViewController(animated animated: Bool = true) {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    
    let logInViewController = storyboard.instantiateViewControllerWithIdentifier("LogInViewController") as! LogInViewController
    
    // Customize the login view controller presentation and transition styles.
    logInViewController.modalPresentationStyle = .OverCurrentContext
    logInViewController.modalTransitionStyle = .CrossDissolve
    
    // Present the sign in view controller.
    AppDelegate.getRootViewController()?.presentViewController(logInViewController, animated: animated, completion: nil)
  }
  
}

//MARK: - Facebook Delegate Methods

extension LogInViewController: FBSDKLoginButtonDelegate {
  
  // FB Delegate method called right before login
  func loginButtonWillLogin(loginButton: FBSDKLoginButton!) -> Bool {
    // start activity indicator and disable action button
    self.toggleIndicator()
    
    return true
  }
  
  //TODO: Handle case when FB logs out user - just kicking user off app for now
  func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
    //AccountManager.defaultAccountManager.signOut()
  }
  
  // FB Delegate method callback after login
  func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
    
    // error with facebook authentication
    if let error = error {
      let errorMessage = error.localizedFailureReason
      self.displayError(errorMessage!)
      
      Answers.logLoginWithMethod("Facebook",
                                 success: false,
                                 customAttributes: ["Error": error.localizedDescription])
    }
    else {
      // verify result object return
      guard let result = result else {
        return
      }
      
      // handle when user cancels facebook login request
      if result.isCancelled {
        let errorMessage = "User cancelled Facebook login request"
        self.displayError(errorMessage)
        
        Answers.logLoginWithMethod("Facebook",
                                   success: false,
                                   customAttributes: ["Error": errorMessage])
      }
      // handle result
      else {
        // verify token and id from Facebook
        guard let token = result.token,
          let accessToken = token.tokenString,
          let userID = token.userID else {
          
          let errorMessage = "Facebook did not provide accessToken or userID"
          self.displayError(errorMessage)
            
          Answers.logLoginWithMethod("Facebook",
                                      success: false,
                                      customAttributes: ["Error": errorMessage])
            
          return
        }
        
        AccountManager.defaultAccountManager.loginWithFacebook(userID, token: accessToken) { (error) -> Void in
          dispatch_async(dispatch_get_main_queue()) {
            
            // stop activity indicator
            self.toggleIndicator()
            
            if let error = error {
              let errorMessage = error.localizedFailureReason
              self.displayError(errorMessage!)
              
              Answers.logLoginWithMethod("Facebook",
                                         success: false,
                                         customAttributes: ["Error": error.localizedDescription])
            } else {
              // dismiss login controller
              self.dismissViewControllerAnimated(true, completion: nil)
              
              // send device token to Meteor for APNS
              AccountManager.defaultAccountManager.setUserNotificationToken()
              
              // register for APNS
              AppDelegate.getAppDelegate().registerForPushNotifications()
              
              // reset badge count
              // the reset in applicationDidBecomeActive only handles when the user is already logged in to app
              // we reset here to handle the case when the user opens the app but isn't logged in yet
              AppDelegate.getAppDelegate().resetBadgeCount()
              
              // present home screen
              HomeViewController.presentHomeViewController()
              
              // log to Answers
              Answers.logLoginWithMethod("Facebook",
                                         success: true,
                                         customAttributes: ["Success": "User logged in using Facebook"])
            }
          }
        }
      }
    }
  }

}
  
  //MARK: Facebook Graph API Call example just in case
  
  /*
   func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
   
   FBSDKGraphRequest.init(graphPath: "me", parameters: ["fields":"first_name, last_name, email, picture.type(large)"]).startWithCompletionHandler {
   (connection, result, error) -> Void in
   
   if let error = error {
   let errorMessage = error.localizedFailureReason
   self.displayError(errorMessage!)
   
   Answers.logLoginWithMethod("Facebook",
   success: false,
   customAttributes: ["Error": error.localizedDescription])
   }
   
   if let declinedPermissions = result.declinedPermissions {
   if declinedPermissions.contains("email") {
   let errorMessage = "User declined permission to use email"
   self.displayError(errorMessage)
   
   Answers.logLoginWithMethod("Facebook",
   success: false,
   customAttributes: ["Error": errorMessage])
   }
   }
   else {
   let strFirstName: String = (result.objectForKey("first_name") as? String)!
   let strLastName: String = (result.objectForKey("last_name") as? String)!
   //let strPictureURL: String = (result.objectForKey("picture")?.objectForKey("data")?.objectForKey("url") as? String)!
   self.ivUserProfileImage.image = UIImage(data: NSData(contentsOfURL: NSURL(string: strPictureURL)!)!)
   }
   }
   }
   */
  




