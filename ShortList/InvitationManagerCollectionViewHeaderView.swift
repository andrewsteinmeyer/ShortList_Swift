//
//  InvitationManagerCollectionViewHeaderView.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 8/2/16.
//  Copyright © 2016 Andrew Steinmeyer. All rights reserved.
//

import UIKit



class InvitationManagerCollectionViewHeaderView: UICollectionReusableView {
  typealias NamedValues = [String:AnyObject]
  
  @IBOutlet weak var autoInviteButton: DesignableButton!
  @IBOutlet weak var eventTitleLabel: UILabel!
  @IBOutlet weak var detailsTextView: UITextView!
  
  weak var delegate: InvitationManagerDelegate?
  
  enum AutoInviteStatus: Int {
    case NotStarted
    case InProgress
  }
  
  var currentStatus: AutoInviteStatus = .NotStarted
  
  var managedObjectContext: NSManagedObjectContext!
  private var eventObserver: ManagedObjectObserver?
  
  var event: Event? {
    didSet {
      if event != oldValue {
        if event != nil {
          eventObserver = ManagedObjectObserver(event!) { (changeType) -> Void in
            switch changeType {
            case .Deleted, .Invalidated:
              self.event = nil
            case .Updated, .Refreshed:
              self.eventDidChange()
              break
            default:
              break
            }
          }
        } else {
          eventObserver = nil
        }
        
        // make updates
        eventDidChange()
      }
    }
  }
  
  deinit {
    if eventObserver != nil {
      eventObserver = nil
    }
  }
  
  private func eventDidChange() {
    updateEventStats()
  }
  
  private func updateEventStats() {
    guard let event = self.event else { return }
    
    //TODO: Need to add invitationsSent to Event object in CoreData
    //      Have added before, but it crashes because of NSNull values from server
    //      Need to figure out how to handle NSNull values with CoreData
    //      Or get Tim to change on server for time being.
    
    // Need to check to see if we have sent invitations
    // Check by looking at the value of event.invitationsSent
    // Need to add that value to the Event object, but can't right now (See note above)
    //if let inviteStatus = event.invi
    
    // set event name
    if let eventName = event.name where eventName != "" {
      eventTitleLabel.text = eventName
    }
    // default to list name if no event name is provided
    else if let list = event.valueForKey("list") as? NamedValues {
      let JSONList = JSON(list)
      
      let listName = JSONList["name"].string ?? ""
      eventTitleLabel.text = listName
    }
    
    // reload view
    //self.setNeedsDisplay()
  }
  
  // MARK: - IBAction Methods
  
  @IBAction func didPressAutoInviteButton(sender: AnyObject) {
    switch currentStatus {
    case .NotStarted:
      delegate?.invitationManagerDidStartAutoInvite()
      currentStatus = .InProgress
      
      autoInviteButton.setTitle("Cancel", forState: .Normal)
      autoInviteButton.backgroundColor = Theme.InvitationCancelButtonColor.toUIColor()
      //detailsTextView.text = "Invitations sent: "
      
      animateViews([detailsTextView], toHidden: true)
      
    case .InProgress:
      delegate?.invitationManagerDidCancelAutoInvite()
      currentStatus = .NotStarted
      
      autoInviteButton.setTitle("Auto Invite", forState: .Normal)
      autoInviteButton.backgroundColor = Theme.InvitationInviteButtonColor.toUIColor()
    }
    
  }
  
  // MARK: - Hide/unhide stack views with animation
  
  private func animateViews(views: [UIView], toHidden hidden: Bool) {
    UIView.animateWithDuration(0.8, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 10, options: UIViewAnimationOptions(), animations: { () -> Void in
      let _ = views.map { $0.hidden = hidden }
      }, completion: nil)
  }
  
  
}