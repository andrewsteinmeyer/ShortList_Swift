//
//  ShareContactsViewController.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 3/14/16.
//  Copyright © 2016 Andrew Steinmeyer. All rights reserved.
//


import UIKit
import CoreData
import DZNEmptyDataSet
import PhoneNumberKit

class ShareContactsViewController: FetchedResultsTableViewController {
  
  private let subscriptionName = "PrivateContacts"
  private let modelName = "Contact"
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // set CoreData context
    self.managedObjectContext = Meteor.mainQueueManagedObjectContext
    
    // setup delegates for empty data
    self.tableView.emptyDataSetDelegate = self
    self.tableView.emptyDataSetSource = self
    
    setupAppearance()
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "generateContactQRCode" {
      if let selectedContact = dataSource.selectedObject as? Contact {
        if let QRCodeViewController = segue.destinationViewController as? QRCodeViewController {
          var contactName = ""
          
          // grab contact documentID
          let documentID = Meteor.documentKeyForObjectID(selectedContact.objectID).documentID
          
          // set name
          if let name = selectedContact.valueForKey("name") as? String {
            contactName = name
          }
          
          QRCodeViewController.navigationItem.title = "Contact"
          QRCodeViewController.name = contactName
          QRCodeViewController.type = "contact"
          QRCodeViewController.documentID = documentID as! String
        }
      }
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
    performSegueWithIdentifier("generateContactQRCode", sender: indexPath)
  }
  
  // do not allow "Delete"
  override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
    return UITableViewCellEditingStyle.None
  }
  
  func setupAppearance() {
    self.navigationItem.rightBarButtonItem?.tintColor = Theme.NavigationBarActionButtonTextColor.toUIColor()
  }
  
  @IBAction func cancelButtonDidPress(sender: AnyObject) {
    // find the reveal controller
    if let revealVC = AppDelegate.getRootViewController() as? SWRevealViewController {
     revealVC.dismissViewControllerAnimated(true, completion: nil)
    }
  }
}
  

extension ShareContactsViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
  
  func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
    let title = Constants.EmptyDataSet.Contact.Title
    let titleFontName = Constants.EmptyDataSet.Title.FontName
    let titleFontSize = Constants.EmptyDataSet.Title.FontSize
    let titleColor = Theme.EmptyDataSetTitleColor.toUIColor()
    
    let attributes = [NSFontAttributeName: UIFont(name: titleFontName, size: titleFontSize)!, NSForegroundColorAttributeName: titleColor]
    
    return NSAttributedString(string: title, attributes: attributes)
  }
  
  func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
    let description = Constants.EmptyDataSet.Contact.Description
    let descriptionFontName = Constants.EmptyDataSet.Description.FontName
    let descriptionFontSize = Constants.EmptyDataSet.Description.FontSize
    let descriptionColor = Theme.EmptyDataSetDescriptionColor.toUIColor()
    
    let paragraph = NSMutableParagraphStyle()
    paragraph.lineBreakMode = NSLineBreakMode.ByWordWrapping
    paragraph.alignment = NSTextAlignment.Center
    
    let attributes = [NSFontAttributeName: UIFont(name: descriptionFontName, size: descriptionFontSize)!, NSForegroundColorAttributeName: descriptionColor, NSParagraphStyleAttributeName: paragraph]
    
    return NSAttributedString(string: description, attributes: attributes)
  }
  
  func verticalOffsetForEmptyDataSet(scrollView: UIScrollView!) -> CGFloat {
    return -40.0
  }
  
}
