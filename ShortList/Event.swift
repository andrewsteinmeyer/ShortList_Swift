//
//  Event.swift
//  Shortlist
//
//  Created by Andrew Steinmeyer on 12/10/15.
//  Copyright © 2015 Andrew Steinmeyer. All rights reserved.
//

import CoreData

class Event: NSManagedObject {
  typealias NamedValues = [String:AnyObject]
  
  @NSManaged var name: String?
  @NSManaged var userId: String?
  @NSManaged var list: NamedValues?
  @NSManaged var venue: NamedValues?
  @NSManaged var location: NamedValues?
  @NSManaged var insertedOn: NSDate?
  
  @NSManaged var eventConfiguration: NamedValues?
  
}