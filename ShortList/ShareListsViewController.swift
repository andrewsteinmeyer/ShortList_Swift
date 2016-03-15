//
//  ShareListsViewController.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 3/14/16.
//  Copyright © 2016 Andrew Steinmeyer. All rights reserved.
//


import UIKit
import CoreData
import DZNEmptyDataSet
import PhoneNumberKit

class ShareListsViewController: FetchedResultsTableViewController {
  
  private let PrivateListSubscriptionName = "PrivateLists"
  private let PublicListSubscriptionName = "PublicLists"
  private let modelName = "List"
  
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
    else if segue.identifier == "generateListQRCode" {
      if let selectedList = dataSource.selectedObject as? List {
        if let QRCodeViewController = segue.destinationViewController as? QRCodeViewController {
          var listName = ""
          
          // grab list documentID
          let documentID = Meteor.documentKeyForObjectID(selectedList.objectID).documentID
          
          // set name
          if let name = selectedList.valueForKey("name") as? String {
            listName = name
          }
          
          QRCodeViewController.navigationItem.title = "List"
          QRCodeViewController.name = listName
          QRCodeViewController.type = "list"
          QRCodeViewController.documentID = documentID as! String
        }
      }
    }
  }

  // MARK: - Content Loading
  
  override func configureSubscriptionLoader(subscriptionLoader: SubscriptionLoader) {
    subscriptionLoader.addSubscriptionWithName(PrivateListSubscriptionName)
    subscriptionLoader.addSubscriptionWithName(PublicListSubscriptionName)
  }
  
  override func createFetchedResultsController() -> NSFetchedResultsController? {
    let fetchRequest = NSFetchRequest(entityName: modelName)
    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "insertedOn", ascending: false)]
    
    return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
  }
  
  // MARK: - FetchedResultsTableViewDataSourceDelegate
  
  func dataSource(dataSource: FetchedResultsTableViewDataSource, configureCell cell: UITableViewCell, forObject object: NSManagedObject, atIndexPath indexPath: NSIndexPath) {
    if let list = object as? List {
      if let cell = cell as? ListsTableViewCell {
        var listName = ""
        
        // set name
        if let name = list.valueForKey("name") as? String {
          listName = name
        }
        
        let data = ListsTableViewCellData(name: listName)
        cell.setData(data)
      }
    }
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    performSegueWithIdentifier("generateListQRCode", sender: indexPath)
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


extension ShareListsViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
  
  func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
    let title = Constants.EmptyDataSet.List.Title
    let titleFontName = Constants.EmptyDataSet.Title.FontName
    let titleFontSize = Constants.EmptyDataSet.Title.FontSize
    let titleColor = Theme.EmptyDataSetTitleColor.toUIColor()
    
    let attributes = [NSFontAttributeName: UIFont(name: titleFontName, size: titleFontSize)!, NSForegroundColorAttributeName: titleColor]
    
    return NSAttributedString(string: title, attributes: attributes)
  }
  
  func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
    let description = Constants.EmptyDataSet.List.Description
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
