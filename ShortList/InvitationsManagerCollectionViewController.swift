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
  typealias EventContact = [String:AnyObject?]
  
  private var contacts = [EventContact]()
  private var isEventOwner = false
  
  private var subscriptionLoader: SubscriptionLoader?
  private let subscriptionName = "EventInvitations"
  private let modelName = "Invitation"
  
  private var fetchedResultsController: NSFetchedResultsController?
  var invitationDuration: Int?
  
  var invitations: [Invitation]? {
    didSet {
      eventDidChange()
    }
  }
  
  // MARK: - Model
  
  private var managedObjectContext: NSManagedObjectContext!
  private var eventObserver: ManagedObjectObserver?
  
  var eventId: NSManagedObjectID! {
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
  
  // MARK: - Content Loading (Invitations)
  
  private(set) var needsLoadContent: Bool = true
  
  func setNeedsLoadContent() {
    needsLoadContent = true
    if isViewLoaded() {
      loadContentIfNeeded()
    }
  }
  
  func loadContentIfNeeded() {
    if needsLoadContent {
      loadContent()
    }
  }
  
  func loadContent() {
    subscriptionLoader = SubscriptionLoader()
    configureSubscriptionLoader(subscriptionLoader!)
    
    // subscribe to invitations
    subscriptionLoader!.whenReady { [weak self] in
      if let fetchedResultsController = self?.createFetchedResultsController() {
        self?.fetchedResultsController = fetchedResultsController
        self?.performFetch()
      }
    }
  }
  
  // MARK: - Invitations Subscription
  
  func configureSubscriptionLoader(subscriptionLoader: SubscriptionLoader) {
    subscriptionLoader.addSubscriptionWithName(subscriptionName, parameters: eventId!)
  }
  
  func createFetchedResultsController() -> NSFetchedResultsController? {
    let fetchRequest = NSFetchRequest(entityName: modelName)
    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "insertedOn", ascending: false)]
    
    return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
  }
  
  func performFetch() {
    var error: NSError?
    do {
      try fetchedResultsController!.performFetch()
      fetchedResultsController!.delegate = self
    } catch let error1 as NSError {
      error = error1
      if error != nil {
        //didFailWithError(error!)
      }
    }
  }
  
  // MARK: - View Lifecycle
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    // load invitations
    loadContentIfNeeded()
    
    // refresh view with event info
    updateViewWithModel()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // setup sticky header layout
    reloadLayout()
    
    // Register cell classes
    let headerViewNib = UINib(nibName: Constants.InvitationManagerCollection.HeaderViewIdentifier, bundle: nil)
    self.collectionView?.registerNib(headerViewNib, forSupplementaryViewOfKind: CSStickyHeaderParallaxHeader, withReuseIdentifier: Constants.InvitationManagerCollection.HeaderViewIdentifier)
    
    // set color behind cells
    self.collectionView?.backgroundColor = Theme.InvitationCollectionViewBackgroundColor.toUIColor()
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
          let contactId = contact["_id"].string ?? ""
          let score = contact["score"].int ?? 0
          let status = contact["status"].string ?? ""
          let added = contact["addedToList"].double ?? nil
          let updated = contact["actionUpdated"].double ?? nil
          let invitationId = contact["invitationId"].string ?? ""
          
          // filter invitations and grab the first match
          let matchedInvitation = self.invitations?.filter {
            invitation($0, matchesContactInvitationId: invitationId)
          }.first
          
          // if we found an invitation, then unwrap it
          var unwrappedInvitation: Invitation?
          if let invitation = matchedInvitation {
            unwrappedInvitation = invitation
          }
          else {
            unwrappedInvitation = nil
          }
          
          // make sure there is at least a name for the contact
          guard !name.isEmpty else { continue }
          
          // build contact
          let newContact: EventContact = ["name": name,
                                          "id": contactId,
                                          "score": score,
                                          "status": status,
                                          "addedToList": added,
                                          "actionUpdated": updated,
                                          "invitation": unwrappedInvitation]
          
          // add contact to list
          contacts.append(newContact)
        }
      }
    }
    
    // TODO: only refresh contacts that changed
    // refresh collectionView data
    collectionView?.reloadData()
  }
  
  private func invitation(invite: Invitation, matchesContactInvitationId id: String) -> Bool {
    // get documentID for invitation
    let invitationId = Meteor.documentKeyForObjectID(invite.objectID).documentID as! String
    
    // check if they match
    return (invitationId == id)
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
      //layout.enableDecorationView = true
      layout.minimumLineSpacing = 0.50
      
      // set up sizes for header and items
      layout.parallaxHeaderReferenceSize = CGSizeMake(self.view.frame.width, Constants.InvitationManagerCollection.HeaderViewHeight)
      layout.itemSize = CGSizeMake(self.view.frame.width, layout.itemSize.height)
      layout.disableStickyHeaders = false
    }
  }
  
  // MARK: - Helper methods
  
  private func isEventOwner(eventId: String?) -> Bool {
    return (eventId == AccountManager.defaultAccountManager.currentUserId)
  }
  
  // MARK: - Invitation Actions
  
  private func inviteContacts() {
    // set invite duration, default to 60 minutes
    let invitationDuration = self.invitationDuration ?? 3600
    
    MeteorEventService.sharedInstance.invite([eventId, invitationDuration]) { result, error in
      dispatch_async(dispatch_get_main_queue()) {
        
        if error != nil {
          if let failureReason = error?.localizedFailureReason {
            AppDelegate.getAppDelegate().showMessage(failureReason)
            print("error: \(failureReason)")
          }
        } else {
          print("success: contacts invited")
        }
      }
    }
  }
  
  private func skipContactInvite(contactId: String) {
    // skip invite for this contact
    MeteorEventService.sharedInstance.skipContactInvite([eventId, contactId]) { result, error in
      dispatch_async(dispatch_get_main_queue()) {
        
        if error != nil {
          if let failureReason = error?.localizedFailureReason {
            AppDelegate.getAppDelegate().showMessage(failureReason)
            print("error: \(failureReason)")
          }
        } else {
          print("success: contact skipped")
        }
      }
    }
  }
  
  private func sendContactInvite(contactId: String) {
    // set invite duration, default to 60 minutes
    let invitationDuration = self.invitationDuration ?? 3600
    
    // send invite for this contact
    MeteorEventService.sharedInstance.inviteContactToEvent([eventId, contactId, invitationDuration]) { result, error in
      dispatch_async(dispatch_get_main_queue()) {
        
        if error != nil {
          if let failureReason = error?.localizedFailureReason {
            AppDelegate.getAppDelegate().showMessage(failureReason)
            print("error: \(failureReason)")
          }
        } else {
          print("success: contact invited")
        }
      }
    }
  }

}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate

