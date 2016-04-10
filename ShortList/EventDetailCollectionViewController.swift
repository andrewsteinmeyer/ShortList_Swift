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
  var nonOwnerCategories = ["Accepted", "Declined"]
  
  var isOwner = false
  var invitedCount = 0
  var acceptedCount = 0
  var declinedCount = 0
  var timeoutCount = 0
  
  // MARK: - Model
  
  var managedObjectContext: NSManagedObjectContext!
  private var eventObserver: ManagedObjectObserver?
  
  var ticketView: UIView?
  
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
    
    // setup custom layout
    reloadLayout()
    
    // Register cell classes
    let headerViewNib = UINib(nibName: Constants.EventDetailCollection.HeaderViewIdentifier, bundle: nil)
    self.collectionView?.registerNib(headerViewNib, forSupplementaryViewOfKind: CSStickyHeaderParallaxHeader, withReuseIdentifier: Constants.EventDetailCollection.HeaderViewIdentifier)
    
    // hide view initially
    self.collectionView?.backgroundColor = UIColor.clearColor()
    self.view.alpha = 0.0
    
  }
  
  // add sticky header
  func reloadLayout() {
    // set header size and item size
    if let layout = self.collectionViewLayout as? CSStickyHeaderFlowLayout {
      let size = self.view.frame.width - Constants.EventDetailCollection.Padding
      
      // resize layout header and item
      layout.parallaxHeaderReferenceSize = CGSizeMake(size, 256)
      layout.parallaxHeaderMinimumReferenceSize = CGSizeMake(size, 256)
      layout.itemSize = CGSizeMake(size, layout.itemSize.height)
    }
  }
  
  // MARK: - Updating View
  
  func updateViewWithModel() {
    guard let event = event else { return }
    
    invitedCount = Int(event.contactCount!) ?? 0
    acceptedCount = Int(event.acceptedCount!) ?? 0
    declinedCount = Int(event.declinedCount!) ?? 0
    timeoutCount = Int(event.timeoutCount!) ?? 0
    
    isOwner = (event.userId == AccountManager.defaultAccountManager.currentUserId) ? true : false
    
    // refresh data
    collectionView?.reloadData()
  }
  
  /*
  func updateViewWithModel() {
    guard let event = event else { return }
    
    // set list name
    if let list = event.valueForKey("list") as? NamedValues {
      let JSONList = JSON(list)
      
      for (_,contact):(String, JSON) in JSONList["contacts"] {
        
        let name = contact["name"].string ?? ""
        let email = contact["email"].string ?? ""
        var phone = contact["phone"].string ?? ""
        let score = contact["score"].int ?? 0
        
        // make sure there is at least a name
        guard !name.isEmpty else {
          return
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
        
        let newContact = ["name": name,
                          "email": email,
                          "phone": phone,
                          "score": String(score)]
        
        contacts.append(newContact)
      }
    } else {
      // clear if no list exists
      contacts = []
    }
    
    // refresh data
    collectionView?.reloadData()
  }
  */
  
  override func prefersStatusBarHidden() -> Bool {
    return true
  }
  
  override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
    return .Fade
  }
  
  // MARK: - UICollectionViewDataSource
  
  override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    return 1
  }
  
  override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return (isOwner ? ownerCategories.count : nonOwnerCategories.count)
  }
  
  override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(Constants.EventDetailCollection.CellIdentifier, forIndexPath: indexPath) as! StatusCategoryCollectionViewCell
    
    let category = isOwner ? ownerCategories[indexPath.row] : nonOwnerCategories[indexPath.row]
    var count = 0
    
    if category == "Invited" {
      count = invitedCount
    }
    else if category == "Accepted" {
      count = acceptedCount
    }
    else if category == "Declined" {
      count = declinedCount
    }
    else if category == "Timeout" {
      count = timeoutCount
    }
    
    let data = StatusCategoryCollectionViewCellData(name: category, count: count)
    cell.setData(data)
    
    return cell
    
    /*
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(Constants.EventDetailCollection.CellIdentifier, forIndexPath: indexPath) as! InviteeCollectionViewCell
    
    var name = ""
    var score = "0"
    
    let contact = contacts[indexPath.row]
    name = contact["name"]!
    score = contact["score"]!
    
    let data = InviteeCollectionViewCellData(name: name, score: score)
    cell.setData(data)
    
    return cell
    */
  }
  
  override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
    switch kind {
    case UICollectionElementKindSectionHeader:
      let cell = self.collectionView?.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: Constants.EventDetailCollection.SectionHeaderIdentifier, forIndexPath: indexPath) as! EventDetailCollectionViewSectionHeader
      
      // hide invite button if not owner of event
      if !isOwner {
        cell.inviteButton.hidden = true
      }
      
      return cell
    case CSStickyHeaderParallaxHeader:
      // make sure the header cell uses the proper identifier
      let cell = self.collectionView!.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: Constants.EventDetailCollection.HeaderViewIdentifier, forIndexPath: indexPath) as! EventDetailCollectionViewHeaderView
      
      let resizedTicketView = scaleAndPositionTicketImageInHeaderView(ticketView!)
      cell.ticketView.image = resizedTicketView
      
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
  
  func closeButtonPressed(sender: UIButton) {
    presentingViewController!.dismissViewControllerAnimated(true, completion: nil)
  }
  
  private func scaleAndPositionTicketImageInHeaderView(ticketView: UIView) -> UIImage {
    var ticketFrame = ticketView.frame
    
    // scale snapshot of ticket to fill header
    // use the same size ratio of the smaller ticket
    let ratio = ticketFrame.size.width / ticketFrame.size.height
    
    // calculate new ticket size
    ticketFrame.size.width = view.frame.size.width
    ticketFrame.size.height = ticketFrame.size.width / ratio
    
    // update ticket frame with new size
    ticketView.frame = ticketFrame
    
    // crop out stats on bottom of ticket
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(ticketView.bounds.size.width, 256), false, UIScreen.mainScreen().scale)
    ticketView.drawViewHierarchyInRect(CGRectMake(0, -44, ticketView.bounds.size.width, ticketView.bounds.size.height), afterScreenUpdates: true)
    let croppedTicketImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return croppedTicketImage
  }
  

  
}