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
    
    init(viewController: UIViewController, fetchRequest: NSFetchRequest<Pin>?, managedObjectContext: NSManagedObjectContext?) {
        self.viewController = viewController
        
        if let fetchRequest = fetchRequest, let managedObjectContext = managedObjectContext {
            fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
            
            //TO DO: Do a better job of handling the fetch errors
            do {
                try fetchedResultsController.performFetch()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    func mapViewDidFailLoadingMap(_ mapView: MKMapView, withError error: Error) {
        let error = error as NSError

        switch error.code {
        case -1009:
            viewController.presentNoActionAlert(title: "No Interent Connection", message: "Please connect to the internet and try again")
        default:
            viewController.presentNoActionAlert(title: "Loading Map Failed", message: error.localizedDescription)
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let currentMapLocation = MapLocation.init(coordinate: mapView.centerCoordinate, span: mapView.region.span)
        currentMapLocation.saveMapViewLocationToUserDefaults()
    }
    
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
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("pin selected")
        viewController.performSegue(withIdentifier: constants.showPhotoAlbum, sender: self)
    }
    
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        guard let fetchedPins = fetchedResultsController.fetchedObjects else {
            print("no results controller")
            return
        }
        var annotations: [MKPointAnnotation] = []
        
        for pin in fetchedPins {
            annotations.append(pin.getPoint())
        }
        
        mapView.addAnnotations(annotations)
    }
}

extension MapViewDelegate {
    enum constants {
        static let showPhotoAlbum = "showPhotoAlbumView"
    }
}

