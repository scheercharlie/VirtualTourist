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
    
    //MARK: Properties
    var flowLayout: UICollectionViewFlowLayout!
    var mapAnnotation: VirtualTouristMapAnnotation!
    var dataController: DataController!
    var vc: PhotoAlbumViewController!
    var fetchResultsController: NSFetchedResultsController<Photo>!
    var collectionView: UICollectionView!
    var activityIndicator: UIActivityIndicatorView!
    
    var objectChanges: [NSFetchedResultsChangeType : [IndexPath]]!
    
    private let spacing: CGFloat = 5
    
    
    //MARK: Initilization
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
    
        objectChanges = [:]
        objectChanges[NSFetchedResultsChangeType.delete] = []
        objectChanges[NSFetchedResultsChangeType.insert] = []
        
    }
    
    //Setup the collection view flow preferences
    func setupFlowLayoutPreferences() {
        flowLayout.sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
        flowLayout.minimumInteritemSpacing = 10
        flowLayout.minimumLineSpacing = 10
        flowLayout.itemSize = CGSize(width: 100, height: 100)
        flowLayout.estimatedItemSize = CGSize(width: 100, height: 100)
    }
    
    
    //MARK: Collection View Data Source Methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if fetchResultsController != nil, let sections = fetchResultsController.sections {
            return sections[section].numberOfObjects
        } else {
            return 10
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //Make collection view cell
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionCell", for: indexPath) as? CollectionViewCell else {
            return UICollectionViewCell()
        }

        //Set background placeholder for Cell
        //Create image view
        //Get photo to set image
        cell.backgroundColor = UIColor.lightGray
        let photo = fetchResultsController.object(at: indexPath)
        
        //Prepare activity indicator and start animating
        vc.startAnimating(true)

        //If the photo does not have data saved
        //Use the Flickr api to fetch data for the image and save it
        //Convert downloaded data to image and display in cell
        if photo.photoData == nil {
            DispatchQueue.global().async {
                FlickrAPIClient.fetchImageDataFor(photo, dataController: self.dataController, completion: {[weak self] (data, error) in
                    if let data = data {
                        self!.setImageForCellFromImageData(data, imageView: cell.imageView, cell: cell)
                        
                    }
                })
            }
            
        //If photo has image data already, convert data to image and display it
        } else {
            setImageForCellFromImageData(photo.photoData!, imageView:
                cell.imageView, cell: cell)
        }
        
        vc.startAnimating(false)
        return cell
    }
    
    fileprivate func setImageForCellFromImageData(_ data: Data, imageView: UIImageView, cell: CollectionViewCell) {
        DispatchQueue.main.async {
            if let image = UIImage(data: data) {
                cell.imageView.image = image
            }
            
            self.vc.startAnimating(false)
        }
    }
    
    fileprivate func startAnimating(_ activityIndicator: UIActivityIndicatorView, _ bool: Bool) {
        if bool {
            activityIndicator.startAnimating()
            vc.reloadButton.isEnabled = false
        } else {
            activityIndicator.stopAnimating()
            vc.reloadButton.isEnabled = true
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let object = fetchResultsController.object(at: indexPath)
        dataController.viewContext.delete(object)
    }
    
    /*CollectionViewCell Spacing code found at https://medium.com/@NickBabo/equally-spaced-uicollectionview-cells-6e60ce8d457b
     Author:Nicholas Babo
     Article: Equally Spaced UICollectionView Cells
     Site: Medium*/
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let numberOfItemsPerRow: CGFloat = 3
        let spacingBetweenItems: CGFloat = 5
        let totalSpacing = (2 * self.spacing) + ((numberOfItemsPerRow - 1) * spacingBetweenItems)
        //TO DO Fix the spacing to automatically size
        let width = (collectionView.bounds.width - totalSpacing) / numberOfItemsPerRow
        return CGSize(width: 100, height: 100)
    }
    

    //MARK: Fetched Results Controller Delegate Methods

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        print(objectChanges)
        if objectChanges != nil {
            
            
            switch type {
            case .insert:
                if let newIndexPath = newIndexPath {
                    objectChanges[NSFetchedResultsChangeType.insert]!.append(newIndexPath)
                    print("insert")
                }
            case .delete:
                if let indexPath = indexPath {
                    print(indexPath)
                    objectChanges[NSFetchedResultsChangeType.delete]!.append(indexPath)
                    }
                    print("delete")
            default:
                break
            }
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if let deletes = objectChanges[NSFetchedResultsChangeType.delete] {
            if deletes.count > 0 {
                collectionView.deleteItems(at: deletes)
                objectChanges[NSFetchedResultsChangeType.delete] = []
            }
        }
        
        if let inserts = objectChanges[NSFetchedResultsChangeType.insert] {
            if inserts.count > 0 {
                collectionView.insertItems(at: inserts)
                objectChanges[NSFetchedResultsChangeType.insert] = []
            }
        }
        
    }
    
    func getCurrentPhotoPage() -> Int? {
        guard let imageArray = fetchResultsController.fetchedObjects else {
            print("couldn't get images from FRC")
            return nil
        }
        
        guard let first = imageArray.first else {
            print("no first object")
            return nil
        }
        
        return Int(first.page)
    }
    
    func removeCurrentImages() {
        guard let imageArray = fetchResultsController.fetchedObjects else {
                return
        }
    
        for image in imageArray {
            print(imageArray.count)
            dataController.viewContext.delete(image)
        }
    }
    
    func fetchNewImages(page: Int) {
        let newPage = page + 1
        FlickrAPIClient.fetchImageURLS(mapAnnotation: mapAnnotation, dataController: dataController, page: newPage) { (success, error) in
            if success {
                print("should have new photo urls")
            } else {
                print("failed")
            }
            print("end of fetch new images")
        }
    }
}
