//
//  InvitationDetailsViewController.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 7/24/16.
//  Copyright © 2016 Andrew Steinmeyer. All rights reserved.
//

import UIKit
import SwiftDate
import BSKeyboardControls

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

class InvitationDetailsViewController: InvitationViewController {

  @IBOutlet weak var itsHappeningButton: InvitationSettingButton!
  @IBOutlet weak var maybeButton: InvitationSettingButton!
  
  @IBOutlet weak var nowButton: InvitationSettingButton!
  @IBOutlet weak var oneHourButton: InvitationSettingButton!
  @IBOutlet weak var laterButton: InvitationSettingButton!
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var timeLabel: UILabel!
  
  @IBOutlet weak var locationTextField: UIMaterialTextField!
  @IBOutlet weak var detailsTextField: UIMaterialTextField!
  
  var statusButtonsArray: [InvitationSettingButton]!
  var timeButtonsArray: [InvitationSettingButton]!
  var keyboardControls: BSKeyboardControls!
  
  private var popDatePicker: PopDatePicker?
  private var selectedDate: NSDate? {
    didSet {
      guard selectedDate != nil else {
        return
      }
      
      // set date and time labels
      dateLabel.text = dateFormatter.stringFromDate(selectedDate!) as String
      timeLabel.text = timeFormatter.stringFromDate(selectedDate!) as String
      
      // save date to details
      eventDetails?.date = selectedDate!
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // save status buttons
    statusButtonsArray = [itsHappeningButton, maybeButton]
    
    // save time buttons
    timeButtonsArray = [nowButton, oneHourButton, laterButton]
    
    // setup popup date picker
    popDatePicker = PopDatePicker(forButton: laterButton)
    
    // default event start time to five minutes fromNow
    selectedDate = 5.minutes.fromNow
    
    setupTextFields()
    populateEventSettings()
  }
  
  private func setupTextFields() {
    locationTextField.TitleText.text = "Location"
    locationTextField.materialDelegate = self
    
    detailsTextField.TitleText.text = "Details"
    detailsTextField.materialDelegate = self
    
    setupKeyboardControls()
  }
  
  // populate existing settings
  override func populateEventSettings() {
    guard eventDetails != nil else { return }
    
    // set location with venue if venue exists
    if let venue = eventDetails?.venue {
      setLocationField(venue.name)
    }
    // otherwise see if location exists
    else if eventDetails?.location != nil {
      setLocationField("Location")
    }
    
    if let date = eventDetails.date {
      self.selectedDate = date
    }
    
    // set status button
    let selectedButton = statusButtonsArray.filter { $0.tag == eventDetails.configuration.currentStatus.rawValue }
    selectedButton.first?.selectButton()
    
    // set start time button
    let selectedTimeButton = timeButtonsArray.filter { $0.tag == eventDetails.startTime.rawValue }
    selectedTimeButton.first?.selectButton()
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if let identifier = segue.identifier {
      if identifier == "showPlacePicker" {
        let placePickerViewController = segue.destinationViewController as! PlacePickerViewController
        placePickerViewController.delegate = self
      }
      else if identifier == "selectVenue" {
        let venueNavigationController = segue.destinationViewController as! VenuesNavigationViewController
        let selectVenueViewController = venueNavigationController.topViewController as! SelectVenueViewController
        selectVenueViewController.delegate = self
        selectVenueViewController.selectedVenue = self.eventDetails.venue
      }
    }
  }
  
  private func toggleStatusButtons(sender: InvitationSettingButton) {
    let unselectedButtons = statusButtonsArray.filter( { $0.tag != sender.tag } )
    
    // unselect other buttons
    for button in unselectedButtons {
      button.unselectButton()
    }
    
    // select the correct status button
    sender.selectButton()
  }
  
  private func toggleTimeButtons(sender: InvitationSettingButton) {
    let unselectedButtons = timeButtonsArray.filter( { $0.tag != sender.tag } )
    
    // unselect other buttons
    for button in unselectedButtons {
      button.unselectButton()
    }
    
    // select the correct time button
    sender.selectButton()
    
    // set date based upon user selection
    if let eventStartTime = EventDetails.EventStartTime(rawValue: sender.tag) {
      switch eventStartTime {
      case .Now:
        selectedDate = 5.minutes.fromNow
      case .OneHour:
        selectedDate = 1.hours.fromNow
      case .Later:
        presentDatePicker()
      }
      
      // save enum for startTime
      eventDetails.startTime = eventStartTime
    }
  }
  
  private func setLocationField(title: String?) {
    self.locationTextField.TitleText.text = title ?? "Location"
    self.locationTextField.text = eventDetails.location?.address ?? ""
  }
  
  private func selectVenue() {
    performSegueWithIdentifier("selectVenue", sender: nil)
  }
  
  private func createLocation() {
    performSegueWithIdentifier("showPlacePicker", sender: nil)
  }
  
  private func setupKeyboardControls() {
    let fields = [self.detailsTextField]
    self.keyboardControls = BSKeyboardControls(fields: fields)
    self.keyboardControls.delegate = self
  }
  
  private func presentDatePicker() {
    // show previously selected date if there is one
    // default to current date/time
    let initDate = ( selectedDate != nil ? selectedDate : NSDate() )
    
    let dataChangedCallback : PopDatePicker.PopDatePickerCallback = { [weak self]
      (newDate : NSDate, forButton : UIButton) -> () in
      
      if let strongSelf = self {
        strongSelf.selectedDate = newDate
      }
    }
    
    popDatePicker!.pick(self, initDate: initDate, dataChanged: dataChangedCallback)
  }
  
  private func presentVenueSelectionMenu() {
    let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
    alertController.addAction(cancelAction)
    
    let createContactAction = UIAlertAction(title: "Select Venue", style: UIAlertActionStyle.Default, handler: { _ in self.selectVenue() })
    alertController.addAction(createContactAction)
    
    let importContactsAction = UIAlertAction(title: "Create Location", style: .Default, handler: { _ in self.createLocation() })
    alertController.addAction(importContactsAction)
    
    presentViewController(alertController, animated: true, completion: nil)
  }
  
  private func dismissKeyboard() {
    self.view.endEditing(true)
  }

  // MARK: - IBActions
  
  @IBAction func statusButtonDidPress(sender: InvitationSettingButton) {
    // user selected status for event
    if let status = EventConfiguration.Status(rawValue: sender.tag) {
      self.eventDetails.configuration.currentStatus = status
    }
    
    // update highlighted button
    toggleStatusButtons(sender)
  }
  
  @IBAction func timeButtonDidPress(sender: InvitationSettingButton) {
    // user selected date for event
    if let status = EventConfiguration.Status(rawValue: sender.tag) {
      self.eventDetails.configuration.currentStatus = status
    }
    
    // update highlighted button
    toggleTimeButtons(sender)
  }
  
}

// MARK: UIMaterialTextFieldDelegate

extension InvitationDetailsViewController: UIMaterialTextFieldDelegate {
  
