//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Charlie Scheer on 9/30/19.
//  Copyright © 2019 Praxsis. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class PhotoAlbumViewController: UIViewController {
    //MARK: View Properties
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var mapPin: MapPin?
    var mapViewDelegate: MapViewDelegate!
    var dataController: DataController!
    
    
    //MARK: View life cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapViewDelegate = MapViewDelegate(viewController: self, fetchRequest: nil, managedObjectContext: nil)
        mapView.delegate = mapViewDelegate
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let pin = mapPin {
            
            mapView.centerCoordinate.longitude = pin.pin.longitude
            print(pin.pin.longitude)
            print(mapView.centerCoordinate.longitude)
            mapView.centerCoordinate.latitude = pin.pin.latitude
            mapView.addAnnotation(pin)
        }
        
        mapView.region.span.latitudeDelta = 10.2
        print(mapView.region.span.longitudeDelta)
        mapView.region.span.longitudeDelta = 4.13
    }
    
    //TO DO: Make map un selectable/un zoomable/etc
}

