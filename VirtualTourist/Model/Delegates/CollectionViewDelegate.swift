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

class CollectionViewDelegate: NSObject, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, NSFetchedResultsControllerDelegate {
    var flowLayout: UICollectionViewFlowLayout!
    private let spacing: CGFloat = 16.0
    
    var mapAnnotation: VirtualTouristMapAnnotation!
    var dataController: DataController!
    
    var fetchResultsController: NSFetchedResultsController<Photo>!
    
    init(flowLayout: UICollectionViewFlowLayout, mapAnnotation: VirtualTouristMapAnnotation, fetchRequest: NSFetchRequest<Photo>, dataController: DataController) {
        self.flowLayout = flowLayout
        self.mapAnnotation = mapAnnotation
        self.dataController = dataController
        
        self.fetchResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "photos")
        
        super.init()
        
        self.fetchResultsController.delegate = self
        
        do {
            try fetchResultsController.performFetch()
        } catch {
            print("could not fetch")
        }
        print(fetchResultsController.fetchedObjects?.count)
        print("in collection view init")
        
    }
    
    func setupFlowLayoutPreferences() {
        flowLayout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        flowLayout.minimumInteritemSpacing = 10
        flowLayout.minimumLineSpacing = 10
        flowLayout.itemSize = CGSize(width: 50, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if fetchResultsController != nil, let sections = fetchResultsController.sections {
            if sections[section].numberOfObjects > 30 {
                print("return 30")
                return 30
            } else {
                print("return count")
                print(sections[section].numberOfObjects)
                return sections[section].numberOfObjects
            }
        } else {
            print("return 10")
            return 10
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionCell", for: indexPath)

        cell.backgroundColor = UIColor.lightGray
        let imageView = UIImageView(frame: cell.bounds)
        
        let photo = fetchResultsController.object(at: indexPath)
        if photo.photoData == nil {
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: photo.url!) {
                    DispatchQueue.main.async {
                        photo.photoData = data
                        try? self.dataController.backgroundContext.save()
                        
                        imageView.image = UIImage(data: data)
                        cell.contentView.addSubview(imageView)
                    }
                }
            }
        } else {
            if let data = photo.photoData {
                DispatchQueue.main.async {
                    imageView.image = UIImage(data: data)
                    cell.contentView.addSubview(imageView)
                }
            }
        }
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("tapped")
        
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
