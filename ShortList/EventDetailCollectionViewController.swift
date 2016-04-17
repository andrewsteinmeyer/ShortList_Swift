//
//  EventDetailCollectionViewController.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 3/25/16.
//  Copyright © 2016 Andrew Steinmeyer. All rights reserved.
//

import CoreData
import PhoneNumberKit
import CSStickyHeaderFlowLayout

class EventDetailCollectionViewController: UICollectionViewController {
  typealias NamedValues = [String:AnyObject]
  typealias Contacts = [String:String]
  
  private var contacts = [Contacts]()
  
  var ownerCategories = ["Invited", "Accepted", "Declined", "Timeout"]
  
  var isOwner = false
  var invitedCount = 0
  var acceptedCount = 0
  var declinedCount = 0
  var timeoutCount = 0
  
  // MARK: - Model
  
  var managedObjectContext: NSManagedObjectContext!
  private var eventObserver: ManagedObjectObserver?
  
  var ticketView: UIView?
  var ticketImage: UIImage?
  
  var event: Event? {
    didSet {
      if event != oldValue {
        if event != nil {
          eventObserver = ManagedObjectObserver(event!) { (changeType) -> Void in
            switch changeType {
            case .Deleted, .Invalidated:
              self.event = nil
            case .Updated, .Refreshed:
              //self.eventDidChange()
              break
            default:
              break
            }
          }
        } else {
          eventObserver = nil
        }
        
        eventDidChange()
      }
    }
  }
  
  deinit {
    if eventObserver != nil {
      eventObserver = nil
    }
  }
  
  func eventDidChange() {
    title = event?.name
    
    if isViewLoaded() {
      updateViewWithModel()
    }
  }
  
  // MARK: - View Lifecycle
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    
    // needed for custom presentation
    modalPresentationStyle = UIModalPresentationStyle.Custom
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    updateViewWithModel()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // set clipsToBounds to false so cancel button can hover
    self.view.clipsToBounds = false
    
    // set CoreData context
    self.managedObjectContext = Meteor.mainQueueManagedObjectContext
    
    // setup sticky header layout
    reloadLayout()
    
    // Register cell classes
    let headerViewNib = UINib(nibName: Constants.EventDetailCollection.HeaderViewIdentifier, bundle: nil)
    self.collectionView?.registerNib(headerViewNib, forSupplementaryViewOfKind: CSStickyHeaderParallaxHeader, withReuseIdentifier: Constants.EventDetailCollection.HeaderViewIdentifier)
    
    // hide view initially
    self.view.alpha = 0.0
    
  }

  // MARK: - Updating View
  
  private func updateViewWithModel() {
    guard let event = event else { return }
    
    // determine if user is event owner
    isOwner = (event.userId == AccountManager.defaultAccountManager.currentUserId) ? true : false
    
    // user is event owner
    if isOwner {
      invitedCount = Int(event.contactCount!) ?? 0
      acceptedCount = Int(event.acceptedCount!) ?? 0
      declinedCount = Int(event.declinedCount!) ?? 0
      timeoutCount = Int(event.timeoutCount!) ?? 0
    }
    // user is attendee
    else {
      // reset contact list
      contacts = []
      
      // retrieve list data from event
      if let list = event.valueForKey("list") as? NamedValues {
        let JSONList = JSON(list)
        
        // retrieve contacts from list data
        for (_,contact):(String, JSON) in JSONList["contacts"] {
          
          let name = contact["name"].string ?? ""
          let email = contact["email"].string ?? ""
          var phone = contact["phone"].string ?? ""
          let score = contact["score"].int ?? 0
          
          // make sure there is at least a name for the contact
          guard !name.isEmpty else {
            continue
          }
          
          // set phone number
          if phone != "" {
            var phoneNumber: PhoneNumber?
            
            do {
              phoneNumber = try PhoneNumber(rawNumber: phone)
            }
            catch {
              print("Error: Could not parse raw phone number")
            }
            
            if let number = phoneNumber?.toNational() {
              phone = number
            }
          }
          
          // build contact
          let newContact = ["name": name,
                            "email": email,
                            "phone": phone,
                            "score": String(score)]
          
          contacts.append(newContact)
        }
      }
    }
    
    // refresh data
    collectionView?.reloadData()
  }
  
  // add sticky header
  private func reloadLayout() {
    // set header size and item size
    if let layout = self.collectionViewLayout as? CSStickyHeaderFlowLayout {
      let size = self.view.frame.width - Constants.EventDetailCollection.Padding
      
      // resize layout header and item
      layout.parallaxHeaderReferenceSize = CGSizeMake(size, 256)
      layout.itemSize = CGSizeMake(size, layout.itemSize.height)
    }
  }
  
  private func getCountForCategory(category: String) -> Int {
    switch category {
    case "Invited":
      return invitedCount
    case "Accepted":
      return acceptedCount
    case "Declined":
      return declinedCount
    case "Timeout":
      return timeoutCount
    default:
      return 0
    }
  }
  
  func closeButtonPressed(sender: UIButton) {
    presentingViewController!.dismissViewControllerAnimated(true, completion: nil)
  }
  
  // MARK: - UICollectionViewDataSource
  
  override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    return 1
  }
  
  override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return (isOwner ? ownerCategories.count : contacts.count)
  }
  
  override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    if isOwner {
      let cell = collectionView.dequeueReusableCellWithReuseIdentifier(Constants.EventDetailCollection.CategoryCellIdentifier, forIndexPath: indexPath) as! StatusCategoryCollectionViewCell
      
      let category = ownerCategories[indexPath.row]
      let count = getCountForCategory(category)
      
      let data = StatusCategoryCollectionViewCellData(name: category, count: count)
      cell.setData(data)
      
      return cell
    }
    else {
       let cell = collectionView.dequeueReusableCellWithReuseIdentifier(Constants.EventDetailCollection.AttendeeCellIdentifier, forIndexPath: indexPath) as! AttendeeCollectionViewCell
       
       var name = ""
      
       let contact = contacts[indexPath.row]
       name = contact["name"] ?? ""
      
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
      cell.toggleIsOwner(isOwner)
      
      return cell
    case CSStickyHeaderParallaxHeader:
      // make sure the header cell uses the proper identifier
      let cell = self.collectionView!.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: Constants.EventDetailCollection.HeaderViewIdentifier, forIndexPath: indexPath) as! EventDetailCollectionViewHeaderView
      
      cell.ticketView.image = ticketImage
      
      // add tap gesture recognizer to the ticket view
      let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(EventDetailCollectionViewController.closeButtonPressed(_:)))
      tapGestureRecognizer.numberOfTapsRequired = 1
      cell.ticketView.userInteractionEnabled = true
      cell.ticketView.addGestureRecognizer(tapGestureRecognizer)
      
      return cell
    default:
      assert(false, "Unexpected element kind")
    }
  }
  
  override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    performSegueWithIdentifier("showAttendeeDetails", sender: nil)
  }
  

  
  
}