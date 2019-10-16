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
    @IBOutlet weak var reloadButton: UIButton!
    
    var mapAnnotation: VirtualTouristMapAnnotation?
    var mapViewDelegate: MapViewDelegate!
    var dataController: DataController!
    var collectionViewDelegate: CollectionViewDelegate!
    var activityIndicator: UIActivityIndicatorView!
    var overlay: UIView!
    
    //MARK: View life cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Create fetch request
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "objectID", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "pin == %@", mapAnnotation!.pin)
        
        //Setup collection view
        setupCollectionView(fetchRequest)
        
        //Setup map view
        setupMapView()
        
        setupActivityView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //Present the location title as the view title
        //TO DO I don't think this works....
        super.viewDidAppear(animated)
        if let mapAnnotation = mapAnnotation {
            self.title = mapAnnotation.pin.name
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        //Save changes to background context
        do {
            try dataController.backgroundContext.save()
        } catch {
            print("Could not save")
        }

    }
    
    fileprivate func setupCollectionView(_ fetchRequest: NSFetchRequest<Photo>) {
        //Create collection view delegate
        collectionViewDelegate = CollectionViewDelegate(flowLayout: flowLayout, mapAnnotation: mapAnnotation!, fetchRequest: fetchRequest, dataController: dataController, viewController: self, collectionView: collectionView)
        collectionViewDelegate.mapAnnotation = mapAnnotation
        
        collectionView.delegate = collectionViewDelegate
        collectionView.dataSource = collectionViewDelegate
        collectionView.collectionViewLayout = flowLayout
    }
    
    
    fileprivate func setupMapView() {
        //Setup map view using mapAnnotation
        //Set may as not interaction enabled
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
    
    fileprivate func setupActivityView() {
        activityIndicator = UIActivityIndicatorView()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.center = view.center
        activityIndicator.color = .white
        overlay = UIView()
        overlay.bounds = view.bounds
        overlay.center = view.center
        overlay.backgroundColor = UIColor(white: 0.1, alpha: 0.5)
        self.view.addSubview(overlay)
        self.view.addSubview(activityIndicator)
        collectionView.isUserInteractionEnabled = false
    }
    
    func startAnimating(_ bool: Bool) {
        if bool {
            activityIndicator.startAnimating()
            overlay.isHidden = false
            reloadButton.isEnabled = false
            collectionView.isUserInteractionEnabled = false
        } else {
            activityIndicator.stopAnimating()
            reloadButton.isEnabled = true
            overlay.isHidden = true
            collectionView.isUserInteractionEnabled = true
            
        }
    }
    
    //MARK: Active Functions
    //Deleted the visible ceels
    @IBAction func reloadWasTapped(_ sender: Any) {
        print("reload was tapped")
        
        collectionView.performBatchUpdates({
            
            self.collectionViewDelegate.removeCurrentImages()
        
            
        }, completion: nil )
    }
    
    
}


