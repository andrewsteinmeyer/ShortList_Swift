//
//  InvitationManagerDetailCollectionViewSectionHeader.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 8/1/16.
//  Copyright © 2016 Andrew Steinmeyer. All rights reserved.
//



class InvitationManagerCollectionViewSectionHeader: UICollectionReusableView {
  
  @IBOutlet weak var totalCountLabel: UILabel!
  @IBOutlet weak var invitedCountLabel: UILabel!
  @IBOutlet weak var acceptedCountLabel: UILabel!
  @IBOutlet weak var declinedCountLabel: UILabel!
  @IBOutlet weak var skippedCountLabel: UILabel!
  @IBOutlet weak var timeoutCountLabel: UILabel!
  
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
              // TODO: Example updated here and below, this one seems redundant.  Think this through
              // self.eventDidChange()
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
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    // add a line to the bottom of the section header view
    let lineLayer = CALayer()
    lineLayer.frame = CGRectMake(0, self.bounds.height - 1, self.bounds.width, 0.5)
    lineLayer.backgroundColor = UIColor.lightGrayColor().CGColor
    self.layer.addSublayer(lineLayer)
  }
  
  private func eventDidChange() {
    updateEventStats()
    
    //TODO: Do we need to refresh the view with setNeedsLayout() or does the view update
    //      due to the ObjectObserver???
    //      Test this by watching screen and inviting someone on web.
  }
  
  private func updateEventStats() {
    guard let event = self.event else { return }
    
    //TODO : Set invitedCount, skippedCount
    // need to aggregate these somehow off of list.contacts
    // do not want to make a separate call to query each invitationId for each invited Contact
    // that is too many calls over the wire for a sum.  maybe put invitedCount and skippted count on Event
    
    totalCountLabel.text = String(event.contactCount!) ?? "0"
    acceptedCountLabel.text = String(event.acceptedCount!) ?? "0"
    declinedCountLabel.text = String(event.declinedCount!) ?? "0"
    timeoutCountLabel.text = String(event.timeoutCount!) ?? "0"
  }
  
}