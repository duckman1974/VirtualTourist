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
    @IBOutlet weak var removePinToolBar: UIToolbar!
    @IBOutlet weak var editPinButton: UIBarButtonItem!
    
    
    
    let mapLatitude = "map Lat"
    let mapLongitude = "map Long"
    let mapLatSpan = "map Lat Span"
    let mapLongSpan = "map Long Span"
    
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var latitudeSpan: Double = 0.0
    var longitudeSpan: Double = 0.0
    
    var bboxLatitude: Double = 0.0
    var bboxLongitude: Double = 0.0
    
    var edit = Bool()
    
    override func viewWillAppear(_ animated: Bool) {
        
        if Reachability.isConnectedToNetwork() == true {
            print("Internet connection OK")
        } else {
            DispatchQueue.main.async {
                self.errorAlert(errorString: "No Network Connection!")
            }
        }
        initGesture()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchedResultsController?.delegate = self
        mapView.delegate = self
        edit = false
        setUI()
        normalView()
        setMap()
        fetchPins()
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>? = {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Constants.Pin.pin)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Constants.Pin.latitude, ascending: true)]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: AppDelegate.stack.context, sectionNameKeyPath: nil, cacheName: nil)
        return fetchedResultsController
    }()
    
    func fetchPins() {
        
        if let fc = fetchedResultsController {
            do {
                try fc.performFetch()
            } catch {
                errorAlert(errorString: "Unable to fetch Pins from Core Data")
            }
        }
        for Pin in (fetchedResultsController?.fetchedObjects)! {
            mapView.addAnnotation(Pin as! MKAnnotation)
        }
    }

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
    
    @discardableResult func mapSet() -> MKCoordinateRegion {
        
        let span = MKCoordinateSpanMake(latitudeSpan, longitudeSpan)
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let region = MKCoordinateRegionMake(location, span)
        mapView.setRegion(region, animated: false)
        return region
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
            mapView.addAnnotation(pin as MKAnnotation)
            AppDelegate.stack.save()
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        if edit == true {
            let pin = view.annotation as! Pin
            AppDelegate.stack.context.delete(pin)
            mapView.removeAnnotation(pin)
            AppDelegate.stack.save()
 
        } else {
            
            let selectedPin = view.annotation
            latitude = (selectedPin?.coordinate.latitude)!
            longitude = (selectedPin?.coordinate.longitude)!
            Constants.PhotoPins.latitude = latitude
            Constants.PhotoPins.longitude = longitude
            let controller = storyboard?.instantiateViewController(withIdentifier: "PhotoCollection") as! PhotoAlbumViewController
            
            let pin = view.annotation as! Pin
            controller.pin = pin
            controller.bbox = bboxString()
            controller.setAnnotation(annotation: view.annotation!)
            controller.setRegion(region: mapSet())
            AppDelegate.stack.save()
            present(controller, animated: true, completion: nil)
        }
        mapView.deselectAnnotation(mapView.annotations as? MKAnnotation, animated: true)
    }
    
    @IBAction func editLocationPin(_ sender: Any) {
       
        if edit == false {
            editPin()
        }
    }
    
    func editPin() {
        if edit == false {
            removePinToolBar.isHidden = false
            let editButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(normalView))
            self.navigationItem.rightBarButtonItem = editButton
    
            edit = true
        }
    }
    
    func normalView() {
        if edit == true {
            removePinToolBar.isHidden = true
            let ediButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editPin))
            self.navigationItem.rightBarButtonItem = ediButton
            
            edit = false
        }
    }
}

extension TravelLocationsViewController {
    
    func errorAlert(errorString: String) {
        let alertController = UIAlertController(title: "ALERT", message: errorString, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func setUI() {
        title = "Virtual Tourist"
        editPinButton.title = "Edit"
        removePinToolBar.isHidden = true
        self.mapView.isHidden = false
    }
}

extension TravelLocationsViewController {
    
    func bboxString() -> String {
        
        if latitude == Double(Constants.PhotoPins.latitude), longitude == Double(Constants.PhotoPins.longitude) {
            
            let minLat = max(Constants.PhotoPins.latitude - Constants.Flickr.SearchBBoxHalfHeight, Constants.Flickr.SearchLatRange.0)
            let minLong = max(Constants.PhotoPins.longitude - Constants.Flickr.SearchBBoxHalfWidth, Constants.Flickr.SearchLonRange.0)
            let maxLat = min(Constants.PhotoPins.latitude + Constants.Flickr.SearchBBoxHalfHeight, Constants.Flickr.SearchLatRange.1)
            let maxLong = min(Constants.PhotoPins.longitude + Constants.Flickr.SearchBBoxHalfWidth, Constants.Flickr.SearchLonRange.1)
            
            return "\(minLong),\(minLat),\(maxLong),\(maxLat)"
            
        }else {
            
            return "0,0,0,0"
        }
    }
 
    class func sharedInstance() -> TravelLocationsViewController {
        struct Singleton {
            static var sharedInstance = TravelLocationsViewController()
            
        }
        return Singleton.sharedInstance
    }
}


