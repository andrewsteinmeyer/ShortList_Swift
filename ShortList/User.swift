//
//  User.swift
//  Shortlist
//
//  Created by Andrew Steinmeyer on 12/6/15.
//  Copyright © 2015 Andrew Steinmeyer. All rights reserved.
//

import CoreData

class User: NSManagedObject {
  typealias NamedValues = [String:AnyObject]
  
  @NSManaged var creationDate: NSDate?
  @NSManaged var username: String?
  
  @NSManaged var emailAddresses: [NamedValues]?
  var emailAddress: String? {
    return emailAddresses?.first?["address"] as? String
  }
  
  @NSManaged var profile: NamedValues?
  @NSManaged var services: NamedValues?
}
