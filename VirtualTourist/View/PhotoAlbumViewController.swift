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
    
    var mapAnnotation: VirtualTouristMapAnnotation?
    var mapViewDelegate: MapViewDelegate!
    var dataController: DataController!
    
    
    //MARK: View life cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMapView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let mapAnnotation = mapAnnotation {
            self.title = mapAnnotation.pin.name
        }
    }
    
    fileprivate func setupMapView() {
        mapViewDelegate = MapViewDelegate(viewController: self, fetchRequest: nil, managedObjectContext: nil)
        mapView.delegate = mapViewDelegate
        if let pin = mapAnnotation {
            let span = MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
            let region = MKCoordinateRegion(center: pin.pin.getCoordinate(), span: span)
            mapView.setRegion(region, animated: false)
            mapView.addAnnotation(pin)
            
            mapView.isUserInteractionEnabled = false
            
        }
    }
    
    //TO DO: Make map un selectable/un zoomable/etc
}

