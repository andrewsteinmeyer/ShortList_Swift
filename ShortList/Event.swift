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
  
  @NSManaged var userId: String?
  @NSManaged var name: String?
  @NSManaged var date: NSDate?
  @NSManaged var list: NamedValues?
  @NSManaged var venue: NamedValues?
  @NSManaged var location: NamedValues?
  @NSManaged var accepted: NSSet?
  @NSManaged var declined: NSSet?
  @NSManaged var timeout: NSSet?
  @NSManaged var eventConfiguration: NamedValues?
  @NSManaged var insertedOn: NSNumber?
}