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
  
  @IBOutlet weak var menuButton: UIBarButtonItem!
  
  private let subscriptionName = "PrivateContacts"
  private let modelName = "Contact"
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.managedObjectContext = Meteor.mainQueueManagedObjectContext
    
    if self.revealViewController() != nil {
      menuButton.target = self.revealViewController()
      menuButton.action = "revealToggle:"
      self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
    }
  }
  
  // MARK: - Content Loading
  
  override func configureSubscriptionLoader(subscriptionLoader: SubscriptionLoader) {
    subscriptionLoader.addSubscriptionWithName(subscriptionName)
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
          contactPhone = phone
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
    displayContactsController()
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