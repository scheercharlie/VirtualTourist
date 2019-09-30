//
//  MapViewLocationAndSpan.swift
//  VirtualTourist
//
//  Created by Charlie Scheer on 9/28/19.
//  Copyright © 2019 Praxsis. All rights reserved.
//


//A Struct to save and return the previous map center location and zoom

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
    
    
    //MARK: Calculate and Return functions:
    
    //Return a CLLocationCoordinate 2D using the MapLocation's latitude and longitude
    func getLocationCoordinate() -> CLLocationCoordinate2D {
        guard let longitudeCoordinate = CLLocationDegrees(exactly: longitude), let latitudeCoordinate = CLLocationDegrees(exactly: latitude) else{
            print("Couldn't convert location to coordinates")
            return CLLocationCoordinate2D()
        }
        
        let location = CLLocationCoordinate2D(latitude: latitudeCoordinate, longitude: longitudeCoordinate)
        
        return location
    }
    
    //Return a MKCoordinateSpan using the MapLocation's deltas
    func getLocationDelta() -> MKCoordinateSpan {
        guard let latitudeDeltaCoordinate = CLLocationDegrees(exactly: latitudeDelta),
            let longitudeDeltaCooridnate = CLLocationDegrees(exactly: longitudeDelta) else {
                print("Couldn't convert span to coordinate delta")
                return MKCoordinateSpan()
        }
        
        let span = MKCoordinateSpan(latitudeDelta: latitudeDeltaCoordinate, longitudeDelta: longitudeDeltaCooridnate)
        
        return span
    }
    
    //MARK: Save and Restore functions:
    
    //Encode location and save the data to UserDefaults
    func saveMapViewLocationToUserDefaults() {
        let encoder = PropertyListEncoder()
        
        do {
            let encodedMapLocation = try encoder.encode(self)
            UserDefaults.standard.set(encodedMapLocation, forKey: constants.mapLocation)
        } catch {
            print("Location Encode Failed")
        }
    }
    
    //Fetch stored location from UserDefaults, decode to MapLocation, if successful return MapLocation
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
    //MARK: Stored Constants:
    enum constants {
        static let mapLocation = "MapLocation"
    }
}
