//
//  User.swift
//  Shortlist
//
//  Created by Andrew Steinmeyer on 12/6/15.
//  Copyright © 2015 Andrew Steinmeyer. All rights reserved.
//

class User {
  
  var firstName: String?
  var lastName: String?
  var emailAddress: String?
  
  var fullName: String? {
    didSet {
      guard fullName != nil else { return }
      
      let fullNameArr = self.fullName!.componentsSeparatedByString(" ")
      firstName = fullNameArr[0]
      lastName = fullNameArr[1]
    }
  }
}
