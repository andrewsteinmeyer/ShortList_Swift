//
//  EventDetailTableViewController.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 4/5/16.
//  Copyright © 2016 Andrew Steinmeyer. All rights reserved.
//

import Foundation

import CoreData
import PhoneNumberKit

class EventDetailTableViewController: UIViewController {
  typealias NamedValues = [String:AnyObject]
  typealias Contacts = [String:String]
  
  private var contacts = [Contacts]()
  
  var statusCategories = ["Pending", "Accepted", "Declined", "Timeout"]
  
  // MARK: - Model
  
  var managedObjectContext: NSManagedObjectContext!
  private var eventObserver: ManagedObjectObserver?
  
  
  @IBOutlet weak var headerView: EventDetailTableViewHeaderView!
  @IBOutlet weak var tableView: UITableView!
  
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
    
    
    // create cancel button
    let closeButton = UIButton(type: .Custom)
    closeButton.frame = CGRect(x: -15, y: -15, width: 30, height: 30)
    closeButton.layer.cornerRadius = 15
    closeButton.layer.backgroundColor = UIColor.whiteColor().CGColor
    closeButton.setImage(UIImage(named: "cancel-button"), forState: .Normal)
    closeButton.layer.borderWidth = 1.5
    closeButton.layer.borderColor = Theme.EventDetailCancelButtonColor.toUIColor().CGColor
    closeButton.addTarget(self, action: #selector(EventDetailCollectionViewController.closeButtonPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
    
    // create clear cancel button for greater surface area
    let clearButton = UIButton(type: .Custom)
    clearButton.frame = CGRect(x: -20, y: -20, width: 50, height: 50)
    clearButton.layer.backgroundColor = UIColor.clearColor().CGColor
    clearButton.addTarget(self, action: #selector(EventDetailCollectionViewController.closeButtonPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
    
    // add cancel buttons to view
    self.view.addSubview(closeButton)
    self.view.addSubview(clearButton)
    
    // set CoreData context
    self.managedObjectContext = Meteor.mainQueueManagedObjectContext
    
    // register section header row
    let nib = UINib(nibName: "EventDetailTableViewSectionHeader", bundle: nil)
    tableView.registerNib(nib, forHeaderFooterViewReuseIdentifier: "EventDetailTableViewSectionHeader")
    
    // hide view initially
    self.tableView?.backgroundColor = UIColor.clearColor()
    self.view.alpha = 0.0
    
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
    }
    
    // refresh data
    tableView?.reloadData()
  }
  
  override func prefersStatusBarHidden() -> Bool {
    return true
  }
  
  override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
    return .Fade
  }
  
  func closeButtonPressed(sender: UIButton) {
    presentingViewController!.dismissViewControllerAnimated(true, completion: nil)
  }

}

//MARK: UITableViewDataSource Extension

extension EventDetailTableViewController: UITableViewDataSource {
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return statusCategories.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("StatusCategoryCell", forIndexPath: indexPath) as! InvitationStatusTableViewCell
    
    cell.statusCategoryLabel.text = statusCategories[indexPath.row]
    cell.countLabel.text = "0"
    
    return cell
  }

  func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let cell = self.tableView.dequeueReusableHeaderFooterViewWithIdentifier("EventDetailTableViewSectionHeader") as! EventDetailTableViewSectionHeader
    
    
    return cell
  }
  
}
