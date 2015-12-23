//
//  CreateContactViewController.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 12/18/15.
//  Copyright © 2015 Andrew Steinmeyer. All rights reserved.
//

import UIKit

class CreateContactViewController: UIViewController, UIMaterialTextFieldDelegate {

  @IBOutlet weak var errorMessageLabel: UILabel!
  @IBOutlet weak var nameTextField: UIMaterialTextField!
  @IBOutlet weak var phoneTextField: UIMaterialTextField!
  @IBOutlet weak var emailTextField: UIMaterialTextField!
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    setup()
    clearErrors()
  }
  
  func setup() {
    // set delegate
    nameTextField.materialDelegate = self
    phoneTextField.materialDelegate = self
    emailTextField.materialDelegate = self
    
    // assign first responder
    nameTextField.becomeFirstResponder()
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
    self.view.endEditing(true)
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
          self.dismissViewControllerAnimated(true, completion: nil)
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
