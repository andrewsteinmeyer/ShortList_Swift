//
//  CreateEventViewController.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 1/5/16.
//  Copyright © 2016 Andrew Steinmeyer. All rights reserved.
//

import UIKit
import ObjectMapper

private let dateFormatter: NSDateFormatter = {
  let formatter = NSDateFormatter()
  formatter.dateFormat = "EEE, MMM d"
    
  return formatter
}()

private let timeFormatter: NSDateFormatter = {
  let formatter = NSDateFormatter()
  formatter.dateStyle = .NoStyle
  formatter.timeStyle = .ShortStyle
  
  return formatter
}()

class CreateEventViewController: UIViewController, UIMaterialTextFieldDelegate {
  
  @IBOutlet weak var errorMessageLabel: UILabel!
  @IBOutlet weak var nameTextField: UIMaterialTextField!
  @IBOutlet weak var dateTextField: UIMaterialTextField!
  @IBOutlet weak var timeTextField: UIMaterialTextField!
  @IBOutlet weak var listTextField: UIMaterialTextField!
  @IBOutlet weak var venueTextField: UIMaterialTextField!
  @IBOutlet weak var locationTextField: UIMaterialTextField!
  @IBOutlet weak var minGuestTextField: UIMaterialTextField!
  @IBOutlet weak var maxGuestTextField: UIMaterialTextField!
  
  private var location: Location?
  
  private var popDatePicker: PopDatePicker?
  private var selectedDate: NSDate? {
    didSet {
      guard isViewLoaded(), let date = selectedDate else {
        return
      }
      
      dateTextField.text = dateFormatter.stringFromDate(date) as String
      timeTextField.text = timeFormatter.stringFromDate(date) as String
      
    }
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    setup()
    clearErrors()
  }
  
  func setup() {
    // set delegate
    nameTextField.materialDelegate = self
    dateTextField.materialDelegate = self
    timeTextField.materialDelegate = self
    locationTextField.materialDelegate = self
    
    // setup popup date picker
    popDatePicker = PopDatePicker(forTextField: dateTextField)
    
    // assign first responder
    //nameTextField.becomeFirstResponder()
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
  
  func materialTextFieldShouldBeginEditing(textField: UITextField) -> Bool {
    if textField == dateTextField {
      // stop keyboard from showing
      self.view.endEditing(true)
      
      return false
    }
    
    return true
  }
  
  func materialTextFieldShouldReturn(textField: UITextField) -> Bool {
    if textField == nameTextField {
      locationTextField.becomeFirstResponder()
      showPlacePicker()
    } else if textField == locationTextField {
      createEvent()
    }
    
    return false
  }
  
  // MARK: IBAction methods
  
  @IBAction func dateTextFieldDidPress(sender: AnyObject) {
    dateTextField.resignFirstResponder()
    
    let selectedDate : NSDate? = dateFormatter.dateFromString(dateTextField.text!)
    let initDate = (selectedDate ?? NSDate())
    
    let dataChangedCallback : PopDatePicker.PopDatePickerCallback = { [weak self]
      (newDate : NSDate, forTextField : UITextField) -> () in
      
      if let strongSelf = self {
        strongSelf.selectedDate = newDate
      }
      
      forTextField.text = (dateFormatter.stringFromDate(newDate) ?? "?") as String
    }
    
    popDatePicker!.pick(self, initDate: initDate, dataChanged: dataChangedCallback)
  }
  
  @IBAction func createEventDidCancel(sender: AnyObject) {
    self.view.endEditing(true)
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  @IBAction func createEventButtonPressed(sender: AnyObject) {
    self.view.endEditing(true)
    createEvent()
  }
  
  @IBAction func locationTextFieldPressed(sender: AnyObject) {
    showPlacePicker()
  }
  
  // MARK: Private methods
  
  private func showPlacePicker() {
    performSegueWithIdentifier("showPlacePicker", sender: nil)
  }
  
  private func createEvent() {
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

extension CreateEventViewController: PlacePickerViewControllerDelegate {
  
  func placePickerDidSelectLocation(location: Location) {
    self.location = location
    self.locationTextField.text = location.address
    
  }
  
}