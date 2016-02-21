//
//  User.swift
//  Shortlist
//
//  Created by Andrew Steinmeyer on 12/6/15.
//  Copyright © 2015 Andrew Steinmeyer. All rights reserved.
//

import Contacts
import PhoneNumberKit

class User {
  
  var firstName: String?
  var lastName: String?
  var emailAddress: String?
  var image: UIImage?
  
  var fullName: String? {
    didSet {
      guard fullName != nil else { return }
      
      let fullNameArr = self.fullName!.componentsSeparatedByString(" ")
      firstName = fullNameArr[0]
      lastName = fullNameArr.count > 1 ? fullNameArr[1] : ""
    }
  }
  
  var phone: PhoneNumber?
  var rawPhone: String? {
    didSet {
      populateWithLocalContact()
      setPhoneInfo()
    }
  }
  
  func setPhoneInfo() {
    guard let number = rawPhone else { return }
    do {
      phone = try PhoneNumber(rawNumber: number)
    }
    catch {
      print("Error: Could not parse raw phone number")
    }
  }
  
  // Enrich the user by fetching information from the local contact by phone number.
  func populateWithLocalContact() {
    guard let phone = rawPhone else { return }
    
    let store = CNContactStore()
    let authorizationStatus = CNContactStore.authorizationStatusForEntityType(.Contacts)
    
    switch authorizationStatus {
    case .Denied, .NotDetermined:
      store.requestAccessForEntityType(.Contacts) {
        access, error in
        
        if access {
          print("Access granted to Contacts")
        }
        else {
          print("Access to Contacts denied by user")
        }
      }
    default: ()
      
    }
    
    // make sure user has authorized access to local phone contacts
    guard CNContactStore.authorizationStatusForEntityType(.Contacts) == .Authorized else { return }
    
    // fetch phone number and image from local contact info
    let fetchRequest = CNContactFetchRequest(keysToFetch: [CNContactPhoneNumbersKey, CNContactThumbnailImageDataKey])
    
    do {
      try store.enumerateContactsWithFetchRequest(fetchRequest) { (contact, stop) in
        let matchingPhoneNumbers = contact.phoneNumbers.map { $0.value as! CNPhoneNumber }.filter {
          phoneNumber($0, matchesPhoneNumberString: phone)
        }
        
        guard matchingPhoneNumbers.count > 0 else {
          return
        }
        
        // save user image from the local contact
        self.image = contact.thumbnailImageData.flatMap(UIImage.init)
        
        stop.memory = true
      }
    }
    catch let error as NSError {
      print("Error looking for contact: \(error)")
    }
  }
}

private func phoneNumber(phoneNumber: CNPhoneNumber, matchesPhoneNumberString phoneNumberString: String) -> Bool {
  return phoneNumberString.rangeOfString(phoneNumber.stringValue.stringByRemovingOccurrencesOfCharacters(" )(- ")) != nil
}
