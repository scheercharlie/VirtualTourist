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
import CoreData

class TravelLocationsViewController: UIViewController, UIGestureRecognizerDelegate {
    //MARK: View Properties
    @IBOutlet weak var mapView: MKMapView!
    
    var dataController: DataController!
    var mapViewDelegate: MapViewDelegate!
    
    //MARK: View Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        //This will likely fail, find out the default value for the unique identifier in nsmanagedobejct
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "objectID", ascending: true)]
        
        mapViewDelegate = MapViewDelegate(viewController: self, fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext)
        mapView.delegate = mapViewDelegate
        
        setupGestureRecognizer()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if let savedMapLocation = MapLocation.getSavedMapLocation() {
            mapView.centerCoordinate = savedMapLocation.getLocationCoordinate()
            mapView.region.span = savedMapLocation.getLocationDelta()
        } else {
            print("No Saved Location")
        }
    }
    
    //MARK: Gesture Recognizer Functions
    func setupGestureRecognizer() {
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        gestureRecognizer.minimumPressDuration = 0.5
        gestureRecognizer.delaysTouchesBegan = true
        gestureRecognizer.delegate = self
        
        self.mapView.addGestureRecognizer(gestureRecognizer)
    }
        
    @objc func handleLongPress(gestureRecognizer : UILongPressGestureRecognizer) {
        print("that was a long press")
        let location = gestureRecognizer.location(in: mapView)
        let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
        
        let point = MKPointAnnotation()
        point.coordinate = coordinate
        point.title = "title"
        
        mapView.addAnnotation(point)
        
        addPin(point: point)
    }
    
    //MARK: Active Functions
    func addPin(point: MKPointAnnotation) {
        let pin = Pin(context: dataController.viewContext)
        pin.latitude = point.coordinate.latitude
        pin.longitude = point.coordinate.longitude
        
        do {
            try dataController.viewContext.save()
            print("Save Success")
        } catch {
            print("could not save pin")
            presentNoActionAlert(title:"Save Failed", message:"Could not save the pin location, try again")
        }
    }
    
    
    //MARK: Navigation Methods
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("segue prepared")
    
    }

}
