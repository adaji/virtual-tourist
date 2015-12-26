//
//  FlickrConstants.swift
//  VirtualTourist
//
//  Created by Ada Ji on 12/20/15.
//  Copyright © 2015 Superada. All rights reserved.
//

extension Flickr {
    
    struct Constants {
        static let APIKey: String = "98102b22efe1dc79351a6b7e1ed5a058"
        
        static let BaseURL: String = "https://api.flickr.com/services/rest/"
    }
    
    struct Methods {
        static let Search = "flickr.photos.search"
    }
    
    struct ParameterKeys {
        static let Method = "method"
        static let APIKey = "api_key"
        static let BBox = "bbox"
        static let SafeSearch = "safe_search"
        static let Extras = "extras"
        static let Format = "format"
        static let NoJSONCallBack = "nojsoncallback"
        static let PerPage = "per_page"
    }
    
    struct JSONResponseKeys {
        static let Photos = "photos"
        static let Photo = "photo"
        static let Total = "total"
        
        static let Id = "id"
        static let Title = "title"
        static let Url_M = "url_m"
    }
    
}
