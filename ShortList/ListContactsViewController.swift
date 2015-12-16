// Copyright (c) 2014-2015 Martijn Walraven
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit
import CoreData
import Meteor
import Contacts
import ContactsUI


class ListContactsViewController: UITableViewController {
  
  var managedObjectContext: NSManagedObjectContext!
  
  // MARK: - Model
  
  var listID: NSManagedObjectID? {
    didSet {
      assert(managedObjectContext != nil)
      
      if listID != nil {
        if listID != oldValue {
          list = (try? managedObjectContext!.existingObjectWithID(self.listID!)) as? List
        }
      } else {
        list = nil
      }
    }
  }
  
  private var listObserver: ManagedObjectObserver?
  
  private var list: List? {
    didSet {
      if list != oldValue {
        if list != nil {
          listObserver = ManagedObjectObserver(list!) { (changeType) -> Void in
            switch changeType {
            case .Deleted, .Invalidated:
              self.list = nil
            case .Updated, .Refreshed:
              break
            default:
              break
            }
          }
        } else {
          listObserver = nil
        }
        
        if let listContacts = list?.valueForKey("contacts") as? [[String:String]] {
          contacts = listContacts
        } else {
          // clear if no list exists
          contacts = []
        }
      }
    }
  }
  
  var contacts = [[String:String]]() {
    didSet {
      if isViewLoaded() {
        tableView.reloadData()
      }
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
  }
  
  // MARK: IBActions
  
  @IBAction func showContacts(sender: AnyObject) {
    displayContactsController()
  }
  
  func displayContactsController() {
    AppDelegate.getAppDelegate().requestForAccess { (accessGranted) -> Void in
      if accessGranted {
        let contactPickerViewController = CNContactPickerViewController()
        
        let fullNames = self.contacts.map { contact in contact["name"]! }
        print("fullNames: \(fullNames)")
        
        //TODO: Filter out contacts that have already been selected and saved.  Having trouble with predicate
        
        //contactPickerViewController.predicateForEnablingContact = NSPredicate(format: "!(name IN %@)", fullNames)
        contactPickerViewController.delegate = self
        
        //contactPickerViewController.displayedPropertyKeys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactEmailAddressesKey, CNContactBirthdayKey, CNContactImageDataKey]
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
          self.presentViewController(contactPickerViewController, animated: true, completion: nil)
        })
      }
    }
  }
  
  // MARK: UITableView Delegate and Datasource functions
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch contacts.count {
    case 0:
      return 1
    default:
      return contacts.count
    }
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    switch contacts.count {
    case 0:
      return tableView.dequeueReusableCellWithIdentifier("NothingFoundCell", forIndexPath: indexPath) as UITableViewCell
    default:
      let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as UITableViewCell!
      
      // get contact
      let currentContact = contacts[indexPath.row]
      
      cell.textLabel?.text = currentContact["name"]
      
      return cell
    }
  }
  
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    switch contacts.count {
    case 0:
      return 100.0
    default:
      return 44.0
    }
  }
  
  // MARK: Helper functions
  
  func loadSelectedContacts(contacts: [CNContact]) {
    for selectedContact in contacts {
      let keys = [CNContactFormatter.descriptorForRequiredKeysForStyle(CNContactFormatterStyle.FullName), CNContactEmailAddressesKey, CNContactPhoneNumbersKey]
      
      // keys are available, create contact
      if selectedContact.areKeysAvailable(keys) {
        createContact(selectedContact)
      }
        // keys not available, refetch keys before creating contact
      else {
        AppDelegate.getAppDelegate().requestForAccess({ (accessGranted) -> Void in
          if accessGranted {
            do {
              let contactRefetched = try AppDelegate.getAppDelegate().contactStore.unifiedContactWithIdentifier(selectedContact.identifier, keysToFetch: keys)
              self.createContact(contactRefetched)
            }
            catch {
              print("Unable to refetch the selected contact.", separator: "", terminator: "\n")
            }
          }
        })
      }
    }
    
  }
  
  func createContact(selectedContact: CNContact) {
    var newContact = [String:String]()
    
    newContact["name"] = CNContactFormatter.stringFromContact(selectedContact, style: .FullName)
    
    var phoneNumber: String!
    for number in selectedContact.phoneNumbers {
      if number.label == CNLabelPhoneNumberMobile {
        phoneNumber = (number.value as! CNPhoneNumber).stringValue
        break
      }
    }
    
    if phoneNumber != nil {
      newContact["phone"] = phoneNumber
    }
    
    var homeEmailAddress: String!
    for emailAddress in selectedContact.emailAddresses {
      if emailAddress.label == CNLabelHome {
        homeEmailAddress = emailAddress.value as! String
        break
      }
    }
    
    if homeEmailAddress != nil {
      newContact["email"] = homeEmailAddress
    }
    
    // add new contact to list
    contacts.append(newContact)
  }
  
  func saveContacts() {
    guard contacts.count > 0 else {
      print("No contacts to persist to database")
      return
    }
    
    let parameters = [self.contacts]
    
    MeteorService.importContacts(parameters) {
      result, error in
      
      if error != nil {
        print("error importing contacts to database: \(error?.localizedDescription)")
      } else {
        dispatch_async(dispatch_get_main_queue()) {
          self.tableView.reloadData()
        }
      }
    }
  }
  
  func updateList() {
    guard let objectID = self.listID
      where contacts.count > 0 else {
        return
    }
    
    // grab documentID for list
    let documentID = Meteor.persistentStore.documentKeyForObjectID(objectID).documentID
    
    let parameters: [AnyObject] = [documentID, self.contacts]
    
    MeteorService.updateListContacts(parameters) {
      result, error in
      
      if error != nil {
        print("error importing contacts to database: \(error?.localizedDescription)")
      } else {
        dispatch_async(dispatch_get_main_queue()) {
          self.tableView.reloadData()
        }
      }
    }
  }
  
}

extension ListContactsViewController: CNContactPickerDelegate {
  
  // MARK: CNContactPickerDelegate
  
  func contactPicker(picker: CNContactPickerViewController, didSelectContacts contacts: [CNContact]) {
    loadSelectedContacts(contacts)
    saveContacts()
    
    updateList()
  }
    

  
}
