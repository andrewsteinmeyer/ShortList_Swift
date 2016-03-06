//
//  SelectContactsViewController.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 12/20/15.
//  Copyright © 2015 Andrew Steinmeyer. All rights reserved.
//


import UIKit
import CoreData
import Meteor
import PhoneNumberKit

protocol SelectContactsViewControllerDelegate {
  func selectContactsViewControllerDidSelectContact(contact: Contact)
  func selectContactsViewControllerDidRemoveContact(contact: Contact)
}

class SelectContactsViewController: FetchedResultsTableViewController {
  
  private let listSubscriptionName = "PrivateContacts"
  private let modelName = "Contact"
  
  weak var delegate: CreateListViewController?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // allow multiple contacts to be selected
    self.tableView.allowsMultipleSelection = true
    
    self.managedObjectContext = Meteor.mainQueueManagedObjectContext
  }
  
  // MARK: - Content Loading
  
  override func configureSubscriptionLoader(subscriptionLoader: SubscriptionLoader) {
    subscriptionLoader.addSubscriptionWithName(listSubscriptionName)
  }
  
  override func createFetchedResultsController() -> NSFetchedResultsController? {
    let fetchRequest = NSFetchRequest(entityName: modelName)
    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "insertedOn", ascending: false)]
    
    return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
  }
  
  // MARK: - FetchedResultsTableViewDataSourceDelegate
  
  func dataSource(dataSource: FetchedResultsTableViewDataSource, configureCell cell: UITableViewCell, forObject object: NSManagedObject, atIndexPath indexPath: NSIndexPath) {
    if let contact = object as? Contact {
      if let cell = cell as? ContactsTableViewCell {
        var contactName = ""
        var contactPhone = ""
        var contactEmail = ""
        
        // set name 
        if let name = contact.valueForKey("name") as? String {
          contactName = name
        }
        
        // set phone number
        if let phone = contact.valueForKey("phone") as? String {
          var phoneNumber: PhoneNumber?
          
          do {
            phoneNumber = try PhoneNumber(rawNumber: phone)
          }
          catch {
            print("Error: Could not parse raw phone number")
          }
          
          if let number = phoneNumber?.toNational() {
            contactPhone = number
          }
        }
        
        // set email
        if let email = contact.valueForKey("email") as? String {
          contactEmail = email
        }
        
        let data = ContactsTableViewCellData(name: contactName, phone: contactPhone, email: contactEmail)
        cell.setData(data)
      }
    }
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let cell = tableView.cellForRowAtIndexPath(indexPath) as? ContactsTableViewCell
    cell?.toggleHighlight()
    
    if let selectedContact = dataSource.objectAtIndexPath(indexPath) as? Contact {
      if cell?.highlight == true {
        delegate?.selectContactsViewControllerDidSelectContact(selectedContact)
      }
      else {
        delegate?.selectContactsViewControllerDidRemoveContact(selectedContact)
      }
    }
  }
  
  // do not allow "Delete"
  override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
    return UITableViewCellEditingStyle.None
  }
  

  
  
}
