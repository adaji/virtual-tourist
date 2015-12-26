//
//  Flickr.swift
//  VirtualTourist
//
//  Created by Ada Ji on 12/20/15.
//  Copyright © 2015 Superada. All rights reserved.
//

import Foundation

// MARK: - FlickrClient: NSObject

class Flickr: NSObject {
    
    // MARK: Properties

    var session: NSURLSession
    
    // MARK: Initializers
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    // MARK: Shared Instance
    
    class func sharedInstance() -> Flickr {
        struct Singleton {
            static var sharedInstance = Flickr()
        }
        
        return Singleton.sharedInstance
    }
    
    // MARK: Shared Image Cache
    
    struct Caches {
        static let imageCache = ImageCache()
    }
    
    // MARK: Tasks for GET Methods
    
    func startTaskForGETMethod(request: NSURLRequest, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        let task = session.dataTaskWithRequest(request) { data, response, error in
            guard error == nil else {
                completionHandler(result: nil, error: error)
                print("There was an error with your request: \(error)")
                return
            }
            
            guard let data = data else {
                let userInfo = [NSLocalizedDescriptionKey : "No data received."]
                completionHandler(result: nil, error: NSError(domain: "startTaskForHTTPMethod", code: 1, userInfo: userInfo))
                return
            }
            
            // Subset data if it's Udacity method
            NetworkingDataHandler.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
        }
        
        task.resume()
    }
    
}

// MARK: - FlickrClient (Convenience)

extension Flickr {
    
    func getPhotosBySearch(parameters: [String: AnyObject], completionHandler: (success: Bool, photoDictionaries: [[String: AnyObject]]?, errorString: String?) -> Void) {
        let request = NSURLRequest(URL: NSURL(string: Flickr.Constants.BaseURL + NetworkingDataHandler.escapedParameters(parameters))!)
        startTaskForGETMethod(request) { (result, error) -> Void in
            guard error == nil else {
                print("There was an error processing request. Error: \(error)")
                completionHandler(success: false, photoDictionaries: nil, errorString: "There was an error retrieving data.")
                return
            }
            
            guard let result = result else {
                print("No result returned.")
                completionHandler(success: false, photoDictionaries: nil, errorString: "There was an error retrieving data.")
                return
            }
            
            guard let photosDictionary = result[JSONResponseKeys.Photos] as? NSDictionary else {
                print("Could not find key \(JSONResponseKeys.Photos) in \(result)")
                completionHandler(success: false, photoDictionaries: nil, errorString: "There was an error retrieving data.")
                return
            }
            
            /* GUARD: Is the "total" key in photosDictionary? */
            guard let nPhotos = (photosDictionary[JSONResponseKeys.Total] as? NSString)?.integerValue else {
                print("Cannot find key 'total' in \(photosDictionary)")
                return
            }
            
            if nPhotos > 0 {
                /* GUARD: Is the "photo" key in photosDictionary? */
                guard let photoDictionaries = photosDictionary[JSONResponseKeys.Photo] as? [[String: AnyObject]] else {
                    print("Cannot find key 'photo' in \(photosDictionary)")
                    return
                }

                completionHandler(success: true, photoDictionaries: photoDictionaries, errorString: nil)
            }
            
        }
        
    }
    
}















