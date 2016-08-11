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
  var contactId: String!
  var status: String!
  var score: Int!
  var addedToList: String!
  var actionUpdated: String!
  var invitation: Invitation?
  
  init(name: String, id: String, status: String, score: Int, addedToList: Double?, actionUpdated: Double?, invitation: Invitation?) {
    self.name = name
    self.contactId = id
    self.status = status
    self.score = score
    self.invitation = invitation
    
    if let addedToListTime = addedToList {
      self.addedToList = dateFormatter.stringFromDate(NSDate(timeIntervalSince1970: addedToListTime))
    }
    
    if let updatedTime = actionUpdated {
     self.actionUpdated = dateFormatter.stringFromDate(NSDate(timeIntervalSince1970: updatedTime))
    }
  }
  
}

protocol InvitationManagerCollectionViewCellDelegate {
  func invitationManagerSkippedContact(contactId: String)
}

class InvitationManagerCollectionViewCell : UICollectionViewCell {
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var detailLabel: UILabel!
  @IBOutlet weak var timeRemainingLabel: UILabel!
  @IBOutlet weak var scoreButton: DesignableButton!
  
  var delegate: InvitationManagerCollectionViewCellDelegate?
  
  var originalCenter = CGPoint()
  var skipOnDragRelease = false
  
  var contactId: String?
  
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
    // remove observer
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
    
    // add gesture handler
    addPanGestureRecognizer()
  }
  
  private func addPanGestureRecognizer() {
    // add a pan recognizer
    let recognizer = UIPanGestureRecognizer(target: self, action: #selector(InvitationManagerCollectionViewCell.handlePan(_:)))
    recognizer.delaysTouchesBegan = true
    recognizer.delegate = self
    addGestureRecognizer(recognizer)
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
    
    // get status and time updated
    let status = invitation.status ?? ""
    let updatedTime = invitation.actionUpdated
    let readableTime = dateFormatter.stringFromDate(NSDate(timeIntervalSince1970: updatedTime))
    
    handleStatusUpdate(status, time: readableTime)
    
    // reload view
    self.setNeedsDisplay()
  }
  
  // populate cell with data
  func setData(data: Any?) {
    if let data = data as? EventContactCollectionViewCellData {
      self.nameLabel.text = data.name
      self.scoreButton.setTitle(String(data.score), forState: .Normal)
      
      // save contact id
      self.contactId = data.contactId
      
      // set invitation
      // there will not be an invitation until user invites the contact
      invitation = data.invitation
      
      guard invitation == nil else { return }
  
      // no invitation yet so display when user was added to list
      handleStatusUpdate(data.status, time: data.addedToList)
    }
  }
  
  func handleStatusUpdate(status: String, time: String) {
    // update appropriate status message
    if let status = Invitation.Status(rawValue: status) {
      switch status {
      case .Active:
        self.detailLabel.text = "Invited: \(time)"
      case .Skipped:
        self.detailLabel.text = "Skipped: \(time)"
      default:
        break
      }
    }
    // default to displaying when user was added to this list
    else {
        self.detailLabel.text = "List Member Since: \(time)"
    }
  }
  
  //MARK: - Horizontal pan gesture methods
  
  func handlePan(recognizer: UIPanGestureRecognizer) {
    // 1
    if recognizer.state == .Began {
      // when the gesture begins, record the current center location
      originalCenter = center
    }
    // 2
    if recognizer.state == .Changed {
      let translation = recognizer.translationInView(self)
      center = CGPointMake(originalCenter.x + translation.x, originalCenter.y)
      // has the user dragged the item far enough to initiate a delete/complete?
      skipOnDragRelease = frame.origin.x < -frame.size.width / 2.0
    }
    // 3
    if recognizer.state == .Ended {
      // the frame this cell had before user dragged it
      let originalFrame = CGRect(x: 0, y: frame.origin.y,
                                 width: bounds.size.width, height: bounds.size.height)
      
      // user panned far enough and wants to skip this contact
      if skipOnDragRelease {
        guard delegate != nil && contactId != nil else {
          return
        }
        
        // report back to collection view that we want to skip this contact
        delegate?.invitationManagerSkippedContact(contactId!)
        
        // return cell back to its normal position
        UIView.animateWithDuration(0.2, animations: {self.frame = originalFrame})
      }
      else {
        // if the item is not being deleted, snap back to the original location
        UIView.animateWithDuration(0.2, animations: {self.frame = originalFrame})
      }
    }
  }
}

extension InvitationManagerCollectionViewCell: UIGestureRecognizerDelegate {
  
  // do not handle vertical gestures, only horizontal
  override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
    if let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
      let translation = panGestureRecognizer.translationInView(superview!)
      if fabs(translation.x) > fabs(translation.y) {
        return true
      }
      return false
    }
    return false
  }
}