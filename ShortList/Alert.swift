//
//  Alert.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 2/28/16
//  Copyright © 2015 Andrew Steinmeyer. All rights reserved.
//

import Foundation
import CoreData

class Alert: NSManagedObject {

    @NSManaged var insertedOn: NSTimeInterval
    @NSManaged var userId: String?
    @NSManaged var sendToUserId: String?
    @NSManaged var alertType: String?
    @NSManaged var title: String?
    @NSManaged var link: String?
    @NSManaged var targetId: String?
    @NSManaged var read: NSNumber?

}
