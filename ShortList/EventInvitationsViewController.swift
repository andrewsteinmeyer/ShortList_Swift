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
  private let modelName = "EventInvitation"
  
  var eventId: String!
  var statusCategory: String!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // show navigation bar
    self.navigationController?.navigationBarHidden = false
    
    // set CoreData context
    self.managedObjectContext = Meteor.mainQueueManagedObjectContext
  }
  
  // MARK: - Content Loading
  
  override func configureSubscriptionLoader(subscriptionLoader: SubscriptionLoader) {
    // subscribe to invitations on this event
    subscriptionLoader.addSubscriptionWithName(subscriptionName, parameters: [ eventId ])
  }
  
  override func createFetchedResultsController() -> NSFetchedResultsController? {
    let fetchRequest = NSFetchRequest(entityName: modelName)
    fetchRequest.predicate = NSPredicate(format: "(eventId == %@) AND (status == %@)", eventId, statusCategory)
    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "insertedOn", ascending: false)]
    
    return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
  }
  
  // MARK: - FetchedResultsTableViewDataSourceDelegate
  
  func dataSource(dataSource: FetchedResultsTableViewDataSource, configureCell cell: UITableViewCell, forObject object: NSManagedObject, atIndexPath indexPath: NSIndexPath) {
    if let invitation = object as? EventInvitation {
      if let cell = cell as? InviteeTableViewCell {
        var inviteeName = ""
        
        // set name
        if let name = invitation.valueForKey("name") as? String {
          inviteeName = name
        }
        
        let data = InviteeTableViewCellData(name: inviteeName)
        cell.setData(data)
      }
    }
  }
  
  // do not allow "Delete"
  override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
    return UITableViewCellEditingStyle.None
  }
  
  
}
