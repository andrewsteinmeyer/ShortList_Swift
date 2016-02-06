//
//  CreateListViewController.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 12/19/15.
//  Copyright © 2015 Andrew Steinmeyer. All rights reserved.
//

import UIKit
import Groot

class CreateListViewController: UIViewController, UIMaterialTextFieldDelegate {
  
  @IBOutlet weak var errorMessageLabel: UILabel!
  @IBOutlet weak var nameTextField: UIMaterialTextField!
  @IBOutlet weak var selectContactsHeaderViewLabel: UILabel!
  @IBOutlet weak var selectContactsHeaderView: UIView!
  
  var selectedContacts = [Contact]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupAppearance()
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    setup()
    clearErrors()
  }
  
  func setup() {
    // set delegate
    nameTextField.materialDelegate = self
    
    // assign first responder
    nameTextField.becomeFirstResponder()
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "selectContacts" {
      if let selectContactsViewController = segue.destinationViewController as? SelectContactsViewController {
        selectContactsViewController.delegate = self
      }
    }
  }
  
  
  // MARK: - UIMaterialTextFieldDelegate
  
  func materialTextFieldShouldReturn(textField: UITextField) -> Bool {
    if textField == nameTextField {
      createList()
    }
    
    return false
  }
  
  // MARK: - IBAction methods
  
  @IBAction func createListDidCancel(sender: AnyObject) {
    self.view.endEditing(true)
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  
  @IBAction func createListButtonPressed() {
    self.view.endEditing(true)
    createList()
  }
  
  private func createList() {
    guard let name = nameTextField.text where !name.isEmpty else {
        let errorMessage = "All fields are required to create list"
        displayError(errorMessage)
        
        return
    }
    
    // convert to JSON to save to Meteor
    let JSONContacts = selectedContacts.map { contact in JSONDictionaryFromObject(contact) }
    
    // toggle for hiding members of list
    let hideMembers = false
    
    //TODO: add support in UI for security and hideMembers
    //      setting to "public" and false for now
    
    MeteorListService.sharedInstance.create( [name, "public", hideMembers, JSONContacts] ) {
      result, error in
      
      dispatch_async(dispatch_get_main_queue()) {
        if let error = error {
          let errorMessage = error.localizedFailureReason
          self.displayError(errorMessage!)
        } else {
          // dismiss keyboard
          self.resignFirstResponder()
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
  
  private func setupAppearance() {
    selectContactsHeaderView.backgroundColor = Theme.SelectContactsHeaderViewBackgroundColor.toUIColor()
    selectContactsHeaderViewLabel.textColor = Theme.SelectContactsHeaderViewTextColor.toUIColor()
  }
  
}

extension CreateListViewController: SelectContactsViewControllerDelegate {
  
  func selectContactsViewControllerDidSelectContact(contact: Contact) {
    selectedContacts.append(contact)
  }
  
  func selectContactsViewControllerDidRemoveContact(selectedContact: Contact) {
    //TODO: Should this comparison be == or === for identity comparison (value vs. reference)
    selectedContacts = selectedContacts.filter { contact in
      !(contact === selectedContact)
    }
  }
}