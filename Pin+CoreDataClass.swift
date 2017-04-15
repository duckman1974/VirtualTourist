//
//  Pin+CoreDataClass.swift
//  VirtualTourist
//
//  Created by Kevin Reese on 4/13/17.
//  Copyright © 2017 Kevin Reese. All rights reserved.
//

import Foundation
import CoreData
import MapKit

@objc(Pin)
public class Pin: NSManagedObject, MKAnnotation {
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    public var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude as Double, longitude: longitude as Double)
    }
    
    init(pinLatitude: Double, pinLongitude: Double, context: NSManagedObjectContext) {
        
        let entity = NSEntityDescription.entity(forEntityName: Constants.Pin.pin, in: context)
        
        super.init(entity: entity!, insertInto: context)
        
        latitude = pinLatitude as Double
        longitude = pinLongitude as Double
    
    }
    
    

}
