//
//  Pin.swift
//  VirtualTourist
//
//  Created by Ada Ji on 12/20/15.
//  Copyright © 2015 Superada. All rights reserved.
//

import UIKit
import CoreData

// MARK: - Pin: NSManagedObject

class Pin: NSManagedObject {
    
    // MARK: Keys
    
    struct Keys {
        static let DateCreated = "dateCreated"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        static let Photos = "photos"
    }
    
    // MARK: Properties
    
    @NSManaged var dateCreated: NSDate
    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    @NSManaged var photos: [Photo]
    
    // MARK: Initializers
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String: AnyObject], context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        dateCreated = dictionary[Keys.DateCreated] as! NSDate
        latitude = dictionary[Keys.Latitude] as! Double
        longitude = dictionary[Keys.Longitude] as! Double
    }

}















