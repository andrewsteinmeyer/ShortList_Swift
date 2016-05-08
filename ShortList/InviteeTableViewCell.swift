//
//  InviteeTableViewCell.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 4/25/16.
//  Copyright © 2016 Andrew Steinmeyer. All rights reserved.
//

import UIKit

// Date format will be 2/11/16 3:30 PM
private let dateFormatter: NSDateFormatter = {
  let formatter = NSDateFormatter()
  formatter.dateStyle = .ShortStyle
  formatter.timeStyle = .ShortStyle
  
  return formatter
}()


struct InviteeTableViewCellData {
  typealias NamedValues = [String:AnyObject]
  
  var name: String!
  var invitation: Invitation!
  
  init(invitation: Invitation) {
    self.invitation = invitation
    
    // extract name from invitation
    if let contact = invitation.valueForKey("contact") as? NamedValues {
      let JSONContact = JSON(contact)
      self.name = JSONContact["name"].string ?? ""
    }
    
  }
  
}


class InviteeTableViewCell : BaseTableViewCell {
  
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var timeRemainingLabel: UILabel!
  
  var invitation: Invitation! {
    didSet {
      // start countdown and add observer
      invitation.startCountdown()
      addInviteCountdownObserver()
    }
  }
  
  deinit {
    //stop countdown and remove the KVO in order to stop watching timer
    invitation.stopCountdown()
    invitation.removeObserver(self, forKeyPath: "readableTimeRemaining")
  }
  
  override func setData(data: Any?) {
    if let data = data as? InviteeTableViewCellData {
      self.nameLabel.text = data.name
      
      // set invitation
      invitation = data.invitation
    }
  }
  
  private func addInviteCountdownObserver() {
    // set initial countdown value
    self.timeRemainingLabel.text = invitation.readableTimeRemaining
    
    //set the KVO
    invitation.addObserver(self, forKeyPath: "readableTimeRemaining", options: NSKeyValueObservingOptions.New, context: nil)
  }
  
  override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
    guard let readableTimeRemaining = invitation.readableTimeRemaining else { return }
    print("remaining: \(readableTimeRemaining)")
    
    // time has updated
    if keyPath == "readableTimeRemaining" {
      self.timeRemainingLabel?.text? = readableTimeRemaining
      self.timeRemainingLabel?.layer.setNeedsDisplay()
    }
  }
}
  
  
  