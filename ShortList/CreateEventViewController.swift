//
//  CreateEventViewController.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 1/5/16.
//  Copyright © 2016 Andrew Steinmeyer. All rights reserved.
//

import UIKit
import ObjectMapper
import Groot

private let dateFormatter: NSDateFormatter = {
  let formatter = NSDateFormatter()
  formatter.dateFormat = "EEE, MMM d" // ie. Thu, Jun 8
    
  return formatter
}()

private let timeFormatter: NSDateFormatter = {
  let formatter = NSDateFormatter()
  formatter.dateStyle = .NoStyle
  formatter.timeStyle = .ShortStyle // ie. 11:10 PM
  
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
  
  private var list: List? {
    didSet {
      // set list name
      listTextField.text = list?.name
    }
  }
  
  private var location: Location? {
    didSet {
      // set location with address
      locationTextField.text = location?.address
    }
    
  }
  
  private var venue: Venue? {
    didSet {
      // set venue name
      venueTextField.text = venue?.name
      
      if let venueLocation = venue?.valueForKey("location") {
        let JSONLocation = JSON(venueLocation)
        
        let location = Location()
        location.name = JSONLocation["name"].string ?? ""
        location.address = JSONLocation["address"].string ?? ""
        location.latitude = JSONLocation["latitude"].double ?? 0.0
        location.longitude = JSONLocation["longitude"].double ?? 0.0
        
        self.location = location
      }
    }
  }
  
  private var popDatePicker: PopDatePicker?
  private var selectedDate: NSDate? {
    didSet {
      guard let date = selectedDate else {
        return
      }
      
      // set date and time text
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
    listTextField.materialDelegate = self
    venueTextField.materialDelegate = self
    locationTextField.materialDelegate = self
    minGuestTextField.materialDelegate = self
    maxGuestTextField.materialDelegate = self
    
    // setup popup date picker
    popDatePicker = PopDatePicker(forTextField: dateTextField)
    
    // assign first responder
    nameTextField.becomeFirstResponder()
  }
  
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if let identifier = segue.identifier {
      if identifier == "showPlacePicker" {
        let placePickerViewController = segue.destinationViewController as! PlacePickerViewController
        placePickerViewController.delegate = self
      }
      else if identifier == "selectVenue" {
        let selectVenueViewController = segue.destinationViewController as! SelectVenueViewController
        selectVenueViewController.delegate = self
        selectVenueViewController.selectedVenue = self.venue
      }
      else if identifier == "selectList" {
        let selectListViewController = segue.destinationViewController as! SelectListViewController
        selectListViewController.delegate = self
        selectListViewController.selectedList = self.list
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
      dateTextField.becomeFirstResponder()
      showDatePicker()
    }
    else if textField == minGuestTextField {
      maxGuestTextField.becomeFirstResponder()
    }
    else if textField == maxGuestTextField {
      maxGuestTextField.resignFirstResponder()
      createEvent()
    }
    
    return false
  }
  
  func materialTextFieldDidEndEditing(textField: UITextField) {
    if textField == maxGuestTextField {
      maxGuestTextField.resignFirstResponder()
    }
  }
  
  // MARK: IBAction methods
  
  // TODO: temporary until we add TPKeyboardAvoiding
  @IBAction func doneButtonDidPress(sender: AnyObject) {
    self.view.endEditing(true)
  }
  
  @IBAction func dateTextFieldDidPress(sender: AnyObject) {
    showDatePicker()
  }
  
  @IBAction func createEventDidCancel(sender: AnyObject) {
    self.view.endEditing(true)
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  @IBAction func createEventButtonPressed(sender: AnyObject) {
    self.view.endEditing(true)
    createEvent()
  }
  
  @IBAction func listTextFieldPressed(sender: AnyObject) {
    performSegueWithIdentifier("selectList", sender: nil)
  }
  
  @IBAction func locationTextFieldPressed(sender: AnyObject) {
    showPlacePicker()
  }
  
  @IBAction func venueTextFieldPressed(sender: AnyObject) {
    performSegueWithIdentifier("selectVenue", sender: nil)
  }
  
  // MARK: Private methods
  
  private func showDatePicker() {
    dateTextField.resignFirstResponder()
    
    let initDate = ( selectedDate != nil ? selectedDate : NSDate() )
    
    let dataChangedCallback : PopDatePicker.PopDatePickerCallback = { [weak self]
      (newDate : NSDate, forTextField : UITextField) -> () in
      
      if let strongSelf = self {
        strongSelf.selectedDate = newDate
      }
      
    }
    
    popDatePicker!.pick(self, initDate: initDate, dataChanged: dataChangedCallback)
  }
  
  private func showPlacePicker() {
    performSegueWithIdentifier("showPlacePicker", sender: nil)
  }
  
  private func createEvent() {
    guard let name = nameTextField.text where !name.isEmpty,
      let date = selectedDate,
      let list = list,
      let venue = venue,
      let location = location else {
        let errorMessage = "All fields are required to create event"
        displayError(errorMessage)
        
        return
    }
    
    // setup event configuration
    let eventConfiguration = EventConfiguration()
    if let minGuests = minGuestTextField.text {
      eventConfiguration.minimumGuests = Int(minGuests)
    }
    if let maxGuests = maxGuestTextField.text {
      eventConfiguration.maximumGuests = Int(maxGuests)
    }
    
    
    // use Groot for core location objects
    let JSONList = JSONDictionaryFromObject(list)
    let JSONVenue = JSONDictionaryFromObject(venue)
    
    // use ObjectMapper for regular models
    let JSONLocation = Mapper().toJSON(location)
    let JSONEventConfiguration = Mapper().toJSON(eventConfiguration)
    
    
    MeteorEventService.sharedInstance.create([ name, date, JSONList, JSONVenue, JSONLocation, JSONEventConfiguration ]) {
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


//MARK: - SelectListViewControllerDelegate

extension CreateEventViewController: SelectListViewControllerDelegate {
  
  func selectListViewControllerDidSelectList(list: List) {
    self.list = list
  }
}


//MARK: - SelectVenueViewControllerDelegate

extension CreateEventViewController: SelectVenueViewControllerDelegate {
  
  func selectVenueViewControllerDidSelectVenue(venue: Venue) {
    self.venue = venue
  }
}


//MARK: - PlacePickerViewControllerDelegate

extension CreateEventViewController: PlacePickerViewControllerDelegate {
  
  func placePickerDidSelectLocation(location: Location) {
    self.location = location
    
  }
  
}