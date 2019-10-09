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
    var vc: PhotoAlbumViewController!
    var fetchResultsController: NSFetchedResultsController<Photo>!
    var collectionView: UICollectionView!
    
    init(flowLayout: UICollectionViewFlowLayout, mapAnnotation: VirtualTouristMapAnnotation, fetchRequest: NSFetchRequest<Photo>, dataController: DataController, viewController: PhotoAlbumViewController, collectionView: UICollectionView) {
        self.flowLayout = flowLayout
        self.mapAnnotation = mapAnnotation
        self.dataController = dataController
        self.vc = viewController
        self.collectionView = collectionView
        
        self.fetchResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "photos")
        
        super.init()
        
        self.fetchResultsController.delegate = self
        
        do {
            try fetchResultsController.performFetch()
        } catch {
            print("could not fetch")
        }
    }
    
    func setupFlowLayoutPreferences() {
        flowLayout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        flowLayout.minimumInteritemSpacing = 10
        flowLayout.minimumLineSpacing = 10
        flowLayout.itemSize = CGSize(width: 50, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if fetchResultsController != nil, let sections = fetchResultsController.sections {
            print(sections[section].numberOfObjects)
            return sections[section].numberOfObjects
        } else {
            return 10
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionCell", for: indexPath) as? CollectionViewCell else {
            return UICollectionViewCell()
        }

        cell.backgroundColor = UIColor.lightGray
        let imageView = UIImageView(frame: cell.bounds)
        let activityIndicator = UIActivityIndicatorView(frame: collectionView.bounds)
        activityIndicator.hidesWhenStopped = true
        collectionView.addSubview(activityIndicator)
        
        
        startAnimating(activityIndicator, true)
        
        let photo = fetchResultsController.object(at: indexPath)
        if photo.photoData == nil {
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: photo.url!) {
                    DispatchQueue.main.async {
                        try? self.dataController.backgroundContext.save()

                        imageView.image = UIImage(data: data)
                        cell.contentView.addSubview(imageView)
                        
                        self.startAnimating(activityIndicator, false)
                        
                    }
                }
            }
        } else {
            if let data = photo.photoData {
                DispatchQueue.main.async {
                    activityIndicator.startAnimating()
//                    self.vc.reloadButton.isEnabled = false
//                    self.setIsLoadingTo(true)
                    imageView.image = UIImage(data: data)
                    cell.contentView.addSubview(imageView)
                }
            }
        }
        
        return cell
    }
    
    func startAnimating(_ activityIndicator: UIActivityIndicatorView, _ bool: Bool) {
        if bool {
            activityIndicator.startAnimating()
            vc.reloadButton.isEnabled = false
        } else {
            activityIndicator.stopAnimating()
            vc.reloadButton.isEnabled = true
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("tapped")
        let object = fetchResultsController.object(at: indexPath)
        dataController.viewContext.delete(object)
        
        do {
            try dataController.viewContext.save()
        } catch {
            print(error)
        }
    }
//    
//    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        
//    }
//
//    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        
//    }
//    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            collectionView.insertItems(at: [newIndexPath!])
        case .delete:
            collectionView.deleteItems(at: [indexPath!])
        default:
            break
        }
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
