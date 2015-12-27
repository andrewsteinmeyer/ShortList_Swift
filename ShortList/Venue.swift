//
//  Venue.swift
//  Shortlist
//
//  Created by Andrew Steinmeyer on 12/6/15.
//  Copyright © 2015 Andrew Steinmeyer. All rights reserved.
//

import CoreData

class Venue: NSManagedObject {
  @NSManaged var name: String?
  @NSManaged var insertedOn: NSDate?
  
  @NSManaged var location: NSSet!
  
}