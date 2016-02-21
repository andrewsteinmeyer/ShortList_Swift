//
//  SignInViewController.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 12/16/15.
//  Copyright © 2015 Andrew Steinmeyer. All rights reserved.
//

import UIKit
import CoreData
import Meteor


enum Screen: Int {
  case SignIn
  case Register
}

class SignInViewController: UIViewController, UITextFieldDelegate {
  
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var nameField: DesignableTextField!
  @IBOutlet weak var emailField: DesignableTextField!
  @IBOutlet weak var phoneNumberField: DesignableTextField!
  @IBOutlet weak var passwordField: DesignableTextField!
  @IBOutlet weak var passwordConfirmationField: DesignableTextField!
  @IBOutlet weak var errorMessageLabel: UILabel!
  @IBOutlet weak var toggleScreenButton: UIButton!
  @IBOutlet weak var actionButton: DesignableButton!
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  
  // set initial screen
  var currentScreen: Screen = .SignIn
  
  // MARK: View Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // set view controller as delegate
    nameField.delegate = self
    emailField.delegate = self
    phoneNumberField.delegate = self
    passwordField.delegate = self
    passwordConfirmationField.delegate = self
    
    nameField.hidden = true
    phoneNumberField.hidden = true
    passwordConfirmationField.hidden = true
    
