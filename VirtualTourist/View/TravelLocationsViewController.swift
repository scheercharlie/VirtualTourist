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

class TravelLocationsViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var dataController: DataController!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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

}

extension TravelLocationsViewController: MKMapViewDelegate {
    
    func mapViewDidFailLoadingMap(_ mapView: MKMapView, withError error: Error) {
        let error = error as NSError

        switch error.code {
        case -1009:
            presentNoActionAlert(title: "No Interent Connection", message: "Please connect to the internet and try again")
        default:
            presentNoActionAlert(title: "Loading Map Failed", message: error.localizedDescription)
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
        performSegue(withIdentifier: constants.showPhotoAlbum, sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("segue prepared")
    }

}


extension TravelLocationsViewController {
    enum constants {
        static let showPhotoAlbum = "showPhotoAlbumView"
    }
}
