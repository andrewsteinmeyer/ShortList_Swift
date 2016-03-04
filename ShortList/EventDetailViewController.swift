//
//  EventDetailViewController.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 1/9/16.
//  Copyright © 2016 Andrew Steinmeyer. All rights reserved.
//

import UIKit
import ObjectMapper

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

class EventDetailViewController: UIViewController {
  typealias NamedValues = [String:AnyObject]
  
  @IBOutlet weak var nameTextField: UIMaterialTextField!
  @IBOutlet weak var dateTextField: UIMaterialTextField!
  @IBOutlet weak var timeTextField: UIMaterialTextField!
  @IBOutlet weak var listTextField: UIMaterialTextField!
  @IBOutlet weak var venueTextField: UIMaterialTextField!
  @IBOutlet weak var locationTextField: UIMaterialTextField!
  @IBOutlet weak var minGuestTextField: UIMaterialTextField!
  @IBOutlet weak var maxGuestTextField: UIMaterialTextField!
  
  var event: Event?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    populateEventFields()
  }
  
  func populateEventFields() {
    guard let event = event else {
      return
    }
    
    //TODO: Do we need to check valueForKey for name, date and eventConfiguration???
    
    // set name
    nameTextField.text = event.name
    
    // set date and time
    let timeInterval = event.date
    let date = NSDate(timeIntervalSince1970: timeInterval)
    
    dateTextField.text = dateFormatter.stringFromDate(date) as String
    timeTextField.text = timeFormatter.stringFromDate(date) as String
    
    // set list name
    if let list = event.valueForKey("list") as? NamedValues {
      let JSONList = JSON(list)
      
      if let listName = JSONList["name"].string {
        listTextField.text = listName
      }
    }
    
    // set venue name and location
    if let venue = event.valueForKey("venue") as? NamedValues {
      let JSONVenue = JSON(venue)
      
      if let venueName = JSONVenue["name"].string {
        venueTextField.text = venueName
      }
      
      // set venue's address
      if let venueAddress = JSONVenue["location"]["address"].string {
        locationTextField.text = venueAddress
      }
      
      // TODO: this is here now to unwrap address from web.  
      // Tim stores just the address string on Web (need to store location object)
      // Android and iOS store the entire location.
      if let venueAddress2 = JSONVenue["location"].string {
        locationTextField.text = venueAddress2
      }
    }
    
    // set location address
    if let location = event.valueForKey("location") as? NamedValues {
      let JSONLocation = JSON(location)
      
      if let locationAddress = JSONLocation["address"].string {
        locationTextField.text = locationAddress
      }
    }
    
    // set event configuration
    if let config = event.eventConfiguration {
      
      // build event config object from JSON
      let eventConfiguration = Mapper<EventConfiguration>().map(config)
      
      // extract min and max guests
      if let minGuests = eventConfiguration?.minimumGuests {
        minGuestTextField.text = minGuests
      }
      if let maxGuests = eventConfiguration?.maximumGuests {
        maxGuestTextField.text = maxGuests
      }
    }
  }
  
  func inviteContacts() {
    guard let event = self.event else {
      return
    }
    
    // get documentID for event
    let documentID = Meteor.documentKeyForObjectID(event.objectID).documentID
    
    // TODO: make this not random all the time
    MeteorEventService.sharedInstance.invite([documentID, "random"]) { result, error in
      dispatch_async(dispatch_get_main_queue()) {
        
        if error != nil {
          if let failureReason = error?.localizedFailureReason {
            AppDelegate.getAppDelegate().showMessage(failureReason)
            print("error: \(failureReason)")
          }
        } else {
          print("success: contacts invited")
          self.dismissViewControllerAnimated(true, completion: nil)
        }
      }
    }
    
  }
  
  // MARK: - IBAction methods
  
  @IBAction func showInviteMenu(sender: AnyObject) {
    let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
    alertController.addAction(cancelAction)
    
    let inviteAction = UIAlertAction(title: "Invite Contacts", style: UIAlertActionStyle.Default, handler: { _ in self.inviteContacts() })
    alertController.addAction(inviteAction)
    
    presentViewController(alertController, animated: true, completion: nil)
  }

  @IBAction func closeButtonDidPress(sender: AnyObject) {
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
}
