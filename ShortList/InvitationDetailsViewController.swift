//
//  InvitationDetailsViewController.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 7/24/16.
//  Copyright © 2016 Andrew Steinmeyer. All rights reserved.
//

import UIKit

class InvitationDetailsViewController: InvitationViewController {

  @IBOutlet weak var itsHappeningButton: InvitationSettingButton!
  @IBOutlet weak var maybeButton: InvitationSettingButton!
  
  @IBOutlet weak var nowButton: InvitationSettingButton!
  @IBOutlet weak var oneHourButton: InvitationSettingButton!
  @IBOutlet weak var laterButton: InvitationSettingButton!
  @IBOutlet weak var dateLabel: UILabel!
  
  @IBOutlet weak var locationTextField: UIMaterialTextField!
  @IBOutlet weak var detailsTextField: UIMaterialTextField!
  
  var statusButtonsArray: [InvitationSettingButton]!
  var timeButtonsArray: [InvitationSettingButton]!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // save status buttons
    statusButtonsArray = [itsHappeningButton, maybeButton]
    
    // save time buttons
    timeButtonsArray = [nowButton, oneHourButton, laterButton]
    
    setupTextFields()
  }
  
  private func setupTextFields() {
    locationTextField.TitleText.text = "Location"
    locationTextField.materialDelegate = self
    
    detailsTextField.TitleText.text = "Details"
    detailsTextField.materialDelegate = self
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
  }
  
  func setLocationField(name: String = "") {
    self.locationTextField.TitleText.text = name ?? "Location"
    self.locationTextField.text = eventDetails.location?.address ?? ""
  }
  
  private func selectVenue() {
    // present venue modal
    performSegueWithIdentifier("selectVenue", sender: nil)
  }
  
  private func createLocation() {
    performSegueWithIdentifier("showPlacePicker", sender: nil)
  }
  
  func presentVenueSelectionMenu() {
    let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
    alertController.addAction(cancelAction)
    
    let createContactAction = UIAlertAction(title: "Select Venue", style: UIAlertActionStyle.Default, handler: { _ in self.selectVenue() })
    alertController.addAction(createContactAction)
    
    let importContactsAction = UIAlertAction(title: "Create Location", style: .Default, handler: { _ in self.createLocation() })
    alertController.addAction(importContactsAction)
    
    presentViewController(alertController, animated: true, completion: nil)
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
    self.eventDetails.venue = venue
    
    setLocationField(venue.name ?? "")
  }
}

//MARK: - PlacePickerViewControllerDelegate

extension InvitationDetailsViewController: PlacePickerViewControllerDelegate {
  
  func placePickerDidSelectLocation(location: Location) {
    self.eventDetails.location = location
    
    setLocationField()
  }
  
}

