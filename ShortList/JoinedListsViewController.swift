//
//  JoinedListsViewController.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 1/12/16.
//  Copyright © 2016 Andrew Steinmeyer. All rights reserved.
//


import UIKit
import CoreData
import Meteor

class JoinedListsViewController: FetchedResultsTableViewController {
  
  @IBOutlet weak var menuButton: UIBarButtonItem!
  
  private let subscriptionName = "PrivateLists"
  private let modelName = "List"
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.managedObjectContext = Meteor.mainQueueManagedObjectContext
    
    if self.revealViewController() != nil {
      menuButton.target = self.revealViewController()
      menuButton.action = "revealToggle:"
      self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
    }
    
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "showListDetail" {
      if let selectedList = dataSource.selectedObject as? List {
        if let listDetailViewController = segue.destinationViewController as? ListDetailViewController {
          listDetailViewController.navigationItem.title = selectedList.name
          listDetailViewController.list = selectedList
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
    fetchRequest.predicate = NSPredicate(format: "userId != %@", AccountManager.defaultAccountManager.currentUserId!)
    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "insertedOn", ascending: false)]
    
    return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
  }
  
  // MARK: - UITableViewDelegate
  
  // chage "Delete" button to "Leave"
  override func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String? {
    return "Leave"
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
  
  func dataSource(dataSource: FetchedResultsTableViewDataSource, deleteObject object: NSManagedObject, atIndexPath indexPath: NSIndexPath) {
    guard object is List else {
      return
    }
    
    // grab joined list documentID
    let documentID = Meteor.documentKeyForObjectID(object.objectID).documentID
    
    MeteorListService.sharedInstance.delete([documentID]) {
      result, error in
      
      if error != nil {
        print("error: \(error?.localizedDescription)")
      } else {
        print("success: list deleted")
      }
    }
  }
  
}