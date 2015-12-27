//
//  VenuesViewController.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 12/24/15.
//  Copyright © 2015 Andrew Steinmeyer. All rights reserved.
//

import Foundation

import UIKit
import CoreData
import Meteor

class VenuesViewController: FetchedResultsTableViewController {
  
  private let listSubscriptionName = "PrivateVenues"
  private let modelName = "Venue"
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
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
    if let venue = object as? Venue {
      if let cell = cell as? VenuesTableViewCell {
        let data = VenuesTableViewCellData(name: venue.name)
        cell.setData(data)
      }
    }
  }
  
  func dataSource(dataSource: FetchedResultsTableViewDataSource, deleteObject object: NSManagedObject, atIndexPath indexPath: NSIndexPath) {
    guard let venue = object as? Venue else {
      return
    }
    
    // get documentID for venue
    let documentID = Meteor.documentKeyForObjectID(venue.objectID).documentID
    
    // delete venue
    MeteorContactService.sharedInstance.delete([documentID]) {
      result, error in
      
      if error != nil {
        print("error: \(error?.localizedDescription)")
      } else {
        print("success: contact deleted")
      }
    }
  }

}
  