extension InvitationsManagerCollectionViewController {
  
  override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    return 1
  }
  
  override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return contacts.count
  }
  
  override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(Constants.InvitationManagerCollection.InvitationManagerCellIdentifier, forIndexPath: indexPath) as! InvitationManagerCollectionViewCell
    
    // set delegate
    cell.delegate = self
    
    // extract information
    let contact = contacts[indexPath.row]
    let name = contact["name"] as? String ?? ""
    let contactId = contact["id"] as? String ?? ""
    let status = contact["status"] as? String ?? ""
    let score = contact["score"] as? Int ?? 0
    let added = contact["addedToList"] as? Double ?? nil
    let updated = contact["actionUpdated"] as? Double ?? nil
    let invitation = contact["invitation"] as? Invitation ?? nil
    
    // pass along to populate collection view cell
    let data = EventContactCollectionViewCellData(name: name, id: contactId, status: status, score: score, addedToList: added, actionUpdated: updated, invitation: invitation)
    cell.setData(data)
    
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
      
      // set delegate and event
      cell.delegate = self
      cell.event = event
      
      return cell
    default:
      assert(false, "Unexpected element kind")
    }
    
    // default
    return UICollectionReusableView()
  }
  
  // MARK: - UICollectionViewDelegate

  override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    performSegueWithIdentifier("showInviteeDetails", sender: indexPath)
  }

}

// MARK: - NSFetchedResultsControllerDelegate

extension InvitationsManagerCollectionViewController: NSFetchedResultsControllerDelegate {
  
  func controllerDidChangeContent(controller: NSFetchedResultsController) {
    self.invitations = controller.fetchedObjects as? [Invitation]
    
    print("invites updated: \(invitations)")
  }
  
}

// MARK: - InvitationManagerCollectionViewHeaderDelegate

extension InvitationsManagerCollectionViewController: InvitationManagerCollectionViewHeaderViewDelegate {
  
  func invitationManagerDidStartAutoInvite() {
    inviteContacts()
  }
  
  func invitationManagerDidCancelAutoInvite() {
    //TODO: Add cancel
  }
  
}

// MARK: - InvitationManagerCollectionViewHeaderDelegate

extension InvitationsManagerCollectionViewController: InvitationManagerCollectionViewCellDelegate {
  
  func invitationManagerDidSkipContact(contactId: String) {
    skipContactInvite(contactId)
  }
  
  func invitationManagerDidInviteContact(contactId: String) {
    sendContactInvite(contactId)
  }
  
}

