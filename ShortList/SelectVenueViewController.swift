//
//  SelectVenueViewController.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 1/7/16.
//  Copyright © 2016 Andrew Steinmeyer. All rights reserved.
//


import UIKit
import CoreData
import Meteor

protocol SelectVenueViewControllerDelegate {
  func selectVenueViewControllerDidSelectVenue(venue: Venue)
}

class SelectVenueViewController: FetchedResultsTableViewController {
  typealias NamedValues = [String:AnyObject]
  
  private let listSubscriptionName = "PrivateVenues"
  private let modelName = "Venue"
  
  var selectedVenue: Venue?
  
  weak var delegate: CreateEventViewController?
  
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
    if let venue = object as? Venue {
      if let cell = cell as? VenuesTableViewCell {
        var locationAddress = ""
        
        if let location = venue.valueForKey("location") as? NamedValues {
          let JSONLocation = JSON(location)
          
          if let address = JSONLocation["address"].string {
            locationAddress = address
          }
        }
        
        let data = VenuesTableViewCellData(name: venue.name, address: locationAddress)
        cell.setData(data)
        
        // highlight venue if one is already selected
        if selectedVenue?.name == venue.name {
          cell.toggleHighlight()
        }
      }
    }
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let cell = tableView.cellForRowAtIndexPath(indexPath) as? VenuesTableViewCell
    
    // user picked same venue
    if cell?.highlight == true {
      self.navigationController?.popViewControllerAnimated(true)
    }
    // user picked new venue
    else {
      cell?.toggleHighlight()
      
      if let selectedVenue = dataSource.objectAtIndexPath(indexPath) as? Venue {
        if cell?.highlight == true {
          delegate?.selectVenueViewControllerDidSelectVenue(selectedVenue)
          self.navigationController?.popViewControllerAnimated(true)
        }
      }
    }
  }
  
  // do not allow "Delete"
  override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
    return UITableViewCellEditingStyle.None
  }
  
  private func setupAppearance() {
    self.navigationItem.rightBarButtonItem?.tintColor = Theme.NavigationBarActionButtonTextColor.toUIColor()
  }
  
}