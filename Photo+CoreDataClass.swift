//
//  Photo+CoreDataClass.swift
//  VirtualTourist
//
//  Created by Kevin Reese on 4/13/17.
//  Copyright © 2017 Kevin Reese. All rights reserved.
//

import Foundation
import CoreData

@objc(Photo)
public class Photo: NSManagedObject {
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    init(dictionary: [String:AnyObject], context: NSManagedObjectContext) {
        
       //Core data
        let entity = NSEntityDescription.entity(forEntityName: Constants.Pin.photo, in: context)
        super.init(entity: entity!, insertInto: context)
        
        //Dictionary
        stringURL = dictionary[Constants.FlickrParameterValues.MediumURL] as? String
        id = dictionary[Constants.FlickrParameterValues.GalleryID] as? String
        
        
    }
    
    //May need to do more stuff in here
    
    
    
    
}
