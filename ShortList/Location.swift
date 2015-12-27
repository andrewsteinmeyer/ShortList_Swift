//
//  Location.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 12/26/15.
//  Copyright © 2015 Andrew Steinmeyer. All rights reserved.
//

import CoreData

class Location: NSManagedObject {
  @NSManaged var name: String?
  @NSManaged var address: String?
  
  @NSManaged var latitude: NSNumber?
  @NSManaged var longitude: NSNumber?
  
}
