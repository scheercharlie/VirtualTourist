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
    
    convenience init(fromCoordinate coordinate: CLLocationCoordinate2D, name: String) {
        self.init()
        
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
        self.name = name
    }
    
    //May not be required.  Remove if possible
    func getCoordinate() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    func returnMapPin() -> MapPin {
        let mapPin = MapPin()
        mapPin.pin = self
        mapPin.coordinate = self.getCoordinate()
        mapPin.title = self.name
        
        return mapPin
    }
    
}
