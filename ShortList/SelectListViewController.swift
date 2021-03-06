//
//  SelectListViewController.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 1/7/16.
//  Copyright © 2016 Andrew Steinmeyer. All rights reserved.
//

import UIKit
import CoreData

protocol SelectListViewControllerDelegate {
  func selectListViewControllerDidSelectList(list: List)
}

class SelectListViewController: FetchedResultsTableViewController {
  
  private let listSubscriptionName = "PrivateLists"
  private let modelName = "List"
  
  var selectedList: List?
  
  weak var delegate: InvitationSettingsViewController?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.managedObjectContext = Meteor.mainQueueManagedObjectContext
    
    setupAppearance()
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
    if let list = object as? List {
      if let cell = cell as? ListsTableViewCell {
        let data = ListsTableViewCellData(name: list.name)
        cell.setData(data)
        
        // highlight list if one is already selected
        if selectedList?.name == list.name {
          cell.toggleHighlight()
        }
      }
    }
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let cell = tableView.cellForRowAtIndexPath(indexPath) as? ListsTableViewCell
    
    // user picked same list
    if cell?.highlight == true {
      self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    // user picked new list
    else {
      cell?.toggleHighlight()
      
      if let selectedList = dataSource.objectAtIndexPath(indexPath) as? List {
        if cell?.highlight == true {
          // pass selected list back to delegate
          delegate?.selectListViewControllerDidSelectList(selectedList)
          
          self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
        }
      }
    }
  }
  
  // MARK: IBAction methods
    
  @IBAction func selectListDidCancel(sender: AnyObject) {
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  // do not allow "Delete"
  override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
    return UITableViewCellEditingStyle.None
  }
  
  private func setupAppearance() {
    self.navigationItem.rightBarButtonItem?.tintColor = Theme.NavigationBarActionButtonTextColor.toUIColor()
  }
  
}