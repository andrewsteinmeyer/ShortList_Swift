//
//  HomeViewController.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 12/14/15.
//  Copyright © 2015 Andrew Steinmeyer. All rights reserved.
//

import UIKit
import CoreData
import DZNEmptyDataSet
import DateTools

class HomeViewController: FetchedResultsTableViewController {

  @IBOutlet weak var menuButton: UIBarButtonItem!
  
  private let subscriptionName = "PrivateAlerts"
  private let modelName = "Alert"
  
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // set CoreData context
    self.managedObjectContext = Meteor.mainQueueManagedObjectContext
    
    // present sign in screen if user is not already logged in
    guard AccountManager.defaultAccountManager.isUserLoggedIn else {
      SignInViewController.presentSignInViewController()
      
      return
    }
    
    if self.revealViewController() != nil {
      menuButton.target = self.revealViewController()
      menuButton.action = "revealToggle:"
      self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
    }
    
    // setup delegates for empty data
    self.tableView.emptyDataSetDelegate = self
    self.tableView.emptyDataSetSource = self
    
    // set up auto resizing table view cells
    self.tableView.rowHeight = UITableViewAutomaticDimension
    self.tableView.estimatedRowHeight = 100
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    guard let indexPath = sender as? NSIndexPath,
      selectedAlert = dataSource.objectAtIndexPath(indexPath) as? Alert else {
        return
    }
    
    if segue.identifier == "showAlertLink" {
      if let alertLinkViewController = segue.destinationViewController as? AlertLinkViewController {
        // set type
        if let type = selectedAlert.valueForKey("alertType") as? String,
          let link = selectedAlert.valueForKey("link") as? String {
            
          // set title
          alertLinkViewController.navigationItem.title = type
            
          // load url to request
          alertLinkViewController.url = MeteorRouter.alertLink(link)
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
    
    print("managed: \(managedObjectContext)")
    print("fetchRequest: \(fetchRequest)")
    
    return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
  }
  
  // MARK: - FetchedResultsTableViewDataSourceDelegate
  
  func dataSource(dataSource: FetchedResultsTableViewDataSource, configureCell cell: UITableViewCell, forObject object: NSManagedObject, atIndexPath indexPath: NSIndexPath) {
    if let alert = object as? Alert {
      if let cell = cell as? AlertsTableViewCell {
        var alertTitle = ""
        var alertType = ""
        var alertLink = ""
        var timeSinceAlert = ""
        
        // set title
        if let title = alert.valueForKey("title") as? String {
          alertTitle = title
        }
        
        // set type
        if let type = alert.valueForKey("alertType") as? String {
          alertType = type
        }
        
        // set link
        if let link = alert.valueForKey("link") as? String {
          alertLink = link
        }
        
        // time since alert
        let alertTime = alert.insertedOn
        let date = NSDate(timeIntervalSince1970: alertTime)
        timeSinceAlert = date.timeAgoSinceNow()
        
        let data = AlertsTableViewCellData(alertType: alertType, title: alertTitle, link: alertLink, insertedOn: timeSinceAlert)
        cell.setData(data)
      }
    }
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    performSegueWithIdentifier("showAlertLink", sender: indexPath)

    /*
    // set name of event
    invitationVC.navigationItem.title = eventName
    
    // load url to request
    invitationVC.url = MeteorRouter.invitationActivityForEventID(eventId)
    
    // populate the navigation controller
    let navVC = EventsNavigationViewController()
    navVC.setViewControllers([eventsViewController, invitationVC], animated: false)
    
    // present the invitation activity page
    revealViewController.pushFrontViewController(navVC, animated: true)
    */
  }
  
}

extension HomeViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {

  func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
    let title = Constants.EmptyDataSet.Home.Title
    let titleFontName = Constants.EmptyDataSet.Title.FontName
    let titleFontSize = Constants.EmptyDataSet.Title.FontSize
    let titleColor = Theme.EmptyDataSetTitleColor.toUIColor()
    
    let attributes = [NSFontAttributeName: UIFont(name: titleFontName, size: titleFontSize)!, NSForegroundColorAttributeName: titleColor]
    
    return NSAttributedString(string: title, attributes: attributes)
  }
  
  func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
    let description = Constants.EmptyDataSet.Home.Description
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
