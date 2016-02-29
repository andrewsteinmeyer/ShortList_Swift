//
//  Alert+CoreDataProperties.swift
//  
//
//  Created by Andrew Steinmeyer on 2/28/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Alert {

    @NSManaged var insertedOn: String?
    @NSManaged var userId: String?
    @NSManaged var sendToUserId: String?
    @NSManaged var alertType: String?
    @NSManaged var title: String?
    @NSManaged var link: String?
    @NSManaged var targetId: String?
    @NSManaged var read: NSNumber?

}
