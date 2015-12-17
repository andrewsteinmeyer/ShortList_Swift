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
  
  @IBOutlet weak var emailField: DesignableTextField!
  @IBOutlet weak var passwordField: DesignableTextField!
  @IBOutlet weak var passwordConfirmationField: DesignableTextField!
  @IBOutlet weak var errorMessageLabel: UILabel!
  @IBOutlet weak var toggleScreenButton: UIButton!
  @IBOutlet weak var actionButton: DesignableButton!
  
  var currentScreen = Screen.SignIn
  
  // MARK: View Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    toggleScreenButton.setTitleColor(UIColor.accentColor(), forState: .Highlighted)
  }
  
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    clearErrors()
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    
    emailField.becomeFirstResponder()
  }
  
  private func toggleScreen() {
    switch currentScreen {
    case .SignIn:
      currentScreen = .Register
      clearErrors()
      
      passwordConfirmationField.animation = "fadeIn"
      passwordConfirmationField.animate()
      
      actionButton.setTitle("Register", forState: .Normal)
      toggleScreenButton.setTitle("Sign In", forState: .Normal)
      
    case .Register:
      currentScreen = .SignIn
      clearErrors()
      
      passwordConfirmationField.animation = "fadeOut"
      passwordConfirmationField.animate()
      
      actionButton.setTitle("Sign In", forState: .Normal)
      toggleScreenButton.setTitle("Register", forState: .Normal)
    }
  
  }
  
  private func clearErrors() {
    errorMessageLabel.text = nil
  }
  
  // MARK: UITextFieldDelegate
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    switch currentScreen {
    case .SignIn:
      print("oh")
      if textField == emailField {
        passwordField.becomeFirstResponder()
      } else if textField == passwordField {
        passwordField.resignFirstResponder()
        signIn()
      }
    case .Register:
      if textField == emailField {
        passwordField.becomeFirstResponder()
      } else if textField == passwordField {
        passwordConfirmationField.becomeFirstResponder()
      } else if textField == passwordConfirmationField {
        passwordConfirmationField.resignFirstResponder()
        signUp()
      }
    }

    return false
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
  
  private func signIn() {
    guard let email = emailField.text where !email.isEmpty,
      let password = passwordField.text where !password.isEmpty else {
        let errorMessage = "Email and password required"
        displayError(errorMessage)
        
        return
    }
    
    Meteor.loginWithEmail(email, password: password) { (error) -> Void in
      if let error = error {
        let errorMessage = error.localizedFailureReason
        self.displayError(errorMessage!)
      } else {
        self.dismissViewControllerAnimated(true, completion: nil)
      }
    }
  }
  
  private func displayError(message: String) {
    // clear out previous errors
    clearErrors()
    
    errorMessageLabel.text = message
    errorMessageLabel.alpha = 1
    
    UIView.animateWithDuration(5) {
      self.errorMessageLabel.alpha = 0
    }
  }
  
  private func signUp() {
    guard let email = emailField.text where !email.isEmpty,
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
    
    Meteor.signUpWithEmail(email, password: password) { (error) -> Void in
      if let error = error {
        let errorMessage = error.localizedFailureReason
        self.displayError(errorMessage!)
      } else {
        self.toggleScreen()
      }
    }
  }
  
  static func presentSignInViewController(withCompletion completion: (Bool -> ())) {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    
    let signInViewController = storyboard.instantiateViewControllerWithIdentifier("SignInViewController") as! SignInViewController
    
    // Customize the sign in view controller presentation and transition styles.
    signInViewController.modalPresentationStyle = .OverCurrentContext
    signInViewController.modalTransitionStyle = .CrossDissolve
    
    // Present the sign in view controller.
    AppDelegate.getAppDelegate().window?.rootViewController?.presentViewController(signInViewController, animated: true, completion: nil)
  }
}


