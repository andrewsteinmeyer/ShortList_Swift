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
  @IBOutlet weak var createVenueButton: DesignableButton!
  
  private var location: Location?
  
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
    locationTextField.materialDelegate = self
    
    setupAppearance()
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
        let errorMessage = "Both fields are needed to create a venue."
        displayError(errorMessage)
        
        return
    }
    
    // dismiss keyboard
    self.view.endEditing(true)
    
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
    let buttonColor =  Theme.CreateVenueButtonBackgroundColor.toUIColor()
    let buttonTextColor = Theme.CreateVenueButtonTextColor.toUIColor()
    
    createVenueButton.backgroundColor = buttonColor
    createVenueButton.setTitleColor(buttonTextColor, forState: .Highlighted)
    
    // set error color
    errorMessageLabel.textColor = Theme.CreateVenueViewErrorColor.toUIColor()
  }
  
}

extension CreateVenueViewController: PlacePickerViewControllerDelegate {
  
  func placePickerDidSelectLocation(location: Location) {
    self.location = location
    self.locationTextField.text = location.address
    
  }
  
}
