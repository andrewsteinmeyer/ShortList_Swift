//
//  CreateInvitationViewController.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 7/18/16.
//  Copyright © 2016 Andrew Steinmeyer. All rights reserved.
//

import UIKit
import ObjectMapper
import Groot

class CreateInvitationViewController: UIViewController {
  
  @IBOutlet weak var invitationProgressView: InvitationProgressView!
  @IBOutlet weak var containerView: UIView!
  @IBOutlet weak var actionButton: DesignableButton!
  
  // controller being displayed in the containerView
  weak var currentViewController: InvitationViewController?
  var settingsViewController: InvitationSettingsViewController!
  var detailsViewController: InvitationDetailsViewController!
  
  var eventDetails: EventDetails!
  
  enum ButtonType: Int {
    case Settings
    case Details
    
    private var AssociatedViewControllerName: String {
      switch self {
      case .Settings: return "InvitationSettingsViewController"
      case .Details:  return "InvitationDetailsViewController"
      }
    }
  }
  
  private var currentScreen: ButtonType = .Settings {
    didSet {
      if currentScreen == ButtonType.Settings {
        actionButton.setTitle("Next", forState: .Normal)
        actionButton.setNeedsLayout()
      }
      else if currentScreen == ButtonType.Details {
        actionButton.setTitle("Create Event", forState: .Normal)
        actionButton.setNeedsLayout()
      }
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // initialize event details object
    self.eventDetails = EventDetails()
    
    // initialize child view controllers
    settingsViewController = self.storyboard?.instantiateViewControllerWithIdentifier(ButtonType.Settings.AssociatedViewControllerName) as! InvitationSettingsViewController
    detailsViewController = self.storyboard?.instantiateViewControllerWithIdentifier(ButtonType.Details.AssociatedViewControllerName) as! InvitationDetailsViewController
    
    // set this controller as the delegate
    invitationProgressView.delegate = self
    
    // populate container view with invitation settings
    populateContainerView()
  }
  
  private func populateContainerView() {
    self.currentViewController = settingsViewController
    self.currentViewController!.delegate = self
    self.currentViewController?.eventDetails = self.eventDetails
    self.currentViewController?.view.translatesAutoresizingMaskIntoConstraints = false
    self.addChildViewController(self.currentViewController!)
    self.addSubview(self.currentViewController!.view, toView: self.containerView)
  }
  
  private func addSubview(subView:UIView, toView parentView:UIView) {
    parentView.addSubview(subView)
    
    // set view constraints
    subView.leadingAnchor.constraintEqualToAnchor(parentView.leadingAnchor).active = true
    subView.trailingAnchor.constraintEqualToAnchor(parentView.trailingAnchor).active = true
    subView.topAnchor.constraintEqualToAnchor(parentView.topAnchor).active = true
    subView.bottomAnchor.constraintEqualToAnchor(parentView.bottomAnchor).active = true
  }
  
  private func cycleFromViewController(oldViewController: UIViewController, toViewController newViewController: UIViewController) {
    oldViewController.willMoveToParentViewController(nil)
    self.addChildViewController(newViewController)
    self.addSubview(newViewController.view, toView:self.containerView!)
    newViewController.view.alpha = 0
    newViewController.view.layoutIfNeeded()
    UIView.animateWithDuration(0, animations: {
      newViewController.view.alpha = 1
      oldViewController.view.alpha = 0
      },
           completion: { finished in
            oldViewController.view.removeFromSuperview()
            oldViewController.removeFromParentViewController()
            newViewController.didMoveToParentViewController(self)
    })
  }
  
  private func proceedToController(newViewController: InvitationViewController) {
    newViewController.delegate = self
    newViewController.eventDetails = self.eventDetails
    newViewController.view.translatesAutoresizingMaskIntoConstraints = false
    self.cycleFromViewController(self.currentViewController!, toViewController: newViewController)
    self.currentViewController = newViewController
  }
  
  private func validateFields() {
    switch self.currentScreen {
    case .Settings:
      if eventDetails.settingsVerified() {
        invitationProgressView.proceedToDetails()
      }
      else {
        let message = "Please select a list in order to proceed."
        AppDelegate.getAppDelegate().showMessage(message, title: "Invitation Settings")
      }
    case .Details:
      if eventDetails.detailsVerified() {
        createEvent()
      }
      else {
        let message = "Please select a date and location to proceed."
        AppDelegate.getAppDelegate().showMessage(message, title: "Invitation Details")
      }
    }
  }
  
  private func createEvent() {
    guard let date = eventDetails.date,
      let list = eventDetails.list,
      let location = eventDetails.location else {
        
        let message = "Please fill out all required fields."
        AppDelegate.getAppDelegate().showMessage(message, title: "Could Not Create Event")
        return
    }
    
    // dismiss keyboard
    self.dismissKeyboard()
    
    let eventName = eventDetails?.title ?? ""
    let eventConfiguration = eventDetails.configuration
    
    // use Groot for core location objects
    let listID = Meteor.documentKeyForObjectID(list.objectID).documentID
    var JSONList = JSONDictionaryFromObject(list)
    JSONList["_id"] = listID
    
    var JSONVenue: JSONDictionary = [:]
    
    // set venue data if one exists
    if let venue = eventDetails.venue {
      let venueID = Meteor.documentKeyForObjectID(venue.objectID).documentID
      JSONVenue = JSONDictionaryFromObject(venue)
      JSONVenue["_id"] = venueID
    }
    
    // use ObjectMapper for regular models
    let JSONLocation = Mapper().toJSON(location)
    let JSONEventConfiguration = Mapper().toJSON(eventConfiguration)
    
    // format date to play nice with web and android epoch unix
    let epochDate = date.convertToEpochMilliseconds()
    
    MeteorEventService.sharedInstance.create([ eventName, epochDate, JSONList, JSONVenue, JSONLocation, JSONEventConfiguration ]) {
      result, error in
      
      dispatch_async(dispatch_get_main_queue()) {
        if let error = error {
          let errorMessage = error.localizedFailureReason
          AppDelegate.getAppDelegate().showMessage(errorMessage!, title: "Error")
        } else {
          self.dismissViewControllerAnimated(true, completion: nil)
        }
      }
    }
  }
  
  private func dismissKeyboard() {
    self.view.endEditing(true)
  }
  
  // MARK: - IBAction methods
  
  @IBAction func actionButtonDidPress(sender: AnyObject) {
    validateFields()
  }
  
}

extension CreateInvitationViewController: InvitationProgressViewDelegate {
  
  func invitationProgressViewDidPressButton(buttonType: Int) {
    if let type = ButtonType(rawValue: buttonType) {
      switch type {
      case .Settings:
        if self.currentScreen == .Details {
          self.proceedToController(settingsViewController)
        }
      case .Details:
        if self.currentScreen == .Settings {
          self.proceedToController(detailsViewController)
        }
      }
      
      // set the current screen type
      self.currentScreen = type
    }
  }
}

extension CreateInvitationViewController: InvitationViewControllerDelegate {
  
  func invitationViewControllerDidUpdateEventDetails() {
    // unlock details if user has selected a list
    if self.currentScreen == .Settings {
      if eventDetails.list != nil {
        self.invitationProgressView.detailsButton.enabled = true
      }
    }
  }
}


