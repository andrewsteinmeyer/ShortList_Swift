//
//  InvitationsManagerCollectionViewController.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 8/1/16.
//  Copyright © 2016 Andrew Steinmeyer. All rights reserved.
//


import CoreData
import PhoneNumberKit

class InvitationsManagerCollectionViewController: UICollectionViewController {
  typealias NamedValues = [String:AnyObject]
  typealias Contacts = [String:String]
  
  private var contacts = [Contacts]()
  private var isEventOwner = false
  
  // MARK: - Model
  
  var managedObjectContext: NSManagedObjectContext!
  private var eventObserver: ManagedObjectObserver?
  
  var eventId: NSManagedObjectID? {
    didSet {
      managedObjectContext = Meteor.mainQueueManagedObjectContext
      
      assert(managedObjectContext != nil)
      
      if eventId != nil {
        if eventId != oldValue {
          event = (try? managedObjectContext!.existingObjectWithID(self.eventId!)) as? Event
        }
      } else {
        event = nil
      }
    }
  }
  
  private var event: Event? {
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
    
    // setup sticky header layout
    reloadLayout()
    
    // Register cell classes
    let headerViewNib = UINib(nibName: Constants.InvitationManagerCollection.HeaderViewIdentifier, bundle: nil)
    self.collectionView?.registerNib(headerViewNib, forSupplementaryViewOfKind: CSStickyHeaderParallaxHeader, withReuseIdentifier: Constants.InvitationManagerCollection.HeaderViewIdentifier)
  }
  
  // MARK: - Updating View
  
  private func updateViewWithModel() {
    guard let event = event else { return }
    
    // determine if user is event owner
    isEventOwner = isEventOwner(event.userId)
    
    // user is owner
    if isEventOwner {
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
    
    // TODO: only refresh contacts that changed
    // refresh collectionView data
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
      
      // set up sizes
      layout.parallaxHeaderReferenceSize = CGSizeMake(self.view.frame.width, Constants.InvitationManagerCollection.HeaderViewHeight)
      layout.itemSize = CGSizeMake(self.view.frame.width, layout.itemSize.height)
      layout.disableStickyHeaders = false
    }
  }
  
  // MARK: - Helper methods
  
  private func isEventOwner(eventId: String?) -> Bool {
    return (eventId == AccountManager.defaultAccountManager.currentUserId)
  }
  
  // MARK: - UICollectionViewDataSource
  
  override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    return 1
  }
  
  override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return contacts.count
  }
  
  override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(Constants.InvitationManagerCollection.InvitationManagerCellIdentifier, forIndexPath: indexPath) as! InvitationManagerCollectionViewCell
    
    return cell
  }
  
  override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
    switch kind {
    case UICollectionElementKindSectionHeader:
      let cell = self.collectionView?.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: Constants.InvitationManagerCollection.SectionHeaderIdentifier, forIndexPath: indexPath) as! InvitationManagerCollectionViewSectionHeader
      
      // set event
      cell.event = event
      
      return cell
    case CSStickyHeaderParallaxHeader:
      let cell = self.collectionView?.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: Constants.InvitationManagerCollection.HeaderViewIdentifier, forIndexPath: indexPath) as! InvitationManagerCollectionViewHeaderView
      
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