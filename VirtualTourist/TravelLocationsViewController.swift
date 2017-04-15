//
//  TravelLocationsViewController.swift
//  VirtualTourist
//
//  Created by Kevin Reese on 4/10/17.
//  Copyright © 2017 Kevin Reese. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class TravelLocationsViewController: UIViewController, MKMapViewDelegate, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    
    //Use this below to do the pressGesture of the PIN; implement this as it isn't good to go
    //let dropPin = UILongPressGestureRecognizer(target: self, action: #selector("pin"))
    
    
    let mapLatitude = "map Lat"
    let mapLongitude = "map Long"
    let mapLatSpan = "map Lat Span"
    let mapLongSpan = "map Long Span"
    
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var latitudeSpan: Double = 0.0
    var longitudeSpan: Double = 0.0
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        if Reachability.isConnectedToNetwork() == true {
            print("Internet connection OK")
        } else {
            DispatchQueue.main.async {
                self.errorAlert(errorString: "No Network Connection!")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Virtual Tourist"
        fetchedResultsController?.delegate = self
        mapView.delegate = self
        self.mapView.isHidden = false
        setMap()
        initGesture()
       
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>? = {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Constants.Pin.pin)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Constants.Pin.latitude, ascending: true)]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: AppDelegate.stack.context, sectionNameKeyPath: nil, cacheName: nil)
        return fetchedResultsController
    }()
    
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        UserDefaults.standard.set(mapView.region.span.latitudeDelta, forKey: mapLatSpan)
        UserDefaults.standard.set(mapView.region.span.longitudeDelta, forKey: mapLongSpan)
        UserDefaults.standard.set(mapView.region.center.latitude, forKey: mapLatitude)
        UserDefaults.standard.set(mapView.region.center.longitude, forKey: mapLongitude)
        
        setMap()
        
    }
    
     
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: Constants.Pin.pin)
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: Constants.Pin.pin)
            
        }else {
            pinView?.annotation = annotation
        }
        
        return pinView
        
    }
 
    func setMap() {
        
        latitude = UserDefaults.standard.double(forKey: mapLatitude)
        longitude = UserDefaults.standard.double(forKey: mapLongitude)
        latitudeSpan = UserDefaults.standard.double(forKey: mapLatSpan)
        longitudeSpan = UserDefaults.standard.double(forKey: mapLongSpan)
        
        if !(latitude == 0.0 && longitude == 0.0) {
            
            mapSet()
        
        }

    }
    
    func mapSet()/* -> MKCoordinateRegion*/ {
        
        let span = MKCoordinateSpanMake(latitudeSpan, longitudeSpan)
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let region = MKCoordinateRegionMake(location, span)
        mapView.setRegion(region, animated: false)
        print(region)
       // return mapView.region
        
    }
    
    func initGesture() {
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(dropPin))
        longPress.minimumPressDuration = 1.0
        mapView.addGestureRecognizer(longPress)
        
        
    }
    
    func dropPin(gestureRecognizer: UIGestureRecognizer) {
        
        let mapLocation = gestureRecognizer.location(in: mapView)
        let convertedLocation = mapView.convert(mapLocation, toCoordinateFrom: mapView)
        
        if UIGestureRecognizerState.began == gestureRecognizer.state {
            
            let pin = Pin(pinLatitude: convertedLocation.latitude, pinLongitude: convertedLocation.longitude, context: AppDelegate.stack.context)
            
            print("putting PIN")
           
           // DispatchQueue.main.async {
            //    self.mapView.addAnnotation(pin as MKAnnotation)
                mapView.addAnnotation(pin as MKAnnotation)
            //   }
            
            AppDelegate.stack.save()
            
        }
        
    }
    
    
    @IBAction func editLocationPin(_ sender: Any) {
        
        
        
        
    }
   

    
    
    
    
    

}

extension TravelLocationsViewController {
    
    func errorAlert(errorString: String) {
        let alertController = UIAlertController(title: "ALERT", message: errorString, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
        
    }
    
}

