//
//  EventDetailViewController.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 1/9/16.
//  Copyright © 2016 Andrew Steinmeyer. All rights reserved.
//

import UIKit

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
    
    // set name
    nameTextField.text = event.name
  
    // set date and time
    if let date = event.date {
      dateTextField.text = dateFormatter.stringFromDate(date) as String
      timeTextField.text = timeFormatter.stringFromDate(date) as String
    }
    
    // set list name
    if let list = event.list {
      let JSONList = JSON(list)
      
      if let listName = JSONList["name"].string {
        listTextField.text = listName
      }
    }
    
    // set venue name
    if let venue = event.venue {
      let JSONVenue = JSON(venue)
      
      if let venueName = JSONVenue["name"].string {
        venueTextField.text = venueName
      }
    }
    
    // set location address
    if let location = event.location {
      let JSONLocation = JSON(location)
      
      if let locationAddress = JSONLocation["address"].string {
        locationTextField.text = locationAddress
      }
    }
  }
  
  func inviteContacts() {
    guard let event = self.event else {
      return
    }
    
    // get documentID for event
    let documentID = Meteor.documentKeyForObjectID(event.objectID).documentID
    
    MeteorEventService.sharedInstance.invite([documentID, "random"]) {
      result, error in
      
      if error != nil {
        print("error: \(error?.localizedDescription)")
      } else {
        print("success: contacts invited")
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

  
}
