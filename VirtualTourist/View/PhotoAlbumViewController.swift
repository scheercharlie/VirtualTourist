//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Charlie Scheer on 9/30/19.
//  Copyright © 2019 Praxsis. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class PhotoAlbumViewController: UIViewController {
    //MARK: View Properties
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    //MARK: View life cycle Methods
    override func viewDidLoad() {
        print("gallery view")
    }
    
    
    //TO DO: Make map un selectable/un zoomable/etc
}

