
//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Ada Ji on 12/19/15.
//  Copyright © 2015 Superada. All rights reserved.
//

import UIKit
import MapKit
import CoreData

// MARK: - Globals

let EXTRAS = "url_m"
let SAFE_SEARCH = "1"
let DATA_FORMAT = "json"
let NO_JSON_CALLBACK = "1"
let PHOTOS_PER_PAGE = "12"
let BOUNDING_BOX_HALF_WIDTH = 1.0
let BOUNDING_BOX_HALF_HEIGHT = 1.0
let LAT_MIN = -90.0
let LAT_MAX = 90.0
let LON_MIN = -180.0
let LON_MAX = 180.0

private let PhotoCollectionViewCellReuseId = "PhotoCollectionViewCell"

// MARK: - PhotoAlbumViewController: UIViewController

class PhotoAlbumViewController: UIViewController, NSFetchedResultsControllerDelegate {
    
    // MARK: Properties
    
    var pin: Pin!
    
    @IBOutlet weak var travelLocationMapView: MKMapView!
    @IBOutlet weak var photosCollectionView: UICollectionView!
    @IBOutlet weak var newCollectionButton: UIButton!
    var coordinate: CLLocationCoordinate2D!
    
    var selectedIndexPaths = [NSIndexPath]()
    var insertedIndexPaths: [NSIndexPath]!
    var deletedIndexPaths: [NSIndexPath]!
    var updatedIndexPaths: [NSIndexPath]!
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        travelLocationMapView.addAnnotation(annotation)
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Unresolved error: \(error)")
            abort()
        }
        
        fetchedResultsController.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        zoomInToCurrentTravelLocation()

        if pin.photos.isEmpty {
            fetchAndDisplayPhotos()
        } else {
            photosCollectionView.reloadData()
        }
    }
    
    // MARK: Update UI
    
    func zoomInToCurrentTravelLocation() {
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: coordinate!, span: span)
        travelLocationMapView.setRegion(region, animated: true)
    }
    
    // MARK: Manipulate Data
    
    func fetchAndDisplayPhotos() {
        let parameters = [
            Flickr.ParameterKeys.Method: Flickr.Methods.Search,
            Flickr.ParameterKeys.APIKey: Flickr.Constants.APIKey,
            Flickr.ParameterKeys.BBox: boundingBoxString(),
            Flickr.ParameterKeys.SafeSearch: SAFE_SEARCH,
            Flickr.ParameterKeys.Extras: EXTRAS,
            Flickr.ParameterKeys.Format: DATA_FORMAT,
            Flickr.ParameterKeys.NoJSONCallBack: NO_JSON_CALLBACK,
            Flickr.ParameterKeys.PerPage: PHOTOS_PER_PAGE
        ]
        Flickr.sharedInstance().getPhotosBySearch(parameters) { (success, photoDictionaries, errorString) -> Void in
            if success {
                print("# of photos returned: \(photoDictionaries!.count)")
                // Create an array of Photo instances from the dictionaries asynchronously
                self.sharedContext.performBlock {
                    _ = photoDictionaries!.map() {
                        let photo = Photo(dictionary: $0, context: self.sharedContext)
                        photo.relatedPin = self.pin
                    }
                    
                    // Update view on the main thread
                    dispatch_async(dispatch_get_main_queue()) {
                        self.photosCollectionView.reloadData()
                    }
                    
                    self.saveContext()
                }
            } else {
                
            }
        }
    }
    
    // MARK: Helpers
    
    func boundingBoxString() -> String {
        
        let latitude = coordinate.latitude
        let longitude = coordinate.longitude
        
        /* Fix added to ensure box is bounded by minimum and maximums */
        let bottom_left_lon = max(longitude - BOUNDING_BOX_HALF_WIDTH, LON_MIN)
        let bottom_left_lat = max(latitude - BOUNDING_BOX_HALF_HEIGHT, LAT_MIN)
        let top_right_lon = min(longitude + BOUNDING_BOX_HALF_HEIGHT, LON_MAX)
        let top_right_lat = min(latitude + BOUNDING_BOX_HALF_HEIGHT, LAT_MAX)
        
        return "\(bottom_left_lon),\(bottom_left_lat),\(top_right_lon),\(top_right_lat)"
    }
    
    // MARK: Core Data Convenience
    
    lazy var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }()
    
    func saveContext() {
        CoreDataStackManager.sharedInstance().saveContext()
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Photo.Keys.PhotoId, ascending: false)]
        return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
    }()
    
}

// MARK: - PhotoAlbumViewController (NSFetchedResultsControllerDelegate)

