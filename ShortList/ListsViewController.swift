//  ListsViewController.swift
//  Shortlist
//
//  Created by Andrew Steinmeyer on 12/6/15.
//  Copyright © 2015 Andrew Steinmeyer. All rights reserved.
//


import UIKit
import CoreData
import DZNEmptyDataSet
import DZNSegmentedControl

class ListsViewController: FetchedResultsTableViewController {
  
  private let PrivateListSubscriptionName = "PrivateLists"
  private let PublicListSubscriptionName = "PublicLists"
  private let ContactListSubscriptionName = "ContactLists"
  private let modelName = "List"
  
  private enum ListType: Int {
    case Owned = 0
    case Joined
  }
  
  lazy var control: DZNSegmentedControl = {
    let menuItems = ["Owned", "Joined"]
    
    var tempControl = DZNSegmentedControl.init(items: menuItems)
    tempControl.selectedSegmentIndex = 0
    tempControl.backgroundColor = Theme.DZNSegmentBackgroundColor.toUIColor()
    tempControl.height = 60
    tempControl.showsCount = false
    //tempControl.font = UIFont(name: "Lato", size: 20)!
    tempControl.delegate = self
    
    // call didChangeSegment when user taps segment control
    tempControl.addTarget(self, action: #selector(ListsViewController.didChangeSegment), forControlEvents: .ValueChanged)
    
    return tempControl
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // set CoreData context
    self.managedObjectContext = Meteor.mainQueueManagedObjectContext
    
    // set DZNSegmentControl header
    self.tableView.tableHeaderView = self.control
    
    // setup delegates for empty data
    self.tableView.emptyDataSetDelegate = self
    self.tableView.emptyDataSetSource = self
    
    setupAppearance()
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
    subscriptionLoader.addSubscriptionWithName(PrivateListSubscriptionName)
    subscriptionLoader.addSubscriptionWithName(PublicListSubscriptionName)
    subscriptionLoader.addSubscriptionWithName(ContactListSubscriptionName)
  }
  
  override func createFetchedResultsController() -> NSFetchedResultsController? {
    let fetchRequest = NSFetchRequest(entityName: modelName)
    
    if let activeList = ListType(rawValue: self.control.selectedSegmentIndex) {
      switch activeList {
        case .Owned:
          fetchRequest.predicate = NSPredicate(format: "userId == %@", AccountManager.defaultAccountManager.currentUserId!)
          fetchRequest.sortDescriptors = [NSSortDescriptor(key: "insertedOn", ascending: false)]
        case .Joined:
          // find lists that the user has joined by searching for the user's email address
          let emailPredicate = NSPredicate { (evaluatedObject, _) in
            if let listContacts = (evaluatedObject as! List).contacts as NSSet? {
              let JSONContacts = JSON(listContacts)
              
              for (_,contact):(String, JSON) in JSONContacts {
                let email = contact["email"].string ?? ""
                
                // found user's email in the list contacts
                if email == AccountManager.defaultAccountManager.currentUser?.emailAddress {
                  return true
                }
              }
            }
            
            // could not evaluate contacts in list
            return false
          }
          
          // find lists where the user is not the owner
          let userPredicate = NSPredicate(format: "userId != %@", AccountManager.defaultAccountManager.currentUserId!)
        
          // combine the predicates and sort by date inserted
          fetchRequest.predicate = NSCompoundPredicate(type: .AndPredicateType, subpredicates: [userPredicate, emailPredicate])
          fetchRequest.sortDescriptors = [NSSortDescriptor(key: "insertedOn", ascending: false)]
      }
    }
    
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
  
  func dataSource(dataSource: FetchedResultsTableViewDataSource, deleteObject object: NSManagedObject, atIndexPath indexPath: NSIndexPath) {
    guard object is List else {
      return
    }
    
    // grab list documentID
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
  
  // MARK: - Private
  
  private func setupAppearance() {
    self.navigationItem.rightBarButtonItem?.tintColor = Theme.NavigationBarActionButtonTextColor.toUIColor()
    
    let textColor = Theme.NavigationBarTintColor.toUIColor()
    self.navigationController?.navigationBar.titleTextAttributes =   ([NSFontAttributeName: UIFont(name: "Lato", size: 23)!, NSForegroundColorAttributeName: textColor])
  }
  
  func didChangeSegment() {
    self.setNeedsLoadContent()
  }
  
  // MARK: - Static functions
  
  static func presentListsViewController() {
    
  }
  
}

extension ListsViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
  
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

extension ListsViewController: DZNSegmentedControlDelegate {
  
  func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
    return UIBarPosition.Top
  }
  
}

