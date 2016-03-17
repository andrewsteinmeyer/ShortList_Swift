//
//  ContactsViewController+Import.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 1/13/16.
//  Copyright © 2016 Andrew Steinmeyer. All rights reserved.
//

import Contacts
import ContactsUI
import Crashlytics

extension ContactsViewController: CNContactPickerDelegate {
  
  typealias ContactDetails = [String:String]
  
  // MARK: CNContactPickerDelegate
  
  func contactPicker(picker: CNContactPickerViewController, didSelectContacts contacts: [CNContact]) {
    loadSelectedContacts(contacts)
  }
  
  // MARK: Helper functions
  
  func displayContactsController() {
    AppDelegate.getAppDelegate().requestForAccess { (accessGranted) -> Void in
      if accessGranted {
        let contactPickerViewController = CNContactPickerViewController()
        
        //let fullNames = self.contacts.map { contact in contact["name"]! }
        //print("fullNames: \(fullNames)")
        
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
  
  func loadSelectedContacts(contacts: [CNContact]) {
    var contactsToImport = [ContactDetails]()
    
    for selectedContact in contacts {
      let keys = [CNContactFormatter.descriptorForRequiredKeysForStyle(CNContactFormatterStyle.FullName), CNContactEmailAddressesKey, CNContactPhoneNumbersKey]
      
      // keys are available, create contact
      if selectedContact.areKeysAvailable(keys) {
        let contact = createContact(selectedContact)
        contactsToImport.append(contact)
        
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
    
    if !contactsToImport.isEmpty {
      saveContacts(contactsToImport)
    }
    
  }
  
  func createContact(selectedContact: CNContact) -> ContactDetails {
    var newContact = [String:String]()
    
    // grab phone number from phone contact
    var phoneNumber: String!
    for number in selectedContact.phoneNumbers {
      if number.label == CNLabelPhoneNumberMobile {
        phoneNumber = (number.value as! CNPhoneNumber).stringValue
        break
      }
      else if number.label == CNLabelPhoneNumberMain {
        phoneNumber = (number.value as! CNPhoneNumber).stringValue
        break
      }
    }
    
    // grab email from phone contact
    var homeEmailAddress: String!
    for emailAddress in selectedContact.emailAddresses {
      if emailAddress.label == CNLabelHome {
        homeEmailAddress = emailAddress.value as! String
        break
      }
      else if emailAddress.label == CNLabelOther {
        homeEmailAddress = emailAddress.value as! String
        break
      }
    }
    
    newContact["name"] = CNContactFormatter.stringFromContact(selectedContact, style: .FullName)
    newContact["phone"] = phoneNumber.stringByRemovingOccurrencesOfCharacters(" )(- ") ?? ""
    newContact["email"] = homeEmailAddress ?? ""
    newContact["source"] = "iPhone"
    
    return newContact
  }
  
  func saveContacts(contacts: [ContactDetails]) {
    guard contacts.count > 0 else {
      print("No contacts to persist to database")
      return
    }
    
    let parameters = [contacts]
    
    MeteorContactService.sharedInstance.importContacts(parameters) {
      result, error in
      
      if error != nil {
        print("error importing contacts to database: \(error?.localizedDescription)")
      } else {
        print("success importing contacts to database")
        
        for addedContact in contacts {
          Answers.logCustomEventWithName("Import Contact",
            customAttributes: [
              "User": (AccountManager.defaultAccountManager.currentUser?.fullName)!,
              "Contact Name": addedContact["name"]!,
              "Contact Phone": addedContact["phone"]!,
              "Contact Email": addedContact["email"]!,
              "Source": "iPhone"
            ]
          )
        }
      }
    }
  }
  
}