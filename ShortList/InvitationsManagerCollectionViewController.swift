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
  
  var invitationDuration: Int?
  
  private var subscriptionLoader: SubscriptionLoader?
  private let subscriptionName = "EventInvitations"
  private let modelName = "Invitation"
  
  private var fetchedResultsController: NSFetchedResultsController?
  var invitations: [Invitation]?
  
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
    
    subscriptionLoader!.whenReady { [weak self] in
      if let fetchedResultsController = self?.createFetchedResultsController() {
        self?.fetchedResultsController = fetchedResultsController
        self?.performFetch()
      }
    }
  }
  
  // MARK: - Invitation Subscription
  
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
  
  // MARK: - Invitation Actions
  
  func inviteContacts() {
    // set invite duration
    let invitationDuration = self.invitationDuration ?? 3600
    
    // TODO: make this not random all the time
    MeteorEventService.sharedInstance.invite([eventId, invitationDuration]) { result, error in
      dispatch_async(dispatch_get_main_queue()) {
        
        if error != nil {
          if let failureReason = error?.localizedFailureReason {
            AppDelegate.getAppDelegate().showMessage(failureReason)
            print("error: \(failureReason)")
          }
        } else {
          print("success: contacts invited")
          //self.dismissViewControllerAnimated(true, completion: nil)
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
      
      // set delegate
      cell.delegate = self
      
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

// MARK: - NSFetchedResultsControllerDelegate

extension InvitationsManagerCollectionViewController: NSFetchedResultsControllerDelegate {
  
  func controllerDidChangeContent(controller: NSFetchedResultsController) {
    self.invitations = controller.fetchedObjects as? [Invitation]
    
    print("got here yeah go invites: \(invitations)")
  }
  
}

// MARK: - Invitation Manager Delegate

extension InvitationsManagerCollectionViewController: InvitationManagerDelegate {
  
  func invitationManagerDidAutoInvite() {
    inviteContacts()
  }
  
  func invitationManagerDidCancelAutoInvite() {
    //TODO: Add cancel
  }
  
}