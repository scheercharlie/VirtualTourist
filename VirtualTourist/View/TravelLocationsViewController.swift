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
    
    override func viewWillDisappear(_ animated: Bool) {
        //Functions for when the travel locations view disappears
        //Save new location to UserDefaults
        let currentMapLocation = MapLocation.init(coordinate: mapView.centerCoordinate, span: mapView.region.span)
        currentMapLocation.saveMapViewLocationToUserDefaults()
        print("saved mapview location")
    }
    
    //MARK: Gesture Recognizer Functions
    func setupGestureRecognizer() {
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        gestureRecognizer.minimumPressDuration = 1.0
        gestureRecognizer.delaysTouchesBegan = true
        gestureRecognizer.delegate = self
        
        self.mapView.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc func handleLongPress(gestureRecognizer : UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            let location = gestureRecognizer.location(in: mapView)
            let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
            
            let point = VirtualTouristMapAnnotation()
            point.coordinate = coordinate
            mapView.addAnnotation(point)
            
            createPinFromMapAnnotation(mapAnnotation: point, coordinate: coordinate)
            
        }
    }
    
    //Get the name of a location from a given CLLocation
    func getLocationtitle(from location: CLLocation, completion: @escaping (String?, Error?) -> Void) {
        let geoCoder = CLGeocoder()
        
        geoCoder.reverseGeocodeLocation(location) { (placemarks, error) in
            guard
                let placemarks = placemarks, let locationString = placemarks.first?.locality else {
                    
                    completion(nil, error)
                    
                    return
            }
            
            completion(locationString, nil)
            
        }
    }
    
    //Create a new VirtualTouristMKPointAnnotation from coordinate
    //Save new Pin to viewContext
    //Return new VirtualTouristMapAnnotation
    func createPinFromMapAnnotation(mapAnnotation: VirtualTouristMapAnnotation, coordinate: CLLocationCoordinate2D) {
        //Try to get a name for the a place given a location
        //If successful set the point's title to the location name
        getLocationtitle(from: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)) { (name, error) in
            if let locationName = name {
                mapAnnotation.title = locationName
                
                mapAnnotation.pin = Pin(fromCoordinate: coordinate,
                                        name: mapAnnotation.title ?? mapAnnotation.returnCoordinateAsName(),
                                        managedObjectContext: self.dataController.viewContext)
                
                self.savePinToStorage(mapAnnotation.pin)
                
                
                FlickrAPIClient.fetchImageURLS(mapAnnotation: mapAnnotation, dataController: self.dataController) { (success, error) in
                    if success {
                        print("should have saved data")
                    } else {
                        print("failed")
                    }
                }
            } else {
                print(error?.localizedDescription ?? "Generic Error")
            }
        }
    }
    
    //MARK: Active Functions
    func savePinToStorage(_ pin : Pin) {
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
        let destination = segue.destination as! PhotoAlbumViewController
        destination.mapAnnotation = mapView.selectedAnnotations[0] as? VirtualTouristMapAnnotation
        destination.dataController = dataController
    }
    
}
