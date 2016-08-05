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
  @NSManaged var date: NSTimeInterval
  @NSManaged var list: NamedValues?
  @NSManaged var venue: NamedValues?
  @NSManaged var location: NamedValues?
  @NSManaged var acceptedCount: NSNumber?
  @NSManaged var declinedCount: NSNumber?
  @NSManaged var timeoutCount: NSNumber?
  @NSManaged var eventConfiguration: NamedValues?
  @NSManaged var insertedOn: NSTimeInterval
  @NSManaged var contactCount: NSNumber?
  
  //TODO: removed invitationsSent bc it was crashing due to null converting to NSNull.  Is this not always set on an Event object on server?
}