//
//  CreateContactViewController.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 12/18/15.
//  Copyright © 2015 Andrew Steinmeyer. All rights reserved.
//

import UIKit
import Crashlytics

class CreateContactViewController: UIViewController, UIMaterialTextFieldDelegate {

  @IBOutlet weak var errorMessageLabel: UILabel!
  @IBOutlet weak var nameTextField: UIMaterialTextField!
  @IBOutlet weak var phoneTextField: UIMaterialTextField!
  @IBOutlet weak var emailTextField: UIMaterialTextField!
  @IBOutlet weak var createContactButton: DesignableButton!
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    clearErrors()
    
    // assign first responder
    nameTextField.becomeFirstResponder()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // set delegate
    nameTextField.materialDelegate = self
    phoneTextField.materialDelegate = self
    emailTextField.materialDelegate = self
    
    setupAppearance()
  }
  
  // MARK: UIMaterialTextFieldDelegate
  
  func materialTextFieldShouldReturn(textField: UITextField) -> Bool {
    if textField == nameTextField {
      phoneTextField.becomeFirstResponder()
    } else if textField == phoneTextField {
      emailTextField.becomeFirstResponder()
    } else if textField == emailTextField {
      emailTextField.resignFirstResponder()
      createContact()
    }
  
    return false
  }
  
  @IBAction func createContactDidCancel(sender: AnyObject) {
    self.view.endEditing(true)
    self.dismissViewControllerAnimated(true, completion: nil)
  }

  @IBAction func createContactButtonPressed() {
    createContact()
  }
  
  private func createContact() {
    guard let name = nameTextField.text where !name.isEmpty,
      let phone = phoneTextField.text where !phone.isEmpty,
      let email = emailTextField.text where !email.isEmpty else {
        let errorMessage = "All fields are needed to create a contact."
        displayError(errorMessage)
        
        return
    }
    
    // dismiss keyboard
    self.view.endEditing(true)
    
    MeteorContactService.sharedInstance.create( [name, phone, email] ) {
      result, error in
      
      dispatch_async(dispatch_get_main_queue()) {
        if let error = error {
          let errorMessage = error.localizedFailureReason
          self.displayError(errorMessage!)
        } else {
          self.dismissViewControllerAnimated(true, completion: nil)
          
          Answers.logCustomEventWithName("Create Contact",
            customAttributes: [
              "User": (AccountManager.defaultAccountManager.currentUser?.fullName)!,
              "Contact Name": name,
              "Contact Phone": phone,
              "Contact Email": email,
              "Source": "iPhone"
            ]
          )
        }
      }
    }
  }
  
  private func displayError(message: String) {
    // clear out previous errors
    clearErrors()
    
    // set error message
    errorMessageLabel.text = message
    errorMessageLabel.alpha = 1
    
    UIView.animateWithDuration(5) {
      self.errorMessageLabel.alpha = 0
    }
  }
  
  private func clearErrors() {
    errorMessageLabel.text = nil
  }
  
  private func setupAppearance() {
    // set theme colors
    let buttonColor =  Theme.CreateContactButtonBackgroundColor.toUIColor()
    let buttonTextColor = Theme.CreateContactButtonTextColor.toUIColor()
    
    createContactButton.backgroundColor = buttonColor
    createContactButton.setTitleColor(buttonTextColor, forState: .Highlighted)
    
    // set error color
    errorMessageLabel.textColor = Theme.CreateContactViewErrorColor.toUIColor()
  }
  
}
