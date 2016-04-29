//
//  GuestListTableViewController.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 4/23/16.
//  Copyright © 2016 Andrew Steinmeyer. All rights reserved.
//

import CoreData
import PhoneNumberKit
import CSStickyHeaderFlowLayout

class GuestListTableViewController: UITableViewController {
  typealias NamedValues = [String:AnyObject]
  typealias Contacts = [String:String]
  
  private var contacts = [Contacts]()
  
  var selectedCategory: String!
  
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
              //self.eventDidChange()
              break
            default:
              break
            }
          }
        } else {
          eventObserver = nil
        }
        
        // update changes
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
    if isViewLoaded() {
      
      // refresh view if loaded
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
    
    // refresh view
    updateViewWithModel()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // show navigation bar
    self.navigationController?.navigationBarHidden = false
    
    // set clipsToBounds to false so close button can hover
    self.view.clipsToBounds = false
    
    // set CoreData context
    self.managedObjectContext = Meteor.mainQueueManagedObjectContext
    
  }
  
  // MARK: - Updating View
  
  private func updateViewWithModel() {
    guard let event = event else { return }
    
    // reset contact list
    contacts = []
    
    // retrieve list data from event
    if let list = event.valueForKey("list") as? NamedValues {
      let JSONList = JSON(list)
      
      // retrieve contacts from list data
      for (_,contact):(String, JSON) in JSONList["contacts"] {
        
        let status = contact["status"].string ?? ""
        
        // only collect contacts for the selected category
        guard status == selectedCategory else { continue }
        
        let name = contact["name"].string ?? ""
        let score = contact["score"].int ?? 0
        
        let invitationId = (status != "" ? contact["invitationId"].string : "")
        
        // make sure there is at least a name for the contact
        guard !name.isEmpty else { continue }
        
        // build contact
        let newContact = ["name": name,
                          "score": String(score)]
        
        contacts.append(newContact)
      }
    }
  
    // refresh data
    tableView?.reloadData()
  }
  
  // MARK: - UITableViewDataSource
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return contacts.count
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    switch selectedCategory {
    default:
      let cell = tableView.dequeueReusableCellWithIdentifier(Constants.GuestListTableView.InviteeCellIdentifier, forIndexPath: indexPath)
      
      let contact = contacts[indexPath.row]
      let name = contact["name"] ?? ""
      
      
      let data = AttendeeCollectionViewCellData(name: name)
      //cell.setData(data)
      
      return cell
    }
  }
  
}