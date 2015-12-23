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
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    // needed for slide menu
    self.setNavigationBarItem()
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
        let data = ContactsTableViewCellData(name: contact.name, phone: contact.phone, email: contact.email)
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
