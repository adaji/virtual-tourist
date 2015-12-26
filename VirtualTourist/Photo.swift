//
//  Photo.swift
//  VirtualTourist
//
//  Created by Ada Ji on 12/20/15.
//  Copyright © 2015 Superada. All rights reserved.
//

import UIKit
import CoreData

// MARK: - Photo: NSManagedObject

class Photo: NSManagedObject {
    
    // MARK: Keys
    
    struct Keys {
        static let PhotoId = "photoId"
        static let Title = "title"
        static let UrlString = "urlString"
        static let RelatedPin = "relatedPin"
    }

    // MARK: Properties
    
    @NSManaged var photoId: String
    @NSManaged var title: String
    @NSManaged var urlString: String
    @NSManaged var relatedPin: Pin?
    
    // MARK: Initializers
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String: AnyObject], context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        photoId = dictionary[Flickr.JSONResponseKeys.Id] as! String
        title = dictionary[Flickr.JSONResponseKeys.Title] as! String
        urlString = dictionary[Flickr.JSONResponseKeys.Url_M] as! String
    }
    
    var image: UIImage? {
        get {
            return Flickr.Caches.imageCache.imageWithIdentifier(urlString)
        }
        
        set {
            Flickr.Caches.imageCache.storeImage(newValue, withIdentifier: urlString)
        }
    }
    
}











