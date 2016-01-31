//
//  EventsViewController.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 1/4/16.
//  Copyright © 2016 Andrew Steinmeyer. All rights reserved.
//

import UIKit
import CoreData
import Meteor

private let dateFormatter: NSDateFormatter = {
  let formatter = NSDateFormatter()
  formatter.dateFormat = "EEE, MMM d" // ie. Thu, Jun 8
  
  return formatter
}()

private let timeFormatter: NSDateFormatter = {
  let formatter = NSDateFormatter()
  formatter.dateStyle = .NoStyle
  formatter.timeStyle = .ShortStyle // ie. 11:10 PM
  
  return formatter
}()

class EventsViewController: FetchedResultsTableViewController {
  
  @IBOutlet weak var menuButton: UIBarButtonItem!
  
  private let subscriptionName = "PrivateEvents"
  private let modelName = "Event"
  
  private var selectedEvent: Event?
  
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
    if segue.identifier == "showInvitationActivity" {
      if let selectedEvent = dataSource.selectedObject as? Event {
        let navVC = segue.destinationViewController as? InvitationNavigationViewController
        if let invitationActivityViewController = navVC?.topViewController as? InvitationActivityViewController {
          // get documentID for event
          let documentID = Meteor.documentKeyForObjectID(selectedEvent.objectID).documentID as! String
          
          // load url to request
          invitationActivityViewController.url = MeteorRouter.invitationActivityForEventID(documentID)
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
    if let event = object as? Event {
      if let cell = cell as? EventsTableViewCell {
        var locationName = ""
        var eventDate = ""
        var eventTime = ""
        var acceptedCount = "0"
        
        // get location address
        if let location = event.location {
          let JSONLocation = JSON(location)
          
          if let name = JSONLocation["name"].string {
            locationName = name
          }
        }
        
        // set date and time
        if let date = event.date {
          eventDate = dateFormatter.stringFromDate(date) as String
          eventTime = timeFormatter.stringFromDate(date) as String
        }
        
        // set accepted count
        if let count = event.acceptedCount {
          acceptedCount = String(count)
        }
        
        let data = EventsTableViewCellData(name: event.name, locationName: locationName, date: eventDate, time: eventTime, acceptedCount: acceptedCount)
        cell.setData(data)
      }
    }
  }
  
  func dataSource(dataSource: FetchedResultsTableViewDataSource, deleteObject object: NSManagedObject, atIndexPath indexPath: NSIndexPath) {
    guard let event = object as? Event else {
      return
    }
    
    // get documentID for event
    let documentID = Meteor.documentKeyForObjectID(event.objectID).documentID
    
    // delete event
    MeteorEventService.sharedInstance.delete([documentID]) {
      result, error in
      
      if error != nil {
        print("error: \(error?.localizedDescription)")
      } else {
        print("success: event deleted")
      }
    }
  }
  
  override func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
    if let selectedEvent = dataSource.objectAtIndexPath(indexPath) as? Event {
      if let eventDetailNavController = self.storyboard?.instantiateViewControllerWithIdentifier("EventDetailNavigationController") as? UINavigationController {
        eventDetailNavController.navigationItem.title = selectedEvent.name
        
        // pass event to Detail View Controller and present Nav Controller modally
        if let eventDetailViewController = eventDetailNavController.topViewController as? EventDetailViewController {
          eventDetailViewController.event = selectedEvent
          presentViewController(eventDetailNavController, animated: true, completion: nil)
        }
      }
    }
  }
  
}
