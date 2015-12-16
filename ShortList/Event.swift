//
//  Event.swift
//  Shortlist
//
//  Created by Andrew Steinmeyer on 12/10/15.
//  Copyright © 2015 Andrew Steinmeyer. All rights reserved.
//

import CoreData

class Event: NSManagedObject {
  @NSManaged var name: String?
  @NSManaged var userId: String?
  @NSManaged var list: String?
  @NSManaged var venue: String?
  @NSManaged var location: String?
  @NSManaged var insertedOn: NSDate?
}