//
//  CollectionViewDelegate.swift
//  VirtualTourist
//
//  Created by Charlie Scheer on 10/3/19.
//  Copyright © 2019 Praxsis. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class CollectionViewDelegate: NSObject, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    var flowLayout: UICollectionViewFlowLayout!
    private let spacing: CGFloat = 16.0
    
    var mapAnnotation: VirtualTouristMapAnnotation!
    var array: [UIImage]!
    var urlArray: [String]!
    var vc: UIViewController!
    
    init(flowLayout: UICollectionViewFlowLayout, mapAnnotation: VirtualTouristMapAnnotation, vc: UIViewController) {
        self.flowLayout = flowLayout
        self.mapAnnotation = mapAnnotation
        self.array = []
        self.urlArray = []
        self.vc = vc
        super.init()
        self.getArray()

    }
    
    func getArray() {
        FlickrAPIClient.preformImageLocationSearch(from: mapAnnotation) { (photoSearchResponse, error) in
            if let photoRepsonse = photoSearchResponse {
                
                for photo in photoRepsonse.photos.photo{
                    if let url = URL(string: photo.url) {
                        let image = FlickrAPIClient.getImageFrom(url: url)
                        self.urlArray.append(photo.url)
                        self.array.append(image)
                        print(self.array.count)
                        print(self.urlArray.count)
                    } else {
                        print("not valid url")
                    }
                }
            }
        }
    }
    
    func setupFlowLayoutPreferences() {
        flowLayout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        flowLayout.minimumInteritemSpacing = 10
        flowLayout.minimumLineSpacing = 10
        flowLayout.itemSize = CGSize(width: 50, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionCell", for: indexPath)
        
        
        
        let imageView: UIImageView = UIImageView(frame: cell.bounds)
        imageView.image = UIImage(named: "VirtualTourist_120")

        
        cell.contentView.addSubview(imageView)
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard.init(name: "MapStoryboard", bundle: Bundle.main)
        guard let destination = storyboard.instantiateViewController(identifier: "TempViewController") as? TempViewController else {
            print("nada")
            return
        }

        print(urlArray[indexPath.row])
        print(indexPath.row)
        destination.image?.image = array[indexPath.row]
        destination.urlString? = urlArray[indexPath.row]
//
//
        print("tapped")
        
        vc.navigationController?.pushViewController(destination, animated: true)
    }
    /*CollectionViewCell Spacing code found at https://medium.com/@NickBabo/equally-spaced-uicollectionview-cells-6e60ce8d457b
     Author:Nicholas Babo
     Article: Equally Spaced UICollectionView Cells
     Site: Medium*/
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numberOfItemsPerRow: CGFloat = 3
        let spacingBetweenItems: CGFloat = 16
        
        let totalSpacing = (2 * self.spacing) + ((numberOfItemsPerRow - 1) * spacingBetweenItems)
        
        
        let width = (collectionView.bounds.width - totalSpacing) / numberOfItemsPerRow
        return CGSize(width: width, height: width)
        
        
    }
    
}
