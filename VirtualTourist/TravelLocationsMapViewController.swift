//
//  TravelLocationsMapViewController.swift
//  VirtualTourist
//
//  Created by Ada Ji on 12/19/15.
//  Copyright © 2015 Superada. All rights reserved.
//

import UIKit
import MapKit
import CoreData

// MARK: - TravelLocationsMapViewController: UIViewController

class TravelLocationsMapViewController: UIViewController, NSFetchedResultsControllerDelegate {
    
    // MARK: Properties

    @IBOutlet weak var travelLocationsMapView: MKMapView!
    
    var longPressRecognizer: UILongPressGestureRecognizer? = nil
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        longPressRecognizer = UILongPressGestureRecognizer(target: self, action: "addAnnotation:")
        longPressRecognizer?.minimumPressDuration = 1.0
        
//        let annotation = MKPointAnnotation()
//        annotation.coordinate = CLLocationCoordinate2D(latitude: travelLocationsMapView.userLocation.coordinate.latitude, longitude: travelLocationsMapView.userLocation.coordinate.longitude)
//        travelLocationsMapView.addAnnotation(annotation)
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Unresolved error: \(error)")
        }
        
        fetchedResultsController.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if !fetchedResultsController.fetchedObjects!.isEmpty {
            // Note: map view doesn't update automatically
            updateView()
        }
        
        travelLocationsMapView.addGestureRecognizer(longPressRecognizer!)
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        travelLocationsMapView.removeGestureRecognizer(longPressRecognizer!)
    }
    
    // MARK: Update UI
    
    func updateView() {
        var annotations = [MKPointAnnotation]()
        
        for pin in self.fetchedResultsController.fetchedObjects as! [Pin] {
            let lat = CLLocationDegrees(pin.latitude)
            let lon = CLLocationDegrees(pin.longitude)
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotations.append(annotation)
        }
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.travelLocationsMapView.removeAnnotations(self.travelLocationsMapView.annotations)
            self.travelLocationsMapView.addAnnotations(annotations)
//            MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
        }
    }
    
    func addAnnotation(longPressRecognizer: UILongPressGestureRecognizer) {
        if longPressRecognizer.state != .Began {
            return
        }
        
        let touchPoint = longPressRecognizer.locationInView(travelLocationsMapView)
        let newCoordinate = travelLocationsMapView.convertPoint(touchPoint, toCoordinateFromView: travelLocationsMapView)
        let annotation = MKPointAnnotation()
        annotation.coordinate = newCoordinate
        travelLocationsMapView.addAnnotation(annotation)
        
        let _ = Pin(dictionary: [Pin.Keys.DateCreated: NSDate(), Pin.Keys.Latitude: newCoordinate.latitude, Pin.Keys.Longitude: newCoordinate.longitude], context: sharedContext)
        saveContext()
    }

    // MARK: Core Data Convenience
    
    lazy var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }()
    
    func saveContext() {
        CoreDataStackManager.sharedInstance().saveContext()
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Pin.Keys.DateCreated, ascending: false)]
        return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
    }()
    
}

// MARK: - TravelLocationsMapViewController (FetchedResultsControllerDelegate)

extension TravelLocationsMapViewController {
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        if let annotation = anObject as? MKAnnotation {
            switch type {
            case .Insert:
                travelLocationsMapView.addAnnotation(annotation)
            case .Delete:
                travelLocationsMapView.removeAnnotation(annotation)
            case .Update:
                travelLocationsMapView.removeAnnotation(annotation)
                travelLocationsMapView.addAnnotation(annotation)
            default:
                return
            }
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
    
}

// MARK: - TravelLocationsMapViewController: MKMapViewDelegate

extension TravelLocationsMapViewController: MKMapViewDelegate {
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        let photoAlbumVC = storyboard!.instantiateViewControllerWithIdentifier("PhotoAlbumViewController") as! PhotoAlbumViewController
        
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        let predicate = NSPredicate(format: "\(Pin.Keys.Latitude) = %@ AND \(Pin.Keys.Longitude) = %@", argumentArray: [NSNumber(double: view.annotation!.coordinate.latitude), NSNumber(double: view.annotation!.coordinate.longitude)])
        fetchRequest.predicate = predicate
        do {
            let result = try sharedContext.executeFetchRequest(fetchRequest)
            if let pin = result[0] as? Pin {
                photoAlbumVC.pin = pin
                navigationController?.pushViewController(photoAlbumVC, animated: true)
            }

        } catch {
            print("Unresolved error: \(error)")
        }
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = travelLocationsMapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.tintColor = UIColor.orangeColor()
            pinView!.animatesDrop = true
        } else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
}











