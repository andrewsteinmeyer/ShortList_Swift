//
//  CreateVenueViewController.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 12/31/15.
//  Copyright © 2015 Andrew Steinmeyer. All rights reserved.
//

import UIKit
import ObjectMapper

class CreateVenueViewController: UIViewController, UIMaterialTextFieldDelegate {
  
  @IBOutlet weak var errorMessageLabel: UILabel!
  @IBOutlet weak var locationTextField: UIMaterialTextField!
  @IBOutlet weak var nameTextField: UIMaterialTextField!
  
  private var location: Location?
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    setup()
    clearErrors()
  }
  
  func setup() {
    // set delegate
    nameTextField.materialDelegate = self
    locationTextField.materialDelegate = self
    
    // assign first responder
    nameTextField.becomeFirstResponder()
  }
  
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if let identifier = segue.identifier {
      if identifier == "showPlacePicker" {
        let placePickerViewController = segue.destinationViewController as! PlacePickerViewController
        placePickerViewController.delegate = self
      }
    }
  }
  
  // MARK: UIMaterialTextFieldDelegate
  
  func materialTextFieldShouldReturn(textField: UITextField) -> Bool {
    if textField == nameTextField {
      locationTextField.becomeFirstResponder()
      showPlacePicker()
    } else if textField == locationTextField {
      createVenue()
    }
    
    return false
  }
  
  // MARK: IBAction methods
  
  @IBAction func createVenueDidCancel(sender: AnyObject) {
    self.view.endEditing(true)
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  @IBAction func createVenueButtonPressed(sender: AnyObject) {
    self.view.endEditing(true)
    createVenue()
  }
  
  @IBAction func locationTextFieldPressed(sender: AnyObject) {
    showPlacePicker()
  }
  
  // MARK: Private methods
  
  private func showPlacePicker() {
    performSegueWithIdentifier("showPlacePicker", sender: nil)
  }
  
  private func createVenue() {
    guard let name = nameTextField.text where !name.isEmpty,
      let location = location else {
        let errorMessage = "Both fields are required to create venue"
        displayError(errorMessage)
        
        return
    }
    
    let JSONLocation = Mapper().toJSON(location)
    
    MeteorVenueService.sharedInstance.create( [name, JSONLocation] ) {
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

extension CreateVenueViewController: PlacePickerViewControllerDelegate {
  
  func placePickerDidSelectLocation(location: Location) {
    self.location = location
    self.locationTextField.text = location.address
    
  }
  
}
