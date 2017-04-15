//
//  Photo+CoreDataProperties.swift
//  VirtualTourist
//
//  Created by Kevin Reese on 4/13/17.
//  Copyright © 2017 Kevin Reese. All rights reserved.
//

import Foundation
import CoreData


extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo")
    }

    @NSManaged public var id: String?
    @NSManaged public var photo: NSData?
    @NSManaged public var stringURL: String?
    @NSManaged public var pin: Pin?

}
