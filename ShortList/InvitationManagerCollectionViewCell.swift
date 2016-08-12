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

/*!
 * Protocol used to report Invitation Actions back to delegate
 */
protocol InvitationManagerCollectionViewCellDelegate {
  func invitationManagerDidSkipContact(contactId: String)
  func invitationManagerDidInviteContact(contactId: String)
}

class InvitationManagerCollectionViewCell : UICollectionViewCell {
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var detailLabel: UILabel!
  @IBOutlet weak var timeRemainingLabel: UILabel!
  @IBOutlet weak var scoreButton: DesignableButton!
  @IBOutlet weak var activityIcon: UIImageView!
  
  var delegate: InvitationManagerCollectionViewCellDelegate?
  
  var originalCenter = CGPoint()
  var skipOnDragRelease = false
  var inviteOnDragRelease = false
  
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
  
  // MARK: - View lifecycle and setup
  
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
    
    clearInvitationTimer()

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
      
      //TODO: Figure out a better way to handle when an invite has not been sent
      
      // handle when no invitation has been sent yet
      guard invitation == nil else { return }
  
      // no invite means nothing has been sent 
      // or the user skipped the contact
      let time = (data.status == "skipped") ? data.actionUpdated : data.addedToList
      
      handleStatusUpdate(data.status, time: time)
    }
  }
  
  // MARK: - Invitation Actions
  
  private func skipContact() {
    guard delegate != nil && contactId != nil else {
      return
    }
    
    updateActivityIconWithStatus(.Skipped)
  
    // report back to collection view that we want to skip this contact
    delegate?.invitationManagerDidSkipContact(contactId!)
  }
  
  private func inviteContact() {
    guard delegate != nil && contactId != nil else {
      return
    }
    
    updateActivityIconWithStatus(.Active)
    
    // report back to collection view that we want to invite this contact
    delegate?.invitationManagerDidInviteContact(contactId!)
  }
  
  // MARK: - Invitation Updates
  
  private func invitationDidChange() {
    updateInvitationData()
  }
  
  private func updateInvitationData() {
    guard let invitation = invitation else {
      return
    }
    
    // get status and time updated
    let status = invitation.status ?? ""
    let updatedTime = status == "active" ? invitation.insertedOn : invitation.actionUpdated
    let readableTime = dateFormatter.stringFromDate(NSDate(timeIntervalSince1970: updatedTime))
    
    handleStatusUpdate(status, time: readableTime)
    
    // refresh collection view cell
    self.setNeedsDisplay()
  }
  
  func handleStatusUpdate(status: String, time: String) {
    // update appropriate status message
    if let status = Invitation.Status(rawValue: status) {
      switch status {
      case .Active:
        self.detailLabel.text = "\(status.labelMessage): \(time)"
      case .Accepted, .Skipped, .Declined:
        self.detailLabel.text = "\(status.labelMessage): \(time)"
        stopInvitationTimer()
        updateActivityIconWithStatus(status)
      default:
        break
      }
    }
    // default to displaying when user was added to this list
    else {
      self.detailLabel.text = "List Member Since: \(time)"
    }
  }
  
  func updateActivityIconWithStatus(status: Invitation.Status) {
    switch status {
    case .Active:
      self.activityIcon.image = UIImage(named: "sand-timer")
      let timerImage = activityIcon.image?.imageWithColor(Theme.InvitationActivityIconTintColor.toUIColor())
      activityIcon.image = timerImage
    case .Accepted:
      self.activityIcon.image = UIImage(named: "invite-accepted")
      let acceptedImage = activityIcon.image?.imageWithColor(Theme.InvitationActivityIconTintColor.toUIColor())
      activityIcon.image = acceptedImage
    case .Skipped:
      self.activityIcon.image = UIImage(named: "skip-arrow")
      let skipImage = activityIcon.image?.imageWithColor(Theme.InvitationActivityIconTintColor.toUIColor())
      activityIcon.image = skipImage
    case .Declined:
      self.activityIcon.image = UIImage(named: "invite-declined")
      let declinedImage = activityIcon.image?.imageWithColor(Theme.InvitationActivityIconTintColor.toUIColor())
      activityIcon.image = declinedImage
    default:
      break
    }
    
    // update activity icon with animation
    animateViews([activityIcon], toHidden: false)
  }
  
  // MARK: - Invitation Countdown Timer
  
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
    //print("remaining: \(readableTimeRemaining)")
    
    // time has updated so refresh time label
    if keyPath == "readableTimeRemaining" {
      self.timeRemainingLabel?.text? = readableTimeRemaining
      self.timeRemainingLabel?.setNeedsLayout()
    }
  }
  
  private func stopInvitationTimer() {
    if let invitation = invitation {
      invitation.stopCountdown()
    }
    
    clearInvitationTimer()
  }
  
  private func clearInvitationTimer() {
    self.timeRemainingLabel.text = ""
  }
  
  // MARK: - Horizontal pan gesture methods
  
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
      inviteOnDragRelease = frame.origin.x > frame.size.width / 2.0
    }
    // 3
    if recognizer.state == .Ended {
      // the frame this cell had before user dragged it
      let originalFrame = CGRect(x: 0, y: frame.origin.y,
                                 width: bounds.size.width, height: bounds.size.height)
      
      // user panned far enough and wants to skip this contact
      if skipOnDragRelease {
        skipContact()
      }
        // user panned far enough and wants to invite this contact
      else if inviteOnDragRelease {
        inviteContact()
      }
      
      // snap cell frame back to original position
      UIView.animateWithDuration(0.2, animations: {self.frame = originalFrame})
    }
  }
  
  // MARK: - Hide/unhide views with animation
  
  private func animateViews(views: [UIView], toHidden hidden: Bool) {
    UIView.animateWithDuration(0.8, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 10, options: UIViewAnimationOptions(), animations: { () -> Void in
      let _ = views.map { $0.hidden = hidden }
      }, completion: nil)
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