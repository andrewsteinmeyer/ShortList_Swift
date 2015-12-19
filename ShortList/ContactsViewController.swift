//
//  ContactsViewController.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 12/17/15.
//  Copyright © 2015 Andrew Steinmeyer. All rights reserved.
//

import UIKit
import CoreData
import Meteor

class ContactsViewController: FetchedResultsTableViewController {
  
  private let listSubscriptionName = "PrivateContacts"
  private let modelName = "Contact"
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.tableView.separatorStyle = .SingleLine
    self.tableView.separatorColor = UIColor.lightGrayColor()
    
    self.managedObjectContext = Meteor.mainQueueManagedObjectContext
    
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
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
  
  func dataSource(dataSource: FetchedResultsTableViewDataSource, deleteObject object: NSManagedObject, atIndexPath indexPath: NSIndexPath) {
    guard let contact = object as? Contact else {
      return
    }
    
    // get documentID for contact
    let documentID = Meteor.documentKeyForObjectID(contact.objectID).documentID
    
    // delete contact
    MeteorContactService.sharedInstance.delete([documentID]) {
      result, error in
      
      if error != nil {
        print("error: \(error?.localizedDescription)")
      } else {
        print("success: contact deleted")
      }
    }
  }
  
  func createContact() {
    performSegueWithIdentifier("createContact", sender: nil)
  }
  
  func importContacts() {
    
  }
  
  // MARK: - IBAction methods
  
  @IBAction func showContactMenu(sender: AnyObject) {
    let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
    alertController.addAction(cancelAction)
    
    let createContactAction = UIAlertAction(title: "Create Contact", style: UIAlertActionStyle.Default, handler: { _ in self.createContact() })
    alertController.addAction(createContactAction)
    
    let importContactsAction = UIAlertAction(title: "Import Contacts", style: .Default, handler: { _ in self.importContacts() })
    alertController.addAction(importContactsAction)
    
    presentViewController(alertController, animated: true, completion: nil)
  }
  
  
}