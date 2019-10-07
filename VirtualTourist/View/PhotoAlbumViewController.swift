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
import CoreData

class PhotoAlbumViewController: UIViewController {
    //MARK: View Properties
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    var mapAnnotation: VirtualTouristMapAnnotation?
    var mapViewDelegate: MapViewDelegate!
    var dataController: DataController!
    var collectionViewDelegate: CollectionViewDelegate!
    
    //MARK: View life cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        FlickrAPIClient.fetchPhotos(mapAnnotation: mapAnnotation!, dataController: dataController!) { (success, error) in
            if success {
                print("should have saved data")
            } else {
                print("failed")
            }
        }
        
        
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "objectID", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "pin == %@", mapAnnotation!.pin)

        
        collectionViewDelegate = CollectionViewDelegate(flowLayout: flowLayout, mapAnnotation: mapAnnotation!, fetchRequest: fetchRequest, dataController: dataController)
        collectionViewDelegate.mapAnnotation = mapAnnotation
        
        collectionView.delegate = collectionViewDelegate
        collectionView.dataSource = collectionViewDelegate
        
        
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
}


