//
//  EventDetailCollectionViewController.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 3/25/16.
//  Copyright © 2016 Andrew Steinmeyer. All rights reserved.
//

import CoreData
import PhoneNumberKit

class EventDetailCollectionViewController: UICollectionViewController {
  typealias NamedValues = [String:AnyObject]
  typealias Contacts = [String:String]
  
  private var contacts = [Contacts]()
  
  private var isEventOwner = false
  
  // MARK: - Model
  
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

  
  // MARK: - View Lifecycle
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    // refresh
    updateViewWithModel()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // set CoreData context
    self.managedObjectContext = Meteor.mainQueueManagedObjectContext
    
    // setup sticky header layout
    reloadLayout()
    
    // Register cell classes
    let headerViewNib = UINib(nibName: Constants.EventDetailCollection.HeaderViewIdentifier, bundle: nil)
    self.collectionView?.registerNib(headerViewNib, forSupplementaryViewOfKind: CSStickyHeaderParallaxHeader, withReuseIdentifier: Constants.EventDetailCollection.HeaderViewIdentifier)
  }
  
  // MARK: - Updating View
  
  private func updateViewWithModel() {
    guard let event = event else { return }
    
    // determine if user is event owner
    isEventOwner = (event.userId == AccountManager.defaultAccountManager.currentUserId) ? true : false
    
    // user is attendee
    if !isEventOwner {
      // reset contact list
      contacts = []
      
      // retrieve list data from event
      if let list = event.valueForKey("list") as? NamedValues {
        let JSONList = JSON(list)
        
        // retrieve contacts from list data
        for (_,contact):(String, JSON) in JSONList["contacts"] {
          
          let name = contact["name"].string ?? ""
          let score = contact["score"].int ?? 0
          
          // make sure there is at least a name for the contact
          guard !name.isEmpty else { continue }
          
          // build contact
          let newContact = ["name": name,
                            "score": String(score)]
          
          // add contact to list
          contacts.append(newContact)
        }
      }
    }
    
    // refresh data
    collectionView?.reloadData()
  }
  
  private func eventDidChange() {
    if isViewLoaded() {
      
      // refresh view if loaded
      updateViewWithModel()
    }
  }
  
  private func reloadLayout() {
    // set header size and item size
    if let layout = self.collectionViewLayout as? CSStickyHeaderFlowLayout {
      // enable lines between cells
      layout.enableDecorationView = true
      layout.minimumLineSpacing = 0.50
      
      layout.parallaxHeaderReferenceSize = CGSizeMake(self.view.frame.width, Constants.EventDetailCollection.HeaderViewHeight)
      layout.itemSize = CGSizeMake(self.view.frame.width, layout.itemSize.height)
      layout.disableStickyHeaders = false
    }
  }
  
  // MARK: - Segue
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if (segue.identifier == "showInviteeDetails") {
      let indexPath = sender as! NSIndexPath
      let category = EventInvitation.Status.categories[indexPath.row]
      
      /*
      let guestListVC = segue.destinationViewController as! GuestListTableViewController
      guestListVC.event = event
      guestListVC.selectedCategory = category
      guestListVC.navigationController?.title = category.uppercaseString
      */
      
      // get documentID for event
      let eventId = Meteor.documentKeyForObjectID(event!.objectID).documentID as! String
      
      let invitationsVC = segue.destinationViewController as! EventInvitationsViewController
      invitationsVC.statusCategory = category
      invitationsVC.eventId = eventId
    }
    
  }
  
  // MARK: - Helper methods
  
  private func getCountForCategory(category: String) -> Int {
    guard let event = event else { return 0 }
    
    if let status = EventInvitation.Status(rawValue: category) {
      switch status {
      case .Active:
        return Int(event.contactCount!) ?? 0
      case .Accepted:
        return Int(event.acceptedCount!) ?? 0
      case .Declined:
        return Int(event.declinedCount!) ?? 0
      case .Timeout:
        return Int(event.timeoutCount!) ?? 0
      default:
        return 0
      }
    }
    
    return 0
  }
  
  // MARK: - UICollectionViewDataSource
  
  override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    return 1
  }
  
  override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    // if event owner, display status categories
    // otherwise, only display names of guests that have accepted an invitation
    return (isEventOwner ? EventInvitation.Status.categories.count : contacts.count)
  }
  
  override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    // if event owner, display the status categories
    if isEventOwner {
      let cell = collectionView.dequeueReusableCellWithReuseIdentifier(Constants.EventDetailCollection.CategoryCellIdentifier, forIndexPath: indexPath) as! StatusCategoryCollectionViewCell
      
      let category = EventInvitation.Status.categories[indexPath.row]
      let count = getCountForCategory(category)
      
      let data = StatusCategoryCollectionViewCellData(name: category.uppercaseString, count: count)
      cell.setData(data)
      
      return cell
    }
    // otherwise, only display the names of the guests that have accepted an invitation
    else {
       let cell = collectionView.dequeueReusableCellWithReuseIdentifier(Constants.EventDetailCollection.AttendeeCellIdentifier, forIndexPath: indexPath) as! AttendeeCollectionViewCell
       
       let contact = contacts[indexPath.row]
       let name = contact["name"] ?? ""
      
       let data = AttendeeCollectionViewCellData(name: name)
       cell.setData(data)
       
       return cell
    }
  }
  
  override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
    switch kind {
    case UICollectionElementKindSectionHeader:
      let cell = self.collectionView?.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: Constants.EventDetailCollection.SectionHeaderIdentifier, forIndexPath: indexPath) as! EventDetailCollectionViewSectionHeader
      
      // setup cell depending on event ownership
      cell.toggleIsOwner(isEventOwner)
      
      return cell
    case CSStickyHeaderParallaxHeader:
      let cell = self.collectionView?.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: Constants.EventDetailCollection.HeaderViewIdentifier, forIndexPath: indexPath) as! EventDetailCollectionViewHeaderView
      
      return cell
    default:
      assert(false, "Unexpected element kind")
    }
    
    return UICollectionReusableView()
  }
  
  // MARK: - UICollectionViewDelegate
  
  override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    performSegueWithIdentifier("showInviteeDetails", sender: indexPath)
  }
  
  
}