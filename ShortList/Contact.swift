//
//  Contact.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 12/17/15.
//  Copyright © 2015 Andrew Steinmeyer. All rights reserved.
//

import CoreData

class Contact: NSManagedObject {
  
  @NSManaged var _id: String?
  @NSManaged var userId: String?
  @NSManaged var insertedOn: String?
  @NSManaged var name: String?
  @NSManaged var email: String?
  @NSManaged var phone: String?
  @NSManaged var source: String?
  @NSManaged var favorite: NSNumber?
  @NSManaged var score: NSNumber?
  
}
