//
//  MapViewLocationAndSpan.swift
//  VirtualTourist
//
//  Created by Charlie Scheer on 9/28/19.
//  Copyright © 2019 Praxsis. All rights reserved.
//

import Foundation
import MapKit

struct MapLocation: Codable {
    let longitude: Double
    let latitude: Double
    let longitudeDelta: Double
    let latitudeDelta: Double
    
    init(coordinate: CLLocationCoordinate2D, span: MKCoordinateSpan) {
        self.longitude = Double(coordinate.longitude)
        self.latitude = Double(coordinate.latitude)
        self.longitudeDelta = Double(span.longitudeDelta)
        self.latitudeDelta = Double(span.latitudeDelta)
        
        print(longitude, latitude, longitudeDelta, latitudeDelta)
    }
    
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
    
    func saveMapViewLocationToUserDefaults() {
        let encoder = PropertyListEncoder()
        
        do {
            let encodedMapLocation = try encoder.encode(self)
            UserDefaults.standard.set(encodedMapLocation, forKey: constants.mapLocation)
            print("encode successful")
            
            if UserDefaults.standard.object(forKey: constants.mapLocation) != nil {
                print("save successful")
            }
        } catch {
            print("Location Encode Failed")
        }
    }
    
    static func getSavedMapLocation() -> MapLocation? {
        let decoder = PropertyListDecoder()
        guard let encodedMapLocation = UserDefaults.standard.data(forKey: constants.mapLocation) else {
            print("couldn't get data")
            return nil
        }
        
        do {
            let decodedMapLocation = try decoder.decode(MapLocation.self, from: encodedMapLocation)
            return decodedMapLocation
        } catch {
            print("couldn't decode location")
            return nil
        }
    }
}

extension MapLocation {
    enum constants {
        static let mapLocation = "MapLocation"
    }
}
