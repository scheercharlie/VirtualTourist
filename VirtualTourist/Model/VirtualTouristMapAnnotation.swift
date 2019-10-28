//
//  VirtualTouristMapAnnotation.swift
//  VirtualTourist
//
//  Created by Charlie Scheer on 10/2/19.
//  Copyright © 2019 Praxsis. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class VirtualTouristMapAnnotation: MKPointAnnotation {
    var pin: Pin!
    
    func returnCoordinateAsName() -> String {
        let roundedLatitudeString = String(self.coordinate.latitude.rounded())
        let roundedLongitudeString = String(self.coordinate.longitude.rounded())
        let string = roundedLatitudeString + " + " + roundedLongitudeString
        return string
    }
}
