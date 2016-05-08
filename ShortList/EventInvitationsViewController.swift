//
//  EventInvitationsViewController.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 4/24/16.
//  Copyright © 2016 Andrew Steinmeyer. All rights reserved.
//


import UIKit
import CoreData


class EventInvitationsViewController: FetchedResultsTableViewController {
  typealias NamedValues = [String:AnyObject]
  
  private let subscriptionName = "EventInvitations"
  private let modelName = "Invitation"
  
  var eventId: String!
  var statusCategory: String!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // set CoreData context
    self.managedObjectContext = Meteor.mainQueueManagedObjectContext
  }
  
  // MARK: - Content Loading
  
  override func configureSubscriptionLoader(subscriptionLoader: SubscriptionLoader) {
    // subscribe to invitations on this event
    subscriptionLoader.addSubscriptionWithName(subscriptionName, parameters: eventId)
  }
  
  override func createFetchedResultsController() -> NSFetchedResultsController? {
    let fetchRequest = NSFetchRequest(entityName: modelName)
    fetchRequest.predicate = NSPredicate(format: "(status == %@) && (eventId == %@)", statusCategory, eventId)
    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "insertedOn", ascending: false)]
    
    return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
  }
  
  // MARK: - FetchedResultsTableViewDataSourceDelegate
  
  func dataSource(dataSource: FetchedResultsTableViewDataSource, configureCell cell: UITableViewCell, forObject object: NSManagedObject, atIndexPath indexPath: NSIndexPath) {
    
    if let invitation = object as? Invitation {
      if let cell = cell as? InviteeTableViewCell {
        let data = InviteeTableViewCellData(invitation: invitation)
        cell.setData(data)
      }
    }
  }
  
  // do not allow "Delete"
  override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
    return UITableViewCellEditingStyle.None
  }
  
  
}
