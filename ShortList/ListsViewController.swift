//  ListsViewController.swift
//  Shortlist
//
//  Created by Andrew Steinmeyer on 12/6/15.
//  Copyright © 2015 Andrew Steinmeyer. All rights reserved.
//

import UIKit
import CoreData
import Meteor

class ListsViewController: FetchedResultsTableViewController {
  
  private let listSubscriptionName = "PrivateLists"
  private let modelName = "List"
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.managedObjectContext = Meteor.mainQueueManagedObjectContext
    
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    self.setNavigationBarItem()
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "accountDidChange", name: METDDPClientDidChangeAccountNotification, object: Meteor)
    
    updateUserBarButtonItem()
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    
    NSNotificationCenter.defaultCenter().removeObserver(self, name: "accountDidChange", object: Meteor)
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
      cell.textLabel!.text = list.name
    }
  }
  
  func dataSource(dataSource: FetchedResultsTableViewDataSource, deleteObject object: NSManagedObject, atIndexPath indexPath: NSIndexPath) {
    guard object is List else {
      return
    }
    
    // grab documentID
    let documentID = Meteor.persistentStore.documentKeyForObjectID(object.objectID).documentID
    
    let parameters = [documentID]
   
    MeteorService.deleteList(parameters) {
      result, error in
      
      if error != nil {
        print("error: \(error?.localizedDescription)")
      } else {
        print("hooray!")
      }
    }
  }
  
  // MARK: - Adding List
  
  @IBAction func addList(sender: AnyObject) {
    let alertController = UIAlertController(title: nil, message: "Add List", preferredStyle: .Alert)
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
    }
    alertController.addAction(cancelAction)
    
    let addAction = UIAlertAction(title: "Add", style: .Default) { (action) in
      guard let nameTextField = alertController.textFields?[0],
        let name = nameTextField.text where !name.isEmpty else {
        return
      }
      
      let parameters = [name]
      
      MeteorService.createList(parameters) {
        result, error in
        
        if error != nil {
          print("error: \(error?.localizedDescription)")
        } else {
          print("hooray!")
        }
      }
    }
    alertController.addAction(addAction)
    
    alertController.addTextFieldWithConfigurationHandler { (textField) in
      textField.placeholder = "Name"
      textField.autocapitalizationType = .Words
      textField.returnKeyType = .Done
      textField.enablesReturnKeyAutomatically = true
    }
    
    presentViewController(alertController, animated: true, completion: nil)
  }

  // MARK: - Signing In and Out
  
  func accountDidChange() {
    dispatch_async(dispatch_get_main_queue()) {
      self.updateUserBarButtonItem()
    }
  }
  
  func updateUserBarButtonItem() {
    if Meteor.userID == nil {
      //userBarButtonItem.image = UIImage(named: "user_icon")
      //userAddButtonItem.enabled = false
    } else {
      //userBarButtonItem.image = UIImage(named: "user_icon_selected")
      //userAddButtonItem.enabled = true
    }
  }
  
  /*
  @IBAction func userButtonPressed(sender: AnyObject) {
    if Meteor.userID == nil {
      performSegueWithIdentifier("SignIn", sender: nil)
    } else {
      showUserAlertSheet()
    }
  }
*/
  
  func showUserAlertSheet() {
    let currentUser = self.currentUser
    
    let username = currentUser?.username
    let message = username != nil ? "Signed in as \(username!)." : "Signed in."
    
    let alertController = UIAlertController(title: nil, message: message, preferredStyle: .ActionSheet)
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
    }
    alertController.addAction(cancelAction)
    
    let signOutAction = UIAlertAction(title: "Sign Out", style: .Destructive) { (action) in
      Meteor.logoutWithCompletionHandler(nil)
    }
    alertController.addAction(signOutAction)
    
    presentViewController(alertController, animated: true, completion: nil)
  }
  
  // MARK: - Segues
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "showDetail" {
      if let selectedList = dataSource.selectedObject as? List {
        if let contactsViewcontroller = segue.destinationViewController as? ListContactsViewController {
          contactsViewcontroller.managedObjectContext = managedObjectContext
          contactsViewcontroller.listID = selectedList.objectID
        }
      }
    }
  }
  
  @IBAction func unwindFromSignIn(segue: UIStoryboardSegue) {
    // Shouldn't be needed, but without it the modal view controller isn't dismissed on the iPad
    dismissViewControllerAnimated(true, completion: nil)
  }
}
