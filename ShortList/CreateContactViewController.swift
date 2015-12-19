//
//  CreateContactViewController.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 12/18/15.
//  Copyright © 2015 Andrew Steinmeyer. All rights reserved.
//

import UIKit

class CreateContactViewController: UIViewController, UITextFieldDelegate {

  @IBOutlet weak var errorMessageLabel: UILabel!
  @IBOutlet weak var nameTextField: UIMaterialTextField!
  @IBOutlet weak var phoneTextField: UIMaterialTextField!
  @IBOutlet weak var emailTextField: UIMaterialTextField!
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    clearErrors()
    
    nameTextField.becomeFirstResponder()
  }
  
  
  // MARK: UITextFieldDelegate
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
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

  @IBAction func createContactButtonPressed() {
    createContact()
  }
  
  private func createContact() {
    guard let name = nameTextField.text where !name.isEmpty,
      let phone = phoneTextField.text where !phone.isEmpty,
      let email = emailTextField.text where !email.isEmpty else {
        let errorMessage = "All fields are required to create contact"
        displayError(errorMessage)
        
        return
    }
    
    MeteorContactService.sharedInstance.create( [name, phone, email] ) {
      result, error in
      
      dispatch_async(dispatch_get_main_queue()) {
        if let error = error {
          let errorMessage = error.localizedFailureReason
          self.displayError(errorMessage!)
        } else {
          self.navigationController?.popViewControllerAnimated(true)
        }
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
  
  private func clearErrors() {
    errorMessageLabel.text = nil
  }
  
}
