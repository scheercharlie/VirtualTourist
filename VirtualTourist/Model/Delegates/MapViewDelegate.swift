//
//  MapViewDelegate.swift
//  VirtualTourist
//
//  Created by Charlie Scheer on 9/30/19.
//  Copyright © 2019 Praxsis. All rights reserved.
//

import Foundation
import MapKit
import CoreData

class MapViewDelegate: NSObject, MKMapViewDelegate, NSFetchedResultsControllerDelegate {
    var viewController: UIViewController!
    var fetchedResultsController: NSFetchedResultsController<Pin>!
    var needsFetch: Bool!
    
    init(viewController: UIViewController, fetchRequest: NSFetchRequest<Pin>?, managedObjectContext: NSManagedObjectContext?) {
        self.viewController = viewController
        
        //Check and see if there is a fetch request and managed object context
        //If there is, setup the fetched results controller
        if let fetchRequest = fetchRequest, let managedObjectContext = managedObjectContext {
            needsFetch = true
            fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        } else {
            //If there isn't set needs fetch to false.
            needsFetch = false
        }
    }
    
    //Handle errors with the map loading
    func mapViewDidFailLoadingMap(_ mapView: MKMapView, withError error: Error) {
        let error = error as NSError

        switch error.code {
        case -1009:
            viewController.presentNoActionAlert(title: "No Interent Connection", message: "Please connect to the internet and try again")
        default:
            viewController.presentNoActionAlert(title: "Loading Map Failed", message: error.localizedDescription)
        }
    }
    
    //Setup the appearance of pins for the map view
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuse = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuse) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuse)
            pinView!.tintColor = UIColor.red
        } else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    //When a pin is selected:
    //Transition to the PhotoAlbumViewController
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        viewController.performSegue(withIdentifier: constants.showPhotoAlbum, sender: self)
    }
    
    //When map finishes loading:
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        //If there is a fetched results controller:
        //Create an array for all of the saved pins and display them
        if needsFetch {
            //Try to fetch pins from storage
            do {
                try fetchedResultsController.performFetch()
            } catch {
                viewController.presentNoActionAlert(title: "Could not fetch Pins", message: "Please try again later")
            }
            
            guard let fetchedPins = fetchedResultsController.fetchedObjects else {
                return
            }
            var annotations: [VirtualTouristMapAnnotation] = []
            
            for pin in fetchedPins {
                annotations.append(pin.returnMapAnnotation())
            }
            
            mapView.addAnnotations(annotations)
        }
        
    }
}

extension MapViewDelegate {
    //Saved constants for MapViewDelegate
    enum constants {
        static let showPhotoAlbum = "showPhotoAlbumView"
    }
}

