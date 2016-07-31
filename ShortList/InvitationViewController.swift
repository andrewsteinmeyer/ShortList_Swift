//
//  InvitationViewController.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 7/27/16.
//  Copyright © 2016 Andrew Steinmeyer. All rights reserved.
//

import UIKit

protocol InvitationViewControllerDelegate: class {
  func invitationViewControllerDidUpdateEventDetails()
}

// parent shell class for Invitation View Controllers
class InvitationViewController: UIViewController {

  var eventDetails: EventDetails!
  weak var delegate: CreateInvitationViewController?
  
  // parent shell function
  func populateEventSettings() {
    
  }

}
