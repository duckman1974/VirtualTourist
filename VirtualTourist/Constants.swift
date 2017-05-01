//
//  Constants.swift
//  VirtualTourist
//
//  Created by Kevin Reese on 4/12/17.
//  Copyright © 2017 Kevin Reese. All rights reserved.
//

import Foundation

struct Constants {
    
    struct PhotoPins {
        
        static var latitude: Double = 0.0
        static var longitude: Double = 0.0
    }
    
    struct Pin {
        static let id = "id"
        static let pin = "Pin"
        static let latitude = "latitude"
        static let longitude = "longitude"
        static let photo = "Photo"
        
    }
    
    // MARK: Flickr
    struct Flickr {
        static let BaseURL = "https://api.flickr.com/services/rest/"
        static let Method = "flickr.photos.search"     //"flickr.photos.getRecent"
        
        static let SearchBBoxHalfWidth = 1.0
        static let SearchBBoxHalfHeight = 1.0
        static let SearchLatRange = (-90.0, 90.0)
        static let SearchLonRange = (-180.0, 180.0)
    }
    
    // MARK: Flickr Parameter Keys
    struct FlickrParameterKeys {
        static let Method = "method"
        static let APIKey = "api_key"
        static let GalleryID = "gallery_id"
        static let Extras = "extras"
        static let Format = "format"
        static let NoJSONCallback = "nojsoncallback"
        static let SafeSearch = "safe_search"
        static let Text = "text"
        static let BoundingBox = "bbox"
        static let Page = "page"
        static let PerPage = "per_page"
    }
    
    // MARK: Flickr Parameter Values
    struct FlickrParameterValues {
        static let SearchMethod = "flickr.photos.search"
        static let APIKey = "42da43103dc740c5835ed55562154a1d"
        static let ResponseFormat = "json"
        static let DisableJSONCallback = "1" /* 1 means "yes" */
        static let GalleryPhotosMethod = "flickr.galleries.search"
        static let GalleryID = "5704-72157622566655097"
        static let MediumURL = "url_m"
        static let UseSafeSearch = "1"
        static let Extras = "geo"
    }
    
    // MARK: Flickr Response Keys
    struct FlickrResponseKeys {
        static let Status = "stat"
        static let Photos = "photos"
        static let Photo = "photo"
        static let Title = "title"
        static let MediumURL = "url_m"
        static let Pages = "pages"
        static let Total = "total"
    }
    
    // MARK: Flickr Response Values
    struct FlickrResponseValues {
        static let OKStatus = "ok"
    }
}
