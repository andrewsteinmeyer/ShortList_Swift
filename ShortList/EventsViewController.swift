//
//  EventsViewController.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 1/4/16.
//  Copyright © 2016 Andrew Steinmeyer. All rights reserved.
//

import UIKit
import CoreData
import DZNEmptyDataSet


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

class EventsViewController: FetchedResultsCollectionViewController {
  typealias NamedValues = [String:AnyObject]
  
  @IBOutlet weak var menuButton: UIBarButtonItem!
  
  private let PrivateEventsSubscriptionName = "PrivateEvents"
  private let ContactEventsSubscriptionName = "ContactEvents"
  private let modelName = "Event"
  
  private var selectedEvent: Event?
  
  var eventDetailTransitionDelegate: EventDetailTransitioningDelegate?
  var selectionObject: SelectionObject?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // set CoreData context
    self.managedObjectContext = Meteor.mainQueueManagedObjectContext
    
    if self.revealViewController() != nil {
      menuButton.target = self.revealViewController()
      menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
      self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
    }
    
    // setup delegates for empty data
    self.collectionView?.emptyDataSetDelegate = self
    self.collectionView?.emptyDataSetSource = self
    
    setupAppearance()
  }
  
  // MARK: - Content Loading
  
  override func configureSubscriptionLoader(subscriptionLoader: SubscriptionLoader) {
    subscriptionLoader.addSubscriptionWithName(PrivateEventsSubscriptionName)
    subscriptionLoader.addSubscriptionWithName(ContactEventsSubscriptionName)
  }
  
  override func createFetchedResultsController() -> NSFetchedResultsController? {
    let fetchRequest = NSFetchRequest(entityName: modelName)
    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "insertedOn", ascending: false)]
    
    return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
  }
  
  // MARK: - FetchedResultsTableViewDataSourceDelegate
  
  func dataSource(dataSource: FetchedResultsCollectionViewDataSource, configureCell cell: UICollectionViewCell, forObject object: NSManagedObject, atIndexPath indexPath: NSIndexPath) {
    if let event = object as? Event {
      if let cell = cell as? EventsCollectionViewCell {
        var locationName = ""
        var eventDate = ""
        var eventTime = ""
        var acceptedCount = "0"
        var declinedCount = "0"
        var eventName = ""
        var listName = ""
        var eventDescription = ""
        
        // set name
        if let name = event.valueForKey("name") as? String {
          eventName = name
        }
        
        // set venue name
        if let venue = event.valueForKey("venue") as? NamedValues {
          let JSONVenue = JSON(venue)
          
          if let venueName = JSONVenue["name"].string {
            locationName = venueName
          }
        }
        
        // set date and time
        if let epochDate = event.valueForKey("date") as? NSTimeInterval {
          let date = NSDate(timeIntervalSince1970: epochDate.formatForNSDate())
          
          eventDate = dateFormatter.stringFromDate(date) as String
          eventTime = timeFormatter.stringFromDate(date) as String
        }
        
        // list name
        if let list = event.valueForKey("list") as? NamedValues {
          let JSONList = JSON(list)
          
          listName = JSONList["name"].string ?? ""
        }
        
        //TODO - get eventDescription after changing property name from "description" on server
        // Core data cannot use generic property names because "description" is already used by Core Data
        
        // set accepted count
        if let accepted = event.valueForKey("acceptedCount") as? Int {
          acceptedCount = String(accepted)
        }
        
        // set declined count
        if let declined = event.valueForKey("declinedCount") as? Int {
          declinedCount = String(declined)
        }
        
        let data = EventsCollectionViewCellData(name: eventName, locationName: locationName, date: eventDate, time: eventTime, listName: listName, eventDescription: eventDescription, acceptedCount: acceptedCount, declinedCount: declinedCount)
        cell.setData(data)
        
        if selectionObject != nil &&
          selectionObject?.selectedCellIndexPath == indexPath {
          cell.hide = selectionObject!.hidden
        } else {
          cell.hide = false
        }
      }
    }
  }
  
  //TODO: Implement delete event in UI using this method.
  
  func dataSource(dataSource: FetchedResultsCollectionViewDataSource, deleteObject object: NSManagedObject, atIndexPath indexPath: NSIndexPath) {
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
  
  // pragma mark - UICollectionViewDelegate
  override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    showEventDetailForIndexPath(indexPath)
  }
  
  
  func showEventDetailForIndexPath(indexPath: NSIndexPath) {
    let selectedCell = collectionView?.cellForItemAtIndexPath(indexPath) as! EventsCollectionViewCell
    
    //set rect for selectedCell and save origin in relation to superview (view controller)
    var rect = selectedCell.frame
    let origin = view.convertPoint(rect.origin, toView: selectedCell.superview)
    rect.origin = origin
      
    selectionObject = SelectionObject(snapshot: selectedCell.snapshot, selectedCellIndexPath: indexPath, originalCellPosition: rect)
    eventDetailTransitionDelegate = EventDetailTransitioningDelegate(selectedObject: selectionObject!)
    transitioningDelegate = eventDetailTransitionDelegate
    
    // get main storyboard
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    
    // get event
    let selectedEvent = dataSource.objectAtIndexPath(indexPath) as? Event
    
    //set up eventDetailCollectionVC and set transitionDelegate as its delegate
    let eventDetailVC = storyboard.instantiateViewControllerWithIdentifier("EventDetailCollectionViewController") as! EventDetailCollectionViewController
    eventDetailVC.event = selectedEvent
    eventDetailVC.ticketImage = scaleAndPositionTicketImageInHeaderView(selectedCell.contentView)
    
    let eventDetailNavVC = EventDetailNavigationViewController(rootViewController: eventDetailVC)
    eventDetailNavVC.transitioningDelegate = eventDetailTransitionDelegate
    presentViewController(eventDetailNavVC, animated: true, completion: nil)
    
    //fade out cell's image
    UIView.animateWithDuration(0.5, animations: {
      selectedCell.hide = true
      }, completion: nil)
  }
  
  // hide selected image view and reload cell
  func hideImage(hidden: Bool, indexPath: NSIndexPath) {
    if selectionObject != nil {
      selectionObject!.hidden = hidden
    }
    
    collectionView?.reloadItemsAtIndexPaths([indexPath])
  }
  
  //MARK: Private methods
  
  private func setupAppearance() {
    self.navigationItem.rightBarButtonItem?.tintColor = Theme.NavigationBarActionButtonTextColor.toUIColor()
  }
  
  private func scaleAndPositionTicketImageInHeaderView(ticketView: UIView) -> UIImage {
    
    var ticketFrame = ticketView.frame
    
    // scale ticket to fill header view
    // use the same size ratio of the smaller ticket
    let ratio = ticketFrame.size.width / ticketFrame.size.height
    
    // calculate new ticket size
    ticketFrame.size.width = self.view.frame.size.width - Constants.EventDetailCollection.Padding
    ticketFrame.size.height = ticketFrame.size.width / ratio
    
    // update ticket frame with new size
    ticketView.frame = ticketFrame
    
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(ticketView.bounds.size.width, 256), false, UIScreen.mainScreen().scale)
    ticketView.drawViewHierarchyInRect(ticketView.bounds, afterScreenUpdates: true)
    let croppedTicketImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return croppedTicketImage
  }
  
}

//MARK: Empty Data Set

extension EventsViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
  
  func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
    let title = Constants.EmptyDataSet.Event.Title
    let titleFontName = Constants.EmptyDataSet.Title.FontName
    let titleFontSize = Constants.EmptyDataSet.Title.FontSize
    let titleColor = Theme.EmptyDataSetTitleColor.toUIColor()
    
    let attributes = [NSFontAttributeName: UIFont(name: titleFontName, size: titleFontSize)!, NSForegroundColorAttributeName: titleColor]
    
    return NSAttributedString(string: title, attributes: attributes)
  }
  
  func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
    let description = Constants.EmptyDataSet.Event.Description
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
