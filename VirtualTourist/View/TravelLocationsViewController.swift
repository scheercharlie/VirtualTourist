//
//  MapViewController.swift
//  VirtualTourist
//
//  Created by Charlie Scheer on 9/28/19.
//  Copyright © 2019 Praxsis. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class TravelLocationsViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!

    
    override func viewWillDisappear(_ animated: Bool) {
        
    }
    
    func getMapCurrentCenterPoint() -> CLLocationCoordinate2D {
        let center = mapView.centerCoordinate
        
        return center
    }
    
    func getMapZoom() -> MKCoordinateSpan {
        let span = mapView.region.span
        
        return span
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        print("Map moved")
        let currentMapLocation = MapLocation.init(coordinate: mapView.centerCoordinate, span: mapView.region.span)
        currentMapLocation.saveMapViewLocationToUserDefaults()
    }

}
