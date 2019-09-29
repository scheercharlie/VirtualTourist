//
//  MapViewLocationAndSpan.swift
//  VirtualTourist
//
//  Created by Charlie Scheer on 9/28/19.
//  Copyright © 2019 Praxsis. All rights reserved.
//

import Foundation
import MapKit

struct MapViewLocationAndSpan: Codable {
    let longitude: Double
    let latitude: Double
    let longitudeDelta: Double
    let latitudeDelta: Double
    
    
    func getLocationCoordinate() -> CLLocationCoordinate2D {
        guard let longitudeCoordinate = CLLocationDegrees(exactly: longitude), let latitudeCoordinate = CLLocationDegrees(exactly: latitude) else{
            print("Couldn't convert location to coordinates")
            return CLLocationCoordinate2D()
        }
        
        let location = CLLocationCoordinate2D(latitude: latitudeCoordinate, longitude: longitudeCoordinate)
        
        
        return location
    }
    
    func getLocationDelta() -> MKCoordinateSpan {
        guard let latitudeDeltaCoordinate = CLLocationDegrees(exactly: latitudeDelta),
            let longitudeDeltaCooridnate = CLLocationDegrees(exactly: longitudeDelta) else {
                print("Couldn't convert span to coordinate delta")
                return MKCoordinateSpan()
        }
        
        let span = MKCoordinateSpan(latitudeDelta: latitudeDeltaCoordinate, longitudeDelta: longitudeDeltaCooridnate)
        
        return span
    }
}
