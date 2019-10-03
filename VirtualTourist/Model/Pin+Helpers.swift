//
//  Pin+Helpers.swift
//  VirtualTourist
//
//  Created by Charlie Scheer on 9/30/19.
//  Copyright © 2019 Praxsis. All rights reserved.
//

import Foundation
import CoreData
import MapKit

extension Pin {
    //May not be required.  Remove if possible
    func getCoordinate() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    //Return an MKPointAnnotation using the saved Longitude/Latitude for a pin
    func getPoint() -> MKPointAnnotation {
        let point = MKPointAnnotation()
        point.coordinate.latitude = latitude
        point.coordinate.longitude = longitude
        
        return point
    }
    
    func returnMapPin() -> MapPin {
        let mapPin = MapPin()
        mapPin.pin = self
        mapPin.coordinate = self.getCoordinate()
        
        return mapPin
    }
    
}
