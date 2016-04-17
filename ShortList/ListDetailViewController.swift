//
//  ListDetailViewController.swift
//  Shortlist
//
//  Created by Andrew Steinmeyer on 12/6/15.
//  Copyright © 2015 Andrew Steinmeyer. All rights reserved.
//

import UIKit
import PhoneNumberKit

class ListDetailViewController: UITableViewController {
  
  private var contacts = [[String:String]]()
  
  var list: List? {
    didSet {
      // reset contacts
      contacts = []
      
      // retrieve contacts from list
      if let listContacts = list?.contacts as NSSet? {
        let JSONContacts = JSON(listContacts)
        
        // iterate over contacts
        for (_,contact):(String, JSON) in JSONContacts {
          
          let name = contact["name"].string ?? ""
          let email = contact["email"].string ?? ""
          var phone = contact["phone"].string ?? ""
          
          // make sure there is at least a name the contact
          guard !name.isEmpty else {
            continue
          }
          
          // set phone number
          if phone != "" {
            var phoneNumber: PhoneNumber?
            
            do {
              phoneNumber = try PhoneNumber(rawNumber: phone)
            }
            catch {
              print("Error: Could not parse raw phone number")
            }
            
            if let number = phoneNumber?.toNational() {
              phone = number
            }
          }
          
          let newContact = ["name": name,
                            "email": email,
                            "phone": phone]
            
          contacts.append(newContact)
        }
      }
    }
  }

  // MARK: UITableView Delegate and Datasource functions
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return contacts.count
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! ContactsTableViewCell
    
    let contact = contacts[indexPath.row]
    
    let data = ContactsTableViewCellData(name: contact["name"], phone: contact["phone"], email: contact["email"])
    cell.setData(data)
      
    return cell
  }
  
}
