//
//  SignInViewController.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 12/16/15.
//  Copyright © 2015 Andrew Steinmeyer. All rights reserved.
//

import UIKit
import CoreData
import PhoneNumberKit


enum Screen: Int {
  case SignIn
  case Register
}

class SignInViewController: UIViewController, UITextFieldDelegate, ValidationDelegate {
  
  @IBOutlet weak var errorMessageLabel: UILabel!
  @IBOutlet weak var nameField: DesignableTextField!
  @IBOutlet weak var emailField: DesignableTextField!
  @IBOutlet weak var phoneNumberField: PhoneTextField!
  @IBOutlet weak var passwordField: DesignableTextField!
  @IBOutlet weak var passwordConfirmationField: DesignableTextField!
  @IBOutlet weak var toggleScreenButton: UIButton!
  @IBOutlet weak var actionButton: DesignableButton!
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  
  var nameValidated = false
  var emailValidated = false
  var phoneValidated = false
  var passwordValidated = false
  var passwordConfirmationValidated = false
  
  let validator = Validator()
  
  // set initial screen
  var currentScreen: Screen = .SignIn
  
  // MARK: View Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // set view controller as textfield delegate
    nameField.delegate = self
    emailField.delegate = self
    phoneNumberField.delegate = self
    passwordField.delegate = self
    passwordConfirmationField.delegate = self
    
    setupAppearance()
    
    // setup text field validations
    registerValidations()
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
      validate()
    }
  }
  
  //MARK: - Sign in and Sign up
  
  private func signIn() {
    guard let email = emailField.text where !email.isEmpty,
      let password = passwordField.text where !password.isEmpty else {
        let errorMessage = "Email and password required."
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
          
          // register for APNS
          AppDelegate.getAppDelegate().registerForPushNotifications()
         
          // present home screen
          HomeViewController.presentHomeViewController()
        }
      }
    }
  }

  private func signUp() {
    // already validated in validate()
    // but use guard to extract to local variables
    guard let name = nameField.text where !name.isEmpty,
      let email = emailField.text where !email.isEmpty,
      var phoneNumber = phoneNumberField.text where !phoneNumber.isEmpty,
      let password = passwordField.text where !password.isEmpty,
      let passwordConfirmation = passwordConfirmationField.text where !passwordConfirmation.isEmpty
      && password == passwordConfirmation else {
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
          
          // register for APNS
          AppDelegate.getAppDelegate().registerForPushNotifications()
          
          // present home screen
          HomeViewController.presentHomeViewController()
        }
      }
    }
  }
  
  //MARK: Helper functions
  
  private func toggleScreen() {
    switch currentScreen {
    case .SignIn:
      currentScreen = .Register
      clearErrors()
      
      // unhide views and focus on nameField
      animateViews([nameField, phoneNumberField, passwordConfirmationField], toHidden: false)
      nameField.becomeFirstResponder()
      
      // toggle button titles
      actionButton.setTitle("Register", forState: .Normal)
      toggleScreenButton.setTitle("Sign In", forState: .Normal)
      
    case .Register:
      currentScreen = .SignIn
      clearErrors()
      
      // hide views and focus on emailField
      animateViews([nameField, phoneNumberField, passwordConfirmationField], toHidden: true)
      emailField.becomeFirstResponder()
      
      // toggle button titles
      actionButton.setTitle("Sign In", forState: .Normal)
      toggleScreenButton.setTitle("Register", forState: .Normal)
    }
    
  }
  
  private func toggleIndicator() {
    if actionButton.enabled {
      // hide activity indicator
      activityIndicator.hidden = false
      activityIndicator.startAnimating()
      
      // show action button
      actionButton.enabled = false
      actionButton.hidden = true
    }
    else {
      // show activity indicator
      activityIndicator.hidden = true
      activityIndicator.stopAnimating()
    
      // hide action button
      actionButton.enabled = true
      actionButton.hidden = false
    }
  }
  
  private func setupAppearance() {
    // set theme color
    let themeColor = Theme.SignInViewThemeColor.toUIColor()
    actionButton.backgroundColor = themeColor
    toggleScreenButton.setTitleColor(themeColor, forState: .Normal)
    
    // set background color
    view.backgroundColor = Theme.SignInViewBackgroundColor.toUIColor()
    
    nameField.hidden = true
    phoneNumberField.hidden = true
    passwordConfirmationField.hidden = true
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

  
  private func animateViews(views: [UIView], toHidden hidden: Bool) {
    UIView.animateWithDuration(0.8, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 10, options: UIViewAnimationOptions(), animations: { () -> Void in
      let _ = views.map { $0.hidden = hidden }
      }, completion: nil)
  }
  
  //MARK: Validation
  
  private func validate() {
    validator.validate(self)
  }
  
  func validationSuccessful() {
    signUp()
  }
  
  func validationFailed(errors: OrderedDictionary<UITextField,ValidationError>) {
    for (_, error) in validator.errors {
      // the last error will be displayed
      displayError(error.errorMessage)
    }
  }
  
  private func registerValidations() {
    // password confirmation
    validator.registerField(passwordConfirmationField, errorLabel: errorMessageLabel, rules: [ConfirmationRule(confirmField: passwordField, message: "Passwords do not match.")])
    
    // password
    validator.registerField(passwordField, errorLabel: errorMessageLabel, rules: [RequiredRule(message: "Password is required."), MinLengthRule(length: 5, message: "Password must be 5 characters.")])
    
    // phone
    validator.registerField(phoneNumberField, errorLabel: errorMessageLabel, rules: [RequiredRule(message: "Phone number is required."), MinLengthRule(length: 9, message: "Invalid phone number.")])
    
    // email
    validator.registerField(emailField, errorLabel: errorMessageLabel, rules: [RequiredRule(message: "Email is required."), EmailRule(message: "Invalid email address.")])
    
    // name
    validator.registerField(nameField, errorLabel: errorMessageLabel, rules: [RequiredRule(message: "Name is required."), FullNameRule()])
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
    AppDelegate.getRootViewController()?.presentViewController(signInViewController, animated: true, completion: nil)
  }
  
}


