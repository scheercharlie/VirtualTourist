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
        
        //Try to get a name for the a place given a location
        //If successful set the point's title to the location name
        let clLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        getLocationtitle(from: clLocation) { (name, error) in
            if let locationName = name {
                point.title = locationName
            } else {
                print(error?.localizedDescription ?? "Generic Error")
            }
        }
        
        mapView.addAnnotation(point)
        
        addPin(point: point, name: point.title ?? "New Pin")
    }
    
    //Get the name of a location from a given CLLocation
    func getLocationtitle(from location: CLLocation, completion: @escaping (String?, Error?) -> Void) {
        let geoCoder = CLGeocoder()
        
        geoCoder.reverseGeocodeLocation(location) { (placemarks, error) in
            guard
                let placemarks = placemarks, let location = placemarks.first?.name else {
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                    return
            }
            DispatchQueue.main.async {
                completion(location, nil)
            }
        }
    }
    
    //MARK: Active Functions
    func addPin(point: MKPointAnnotation, name: String) {
        let pin = Pin(context: dataController.viewContext)
        pin.latitude = point.coordinate.latitude
        pin.longitude = point.coordinate.longitude
        pin.name = name
        
        
        do {
            try dataController.viewContext.save()
            print("Save Successful")
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
