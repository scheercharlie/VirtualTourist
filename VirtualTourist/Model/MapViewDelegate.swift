//
//  MapViewDelegate.swift
//  VirtualTourist
//
//  Created by Charlie Scheer on 9/30/19.
//  Copyright © 2019 Praxsis. All rights reserved.
//

import Foundation
import MapKit

class MapViewDelegate: NSObject, MKMapViewDelegate {
    var viewController: UIViewController!
    
    init(viewController: UIViewController) {
        self.viewController = viewController
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
}

extension MapViewDelegate {
    enum constants {
        static let showPhotoAlbum = "showPhotoAlbumView"
    }
}

