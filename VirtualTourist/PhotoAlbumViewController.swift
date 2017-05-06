//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Kevin Reese on 4/11/17.
//  Copyright © 2017 Kevin Reese. All rights reserved.
//

//import Foundation
import MapKit
import UIKit
import CoreData


class PhotoAlbumViewController: UIViewController, MKMapViewDelegate, NSFetchedResultsControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var mapViewPC: MKMapView!
    @IBOutlet weak var photoCollection: UICollectionView!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var newCollection: UIButton!
    @IBOutlet weak var removePhotos: UIButton!
    
    
    var pin: Pin!
    var selectedItems = [NSIndexPath]()
    var deSelectedItems = [NSIndexPath]()
    var annotation: MKAnnotation!
    var region: MKCoordinateRegion!
    var bbox = ""
    var photoArray = [Photo]()
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if Reachability.isConnectedToNetwork() == true {
            print("Internet connection OK from PhotoAlbumViewController")
        } else {
            errorAlert(errorString: "No Network Connection!")
        }
        
        mapViewPC.addAnnotation(annotation)
        mapViewPC.setRegion(region, animated: true)
        self.mapViewPC.camera.altitude = 50000
        fetchedResultsController?.delegate = self
        
        fetchPhotos()
        
        if fetchedResultsController?.fetchedObjects!.count == 0 {
            photosDownload()
        }
        
        
        /*
        if pin.photo.isEmpty {
            print("downloading new photos")
            photosDownload()
            
        } else {
            self.newCollection.isHidden = false
        }
 */
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        mapViewPC.delegate = self
        
        photoCollection.delegate = self
        photoCollection.dataSource = self
        photoCollection.allowsSelection = true
        photoCollection.allowsMultipleSelection = true
        newCollection.isHidden = false
        removePhotos.isHidden = true
        
        
        setupCollectionFlowLayout()
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>? = {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Constants.Pin.photo)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Constants.Pin.id, ascending: true)]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: AppDelegate.stack.context, sectionNameKeyPath: nil, cacheName: nil)
        return fetchedResultsController
    }()
    
    func fetchPhotos(){
        
        if let fc = fetchedResultsController {
            
            do {
                print("retrieving from coredata")
                try fc.performFetch()
                
            } catch {}
        }
        for Photo in (fetchedResultsController?.fetchedObjects)! {
            print(Photo)
        }
    }
    
    
    func photosDownload() {
        
        if Reachability.isConnectedToNetwork() == true {
        
            Networking.sharedInstance().imagesFromFlickr(bbox: bbox) { (success, photoArray, error) in
                
                if error != nil {
                    DispatchQueue.main.async {
                        self.errorAlert(errorString: "Error downloading photos")
                    }
                    
                } else {
                    
                    if let photos = photoArray{
        
                        DispatchQueue.main.async {
                        _ = photos.map() {(dictionary: [String:AnyObject]) -> Photo in
                            let photo = Photo(dictionary: dictionary, context: AppDelegate.stack.context)
                            photo.pin = self.pin
                            //print(photo.pin as AnyObject)
                            AppDelegate.stack.save()
                            return photo
                            }
                        }
                    } else {
                        self.errorAlert(errorString: "An error occurred when fetching photos")
                    }
                }
            }
        } else {
            errorAlert(errorString: "No Network Connection!")
        }
    }
    
    func setAnnotation(annotation: MKAnnotation) {
        self.annotation = annotation
    }
    
    func setRegion(region: MKCoordinateRegion) {
        self.region = region
    }
    
    @IBAction func dismissController(_ sender: Any) {
        let removePhotos = [Photo]()
        
        for photo in removePhotos {
            AppDelegate.stack.context.delete(photo)
        }
        AppDelegate.stack.save()
        
        dismiss(animated: false, completion: nil)
    }
    
    @IBAction func getNewPhotos(_ sender: Any) {
        let oldPhotos = fetchedResultsController?.fetchedObjects as! [Photo]
        
        for photos in oldPhotos {
            AppDelegate.stack.context.delete(photos)
        }
        photosDownload()
        AppDelegate.stack.save()
    }
    
    @IBAction func deletePhotos(_ sender: Any) {
        var removePhotos = [Photo]()
        
        let result = selectedItems.filter({ element in
            return !deSelectedItems.contains(element)
        })
        
        for index in result {
            removePhotos.append(fetchedResultsController?.object(at: index as IndexPath) as! Photo)
        }
        
        for photo in removePhotos {
            AppDelegate.stack.context.delete(photo)
        }
        selectedItems.removeAll()
        AppDelegate.stack.save()

        self.removePhotos.isHidden = true
        self.newCollection.isHidden = false
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pin.photo.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! CollectionViewCell
        configureCell(cell, atIndexPath: indexPath)
        cell.layer.borderWidth = 0.0
        cell.layer.borderColor = UIColor.clear.cgColor
        return cell
    }
    
    func configureCell(_ cell: CollectionViewCell, atIndexPath indexPath: IndexPath) {
        
        var photoImage = UIImage(named: "placeHolder")
        let photo = fetchedResultsController?.object(at: indexPath) as! Photo
        //print(photo.stringURL)
        
        if photo.stringURL == nil || photo.stringURL == "" {
            photoImage = UIImage(named: "placeHolder")
            
        } else if photo.photo != nil {
            photoImage = UIImage(data: photo.photo! as Data)

        } else {
            
            DispatchQueue.main.async {
                cell.statusWheel.hidesWhenStopped = true
                cell.statusWheel.startAnimating()
            }
            
            _ = Networking.sharedInstance().imageData(photo.stringURL!) { (imageData, error) in
                
                if error != nil {
                    photoImage = UIImage(named: "placeHolder")
                    DispatchQueue.main.async {
                        cell.photoImage.image = photoImage
                    }
                }
                if let data = imageData {

                    photoImage = UIImage(data: data as Data)!
                    //AppDelegate.stack.save()
                    
                    DispatchQueue.main.async {
                        cell.statusWheel.stopAnimating()
                        cell.photoImage.image = photoImage
                    }
                    
                    
                    
                    
                    do{
                        try AppDelegate.stack.context.save()
                        
                    }catch{
                        print("couldn't save data")
                    }
                }
            }
        }
        cell.photoImage.image = photoImage
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        removePhotos.isHidden = false
        newCollection.isHidden = true
        
        collectionView.selectItem(at: indexPath, animated: true, scrollPosition: UICollectionViewScrollPosition.centeredVertically)
        
        selectedItems.append(indexPath as NSIndexPath)
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.layer.borderWidth = 2.0
        cell?.layer.borderColor = UIColor.blue.cgColor
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        self.removePhotos.isHidden = true
        self.newCollection.isHidden = false
        collectionView.deselectItem(at: indexPath, animated: true)
        deSelectedItems.append(indexPath as NSIndexPath)
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.layer.borderWidth = 0.0
        cell?.layer.borderColor = UIColor.clear.cgColor
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        photoCollection.reloadData()
    }
  
    
    func setupCollectionFlowLayout() {
        let items: CGFloat = view.frame.size.width > view.frame.size.height ? 5.0 : 3.0
        let space: CGFloat = 3.0
        let dimension = (view.frame.size.width - ((items + 1) * space)) / items
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 8.0 - items
        layout.minimumInteritemSpacing = space
        layout.itemSize = CGSize(width: dimension, height: dimension)
        
        photoCollection.collectionViewLayout = layout
    }}

extension PhotoAlbumViewController {
    
    func errorAlert(errorString: String) {
        let alertController = UIAlertController(title: "ALERT", message: errorString, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
}