    setupAppearance()
  }
  
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    clearErrors()
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    
    // initially focus on name field
    emailField.becomeFirstResponder()
  }
  
  private func toggleScreen() {
    switch currentScreen {
    case .SignIn:
      currentScreen = .Register
      clearErrors()
      
      // unhide views
      animateViews([nameField, phoneNumberField, passwordConfirmationField], toHidden: false)
      nameField.becomeFirstResponder()
      
      actionButton.setTitle("Register", forState: .Normal)
      toggleScreenButton.setTitle("Sign In", forState: .Normal)
      
    case .Register:
      currentScreen = .SignIn
      clearErrors()
      
      // hide views
      animateViews([nameField, phoneNumberField, passwordConfirmationField], toHidden: true)
      emailField.becomeFirstResponder()
      
      actionButton.setTitle("Sign In", forState: .Normal)
      toggleScreenButton.setTitle("Register", forState: .Normal)
    }
  
  }
  
  private func animateViews(views: [UIView], toHidden hidden: Bool) {
    UIView.animateWithDuration(0.8, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 10, options: UIViewAnimationOptions(), animations: { () -> Void in
      let _ = views.map { $0.hidden = hidden }
      }, completion: nil)
  }
  
  // MARK: UITextFieldDelegate
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    switch currentScreen {
    case .SignIn:
      if textField == nameField {
        phoneNumberField.becomeFirstResponder()
      } else if textField == phoneNumberField {
        emailField.becomeFirstResponder()
      } else if textField == emailField {
        passwordField.becomeFirstResponder()
      } else if textField == passwordField {
        passwordField.resignFirstResponder()
        signIn()
      }
    case .Register:
      if textField == nameField {
        emailField.becomeFirstResponder()
      } else if textField == emailField {
        phoneNumberField.becomeFirstResponder()
      } else if textField == phoneNumberField {
        passwordField.becomeFirstResponder()
      } else if textField == passwordField {
        passwordConfirmationField.becomeFirstResponder()
      } else if textField == passwordConfirmationField {
        passwordConfirmationField.resignFirstResponder()
        signUp()
      }
    }

    return true
  }
  
  // MARK: IBActions
  @IBAction func toggleScreenButtonPressed(sender: AnyObject) {
    toggleScreen()
  }
  
  @IBAction func actionButtonPressed(sender: AnyObject) {
    switch currentScreen {
    case .SignIn:
      signIn()
    case .Register:
      signUp()
    }
  }
  
  //MARK: - Sign In and Sign Up
  
  private func signIn() {
    guard let email = emailField.text where !email.isEmpty,
      let password = passwordField.text where !password.isEmpty else {
        let errorMessage = "All fields required to sign in"
        displayError(errorMessage)
        
        return
    }
    
    // start activity indicator and disable action button
    toggleIndicator()
    
    AccountManager.defaultAccountManager.loginWithEmail(email, password: password) { (error) -> Void in
      dispatch_async(dispatch_get_main_queue()) {
        
        // stop activity indicator and re-enable action button
        self.toggleIndicator()
        
        if let error = error {
          let errorMessage = error.localizedFailureReason
          self.displayError(errorMessage!)
        } else {
          // dismiss keyboard and signup controller
          self.view.endEditing(true)
          self.dismissViewControllerAnimated(true, completion: nil)
        }
      }
    }
  }
  
  private func signUp() {
    guard let name = nameField.text where !name.isEmpty,
      let email = emailField.text where !email.isEmpty,
      var phoneNumber = phoneNumberField.text where !phoneNumber.isEmpty,
      let password = passwordField.text where !password.isEmpty,
      let passwordConfirmation = passwordConfirmationField.text where !passwordConfirmation.isEmpty else {
        let errorMessage = "All fields required to register"
        displayError(errorMessage)
        return
    }
    
    if password != passwordConfirmation {
      let errorMessage = "Password and confirmation do not match"
      displayError(errorMessage)
      return
    }
    
    // strip down phone number
    phoneNumber = phoneNumber.stringByRemovingOccurrencesOfCharacters(" )(- ")
    
    // start activity indicator and disable action button
    toggleIndicator()
    
    AccountManager.defaultAccountManager.signUpWithEmail(email, password: password, name: name, phone: phoneNumber) { (error) -> Void in
      dispatch_async(dispatch_get_main_queue()) {
        
        // stop activity indicator and re-enable action button
        self.toggleIndicator()
        
        if let error = error {
          let errorMessage = error.localizedFailureReason
          self.displayError(errorMessage!)
        } else {
          // send device token to Meteor for APNS
          AccountManager.defaultAccountManager.setUserNotificationToken()
          
          // dismiss keyboard and signup controller
          self.view.endEditing(true)
          self.dismissViewControllerAnimated(true, completion: nil)
        }
      }
    }
  }
  
  private func toggleIndicator() {
    if actionButton.enabled {
      activityIndicator.hidden = false
      activityIndicator.startAnimating()
      
      toggleScreenButton.hidden = true
      
      actionButton.enabled = false
      actionButton.hidden = true
    }
    else {
      activityIndicator.hidden = true
      activityIndicator.stopAnimating()
      
      toggleScreenButton.hidden = false
      
      actionButton.enabled = true
      actionButton.hidden = false
    }
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
  
  private func setupAppearance() {
    // set theme color
    let themeColor = Theme.SignInViewThemeColor.toUIColor()
    titleLabel.textColor = themeColor
    actionButton.backgroundColor = themeColor
    toggleScreenButton.setTitleColor(themeColor, forState: .Normal)
    
    // set background color
    view.backgroundColor = Theme.SignInViewBackgroundColor.toUIColor()
    
    // set error color
    errorMessageLabel.textColor = Theme.SignInViewErrorColor.toUIColor()
  }
  
  //MARK: Status Bar
  
  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return .LightContent
  }
  
  //MARK: - Static methods
  
  static func presentSignInViewController() {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    
    let signInViewController = storyboard.instantiateViewControllerWithIdentifier("SignInViewController") as! SignInViewController
    
    // Customize the sign in view controller presentation and transition styles.
    signInViewController.modalPresentationStyle = .OverCurrentContext
    signInViewController.modalTransitionStyle = .CrossDissolve
    
    // Present the sign in view controller.
    //AppDelegate.getRootViewController()?.presentViewController(signInViewController, animated: true, completion: nil)
    UIApplication.topViewController()?.presentViewController(signInViewController, animated: true, completion: nil)
  }
  
}


