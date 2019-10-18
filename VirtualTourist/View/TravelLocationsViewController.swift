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
        
        //If there are changes to the context, save to core data
        if dataController.viewContext.hasChanges {
            DispatchQueue.global().async {
                do {
                    try self.dataController.viewContext.save()
                } catch {
                    print("Could not save new Photo")
                }
                
                do {
                    try self.dataController.backgroundContext.save()
                } catch {
                    print("Could not save new Photo")
                }
            }
        }
    }
    
    //MARK: Gesture Recognizer Functions
    func setupGestureRecognizer() {
        //Create and add long press gesture recognizer
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        gestureRecognizer.minimumPressDuration = 1.0
        gestureRecognizer.delaysTouchesBegan = true
        gestureRecognizer.delegate = self
        
        self.mapView.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc func handleLongPress(gestureRecognizer : UILongPressGestureRecognizer) {
        //Only trigger the long press if the gesture recognizer is in state Begin
        if gestureRecognizer.state == .began {
            //Get location from the mapView and convert it to a 2d Coordinate
            let location = gestureRecognizer.location(in: mapView)
            let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
            
            //Create a new pin and set it's coordinate
            //Add the pin to the mapview
            let point = VirtualTouristMapAnnotation()
            point.coordinate = coordinate
            mapView.addAnnotation(point)
            
            //Create a managed object Pin
            createPinFromMapAnnotation(mapAnnotation: point, coordinate: coordinate, page: 1)
            
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
    func createPinFromMapAnnotation(mapAnnotation: VirtualTouristMapAnnotation, coordinate: CLLocationCoordinate2D, page: Int) {
        //Try to get a name for the a place given a location
        //If successful set the point's title to the location name
        getLocationtitle(from: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)) { [weak self] (name, error) in
            if let locationName = name {
                mapAnnotation.title = locationName
                
                mapAnnotation.pin = Pin(fromCoordinate: coordinate,
                                        name: mapAnnotation.title ?? mapAnnotation.returnCoordinateAsName(),
                                        managedObjectContext: self!.dataController.viewContext)
                
                //Fetch and save Image URLS for the newly created Pin
                flickrAPIClient.fetchImageURLS(mapAnnotation: mapAnnotation, dataController: self!.dataController, page: page) { (success, error) in
                    if success {
                        print("should have saved urls")
                    } else {
                        print("failed")
                    }
                }
            } else {
                print(error?.localizedDescription ?? "Generic Error")
            }
        }
    }
    
    //MARK: Navigation Methods
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //Pass data controller into Photo Album View Controller and present VC
        let destination = segue.destination as! PhotoAlbumViewController
        destination.mapAnnotation = mapView.selectedAnnotations[0] as? VirtualTouristMapAnnotation
        destination.dataController = dataController
    }
    
}
