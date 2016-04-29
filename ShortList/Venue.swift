//
//  Venue.swift
//  Shortlist
//
//  Created by Andrew Steinmeyer on 12/6/15.
//  Copyright © 2015 Andrew Steinmeyer. All rights reserved.
//

import CoreData

class Venue: NSManagedObject {
  typealias NamedValues = [String:AnyObject]
  
  @NSManaged var name: String?
  @NSManaged var userId: String?
  @NSManaged var insertedOn: NSTimeInterval
  
  @NSManaged var location: NamedValues?
  
}