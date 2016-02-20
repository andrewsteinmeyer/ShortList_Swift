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
  
  var name: String = "No name" {
    didSet {
      let fullNameArr = self.name.componentsSeparatedByString(" ")
      firstName = fullNameArr[0]
      lastName = fullNameArr[1]
    }
  }
}