extension PhotoAlbumViewController {
    
    // Whenever changes are made to Core Data the following three methods are invoked. This first method is used to create
    // three fresh arrays to record the index paths that will be changed.
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        // We are about to handle some new changes. Start out with empty arrays for each change type
        insertedIndexPaths = [NSIndexPath]()
        deletedIndexPaths = [NSIndexPath]()
        updatedIndexPaths = [NSIndexPath]()
        
        print("in controllerWillChangeContent")
    }
    
    // The second method may be called multiple times, once for each Meme object that is added, deleted, or changed.
    // We store the index paths into the three arrays.
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            print("Insert an item")
            // Here we are noting that a new Meme instance has been added to Core Data. We remember its index path
            // so that we can add a cell in "controllerDidChangeContent". Note that the "newIndexPath" parameter has
            // the index path that we want in this case
            insertedIndexPaths.append(newIndexPath!)
            break
        case .Delete:
            print("Delete an item")
            // Here we are noting that a Meme instance has been deleted from Core Data. We keep remember its index path
            // so that we can remove the corresponding cell in "controllerDidChangeContent". The "indexPath" parameter has
            // value that we want in this case.
            deletedIndexPaths.append(indexPath!)
            break
        case .Update:
            print("Update an item.")
            // Core Data would notify us of changes if Meme instance is updated.
            updatedIndexPaths.append(indexPath!)
            break
        case .Move:
            print("Move an item. We don't expect to see this in this app.")
            break
        }
    }
    
    // This method is invoked after all of the changed in the current batch have been collected
    // into the three index path arrays (insert, delete, and upate). We now need to loop through the
    // arrays and perform the changes.
    //
    // The most interesting thing about the method is the collection view's "performBatchUpdates" method.
    // Notice that all of the changes are performed inside a closure that is handed to the collection view.
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        print("in controllerDidChangeContent. changes.count: \(insertedIndexPaths.count + deletedIndexPaths.count)")
        
        photosCollectionView.performBatchUpdates({
            var selectedSections = Set<Int>()
            for indexPath in self.insertedIndexPaths {
                self.photosCollectionView.insertItemsAtIndexPaths([indexPath])
                selectedSections.insert(indexPath.section)
            }
            
            for indexPath in self.deletedIndexPaths {
                self.photosCollectionView.deleteItemsAtIndexPaths([indexPath])
                selectedSections.insert(indexPath.section)
            }
            
            for indexPath in self.updatedIndexPaths {
                self.photosCollectionView.reloadItemsAtIndexPaths([indexPath])
                selectedSections.insert(indexPath.section)
            }
            
            }, completion: nil)
    }
    
}

// MARK: - PhotoAlbumViewController: UICollectionViewDataSource, UICollectionViewDelegate

extension PhotoAlbumViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let nPhotos = (fetchedResultsController.sections![section]).numberOfObjects
        print("# of photos: \(nPhotos)")
        return nPhotos
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(PhotoCollectionViewCellReuseId, forIndexPath: indexPath) as! PhotoCollectionViewCell
        cell.photoImageView.backgroundColor = UIColor.orangeColor()
        cell.shadowView.backgroundColor = UIColor.clearColor()
        cell.shadowView.alpha = 0.5
        cell.activityIndicator.hidden = true
        cell.titleLabel.textColor = UIColor.whiteColor()

        let photo = fetchedResultsController.objectAtIndexPath(indexPath) as! Photo

        configureCell(cell, withPhoto: photo)
        
        return cell
    }
    
    func configureCell(cell: PhotoCollectionViewCell, withPhoto photo: Photo) {
        print("photo id: \(photo.photoId)")
        
        cell.photoImageView.image = UIImage(named: "imagePlaceholder")
        
        if photo.image != nil {
            cell.photoImageView.image = photo.image!
            cell.titleLabel.text = photo.title
        }
        else {
            cell.activityIndicator.hidden = false
            cell.activityIndicator.startAnimating()
            
            print("\(NSDate()): start downloading image")
            dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.rawValue), 0)) {
                if let imageData = NSData(contentsOfURL: NSURL(string: photo.urlString)!) {
                    let image = UIImage(data: imageData)
                    print("\(NSDate()): finish downloading image")
                    // Update the model, so that the image gets cached
                    photo.image = image
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        cell.activityIndicator.stopAnimating()
                        cell.activityIndicator.hidden = true
                        cell.photoImageView.image = image
                        cell.titleLabel.text = photo.title
                    }
                }
            }
        }
    }
    
}










