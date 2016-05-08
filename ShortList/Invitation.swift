//
//  Invitation.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 4/24/16.
//  Copyright © 2016 Andrew Steinmeyer. All rights reserved.
//

import CoreData

class Invitation: NSManagedObject {
  typealias NamedValues = [String:AnyObject]
  
  @NSManaged var userId: String?
  @NSManaged var eventId: String?
  @NSManaged var listId: String?
  @NSManaged var contact: NamedValues?
  @NSManaged var duration: NSNumber?
  @NSManaged var insertedOn: NSTimeInterval
  @NSManaged var status: String?
  @NSManaged var actionUpdated: NSTimeInterval
}