  func materialTextFieldShouldBeginEditing(textField: UITextField) -> Bool {
    if textField == locationTextField {
      // stop keyboard from showing
      self.view.endEditing(true)
      
      presentVenueSelectionMenu()
      return false
    }
    
    return true
  }
  
  func materialTextFieldDidBeginEditing(textField: UITextField) {
    self.keyboardControls.activeField = textField
  }
  
  func materialTextFieldShouldEndEditing(textField: UITextField) -> Bool {
    switch textField {
    case detailsTextField:
      return true
    default: ()
    }
    
    return true
  }
  

}

//MARK: - SelectVenueViewControllerDelegate

extension InvitationDetailsViewController: SelectVenueViewControllerDelegate {
  
  func selectVenueViewControllerDidSelectVenue(venue: Venue) {
    // save venue
    self.eventDetails.venue = venue
    
    // update location text field
    setLocationField(venue.name ?? "Location")
  }
}

// MARK: - KeyboardControls Delegate

extension InvitationDetailsViewController: BSKeyboardControlsDelegate {
  
  func keyboardControlsDonePressed(keyboardControls: BSKeyboardControls!) {
    self.dismissKeyboard()
  }
}

//MARK: - PlacePickerViewControllerDelegate

extension InvitationDetailsViewController: PlacePickerViewControllerDelegate {
  
  func placePickerDidSelectLocation(location: Location?) {
    // dismiss the place picker
    self.dismissViewControllerAnimated(true, completion: nil)
    
    guard location != nil else { return }
    
    // save location and update location text field
    self.eventDetails.location = location
    setLocationField("Location")
  }
  
}

