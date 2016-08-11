//
//  InvitationManagerCollectionViewCell.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 8/2/16.
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

struct EventContactCollectionViewCellData {
  typealias NamedValues = [String:AnyObject]
  
  var name: String!
  var status: String!
  var score: Int!
  var addedToList: String!
  var invitation: Invitation?
  
  init(name: String, status: String, score: Int, addedToList: Double, invitation: Invitation?) {
    self.name = name
    self.status = status
    self.score = score
    self.addedToList = dateFormatter.stringFromDate(NSDate(timeIntervalSince1970: addedToList))
    self.invitation = invitation
  }
  
}

class InvitationManagerCollectionViewCell : UICollectionViewCell {
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var detailLabel: UILabel!
  @IBOutlet weak var timeRemainingLabel: UILabel!
  @IBOutlet weak var scoreButton: DesignableButton!
  
  var managedObjectContext: NSManagedObjectContext!
  private var invitationObserver: ManagedObjectObserver?
  
  var invitation: Invitation? {
    didSet {
      if invitation != oldValue {
        if invitation != nil {
          // start countdown and add observer
          invitation!.startCountdown()
          addInviteCountdownObserver()
          
          invitationObserver = ManagedObjectObserver(invitation!) { (changeType) -> Void in
            switch changeType {
            case .Deleted, .Invalidated:
              self.invitation = nil
            case .Updated, .Refreshed:
              self.invitationDidChange()
              break
            default:
              break
            }
          }
        } else {
          invitationObserver = nil
        }
        
        // make updates
        invitationDidChange()
      }
    }
  }
  
  deinit {
    if invitationObserver != nil {
      invitationObserver = nil
    }
    
    //stop countdown and remove the KVO in order to stop watching timer
    invitation?.stopCountdown()
    invitation?.removeObserver(self, forKeyPath: "readableTimeRemaining")
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    // clear out initially
    self.timeRemainingLabel.text = ""
  }
  
  private func addInviteCountdownObserver() {
    // set initial countdown value
    self.timeRemainingLabel.text = invitation?.readableTimeRemaining
    
    //set the KVO
    invitation?.addObserver(self, forKeyPath: "readableTimeRemaining", options: NSKeyValueObservingOptions.New, context: nil)
  }
  
  override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
    guard let readableTimeRemaining = invitation?.readableTimeRemaining else {
      return
    }
    print("remaining: \(readableTimeRemaining)")
    
    // time has updated so refresh time label
    if keyPath == "readableTimeRemaining" {
      self.timeRemainingLabel?.text? = readableTimeRemaining
      self.timeRemainingLabel?.setNeedsLayout()
    }
  }
  
  private func invitationDidChange() {
    updateInvitationData()
  }
  
  private func updateInvitationData() {
    guard let invitation = invitation else {
      return
    }
    
    //scoreButton.titleLabel?.text = invitation.sc
    
    // reload view
    //self.setNeedsDisplay()
  }
  
  func setData(data: Any?) {
    if let data = data as? EventContactCollectionViewCellData {
      self.nameLabel.text = data.name
      self.scoreButton.setTitle(String(data.score), forState: .Normal)
      
      // set invitation
      invitation = data.invitation
      
      // if we have an invitation
      if invitation != nil {
        if let status = Invitation.Status(rawValue: data.status) {
          switch status {
          case .Active:
            guard let updatedTime = invitation?.actionUpdated else { break }
            
            self.detailLabel.text = "Invited: " + dateFormatter.stringFromDate(NSDate(timeIntervalSince1970: updatedTime))
            break
          default:
            break
          }
        }
        
      }
      // if contact has not been invited, then show when they were added to the list instead
      else {
        self.detailLabel.text = "List Member Since: " + data.addedToList
      }
    }
  }
  
  
}