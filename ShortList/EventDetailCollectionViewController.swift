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
    
    print("view did load")
    
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
  
  func reloadLayout() {
    // set header size and item size
    if let layout = self.collectionViewLayout as? CSStickyHeaderFlowLayout {
      let size = self.view.frame.width - Constants.EventDetailCollection.Padding
      
      // resize layout header and item
      layout.parallaxHeaderReferenceSize = CGSizeMake(size, size)
      layout.parallaxHeaderMinimumReferenceSize = CGSizeMake(size, size)
      layout.itemSize = CGSizeMake(size, layout.itemSize.height)
    }
  }
  
    // MARK: - Updating View
  
  func updateViewWithModel() {
    if event == nil {
    }
    else {
      // set list name
      if let list = event?.valueForKey("list") as? NamedValues {
        let JSONList = JSON(list)
        
        for (_,contact):(String, JSON) in JSONList["contacts"] {
          
          let name = contact["name"].string ?? ""
          let email = contact["email"].string ?? ""
          var phone = contact["phone"].string ?? ""
          
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
                            "phone": phone]
          
          contacts.append(newContact)
        }
      } else {
        // clear if no list exists
        contacts = []
      }
    }
    
    // refresh data
    collectionView?.reloadData()
  }
  
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
    return contacts.count + 20
  }
  
  override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(Constants.EventDetailCollection.CellIdentifier, forIndexPath: indexPath)
    
    return cell
  }
  
  override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
    switch kind {
    case UICollectionElementKindSectionHeader:
      let cell = self.collectionView?.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: Constants.EventDetailCollection.SectionHeaderIdentifier, forIndexPath: indexPath) as UICollectionReusableView!
      
      return cell
    case CSStickyHeaderParallaxHeader:
      // make sure the header cell uses the proper identifier
      let cell = self.collectionView!.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: Constants.EventDetailCollection.HeaderViewIdentifier, forIndexPath: indexPath) as! EventDetailCollectionViewHeaderView
      
      let resizedTicketView = scaleAndPositionTicketInHeaderView(cell, ticketView: ticketView!)
      //cell.addSubview(resizedTicketView)
      cell.ticketView = resizedTicketView
      
      return cell
    default:
      assert(false, "Unexpected element kind")
    }
  }
  
  func scaleAndPositionTicketInHeaderView(cell: EventDetailCollectionViewHeaderView, ticketView: UIView) -> UIView {
    var ticketFrame = ticketView.frame
    
    let ratio = ticketFrame.size.width / ticketFrame.size.height
    
    ticketFrame.size.width = view.frame.size.width
    ticketFrame.size.height = ticketFrame.size.width / ratio
    
    ticketView.frame = ticketFrame
    
    return ticketView
  }
  
}