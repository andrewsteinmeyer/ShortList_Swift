//
//  List.swift
//  Shortlist
//
//  Created by Andrew Steinmeyer on 12/6/15.
//  Copyright © 2015 Andrew Steinmeyer. All rights reserved.
//

import CoreData

class List: NSManagedObject {
  @NSManaged var name: String?
  @NSManaged var userId: String?
  @NSManaged var security: String?
  @NSManaged var hideMembers: NSNumber?
  @NSManaged var insertedOn: NSTimeInterval
  @NSManaged var updateDate: NSTimeInterval
  
  // TODO: Leave as NSSet or make [[String: AnyObject]]??
  @NSManaged var contacts: NSSet?
  
}
