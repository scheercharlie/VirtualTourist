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

class CollectionViewDelegate: NSObject, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, NSFetchedResultsControllerDelegate, ImageTaskDownloadedDelegate {
    
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
    var imageTasks = [Int: ImageTask]()
    
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
        
        if fetchResultsController.fetchedObjects!.count > 0 {
            finishedFetchingImagesInfo(totalImages: fetchResultsController.fetchedObjects!.count)
        } else {
            fetchNewImages(page: 1)
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
        cell.backgroundColor = UIColor.lightGray

        //Get photo to set image
        let image = imageTasks[indexPath.row]?.image
        cell.imageView.image = image

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        imageTasks[indexPath.row]?.resume()
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        imageTasks[indexPath.row]?.pause()
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
        let width = (collectionView.bounds.width - totalSpacing) / numberOfItemsPerRow
        return CGSize(width: 100, height: 100)
    }
    

    //MARK: Fetched Results Controller Delegate Methods

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {

        if objectChanges != nil {
            
            
            switch type {
            case .insert:
                if let newIndexPath = newIndexPath {
                    objectChanges[NSFetchedResultsChangeType.insert]!.append(newIndexPath)
                }
            case .delete:
                if let indexPath = indexPath {
                    print(indexPath)
                    objectChanges[NSFetchedResultsChangeType.delete]!.append(indexPath)
                    }
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
        flickrAPIClient.fetchImageURLS(mapAnnotation: mapAnnotation, dataController: dataController, page: newPage) { (success, error) in
            if success {
                print("should have new photo urls")
                try? self.fetchResultsController.performFetch()
                self.finishedFetchingImagesInfo(totalImages: self.fetchResultsController.fetchedObjects!.count)
            } else {
                print("failed")
            }
            print("end of fetch new images")
        }
    }
    
    
    //MARK: ImageTaskDownloadedDelegate Methods
    
    func imageDownloaded(position: Int) {
        self.collectionView?.reloadItems(at: [IndexPath(row: position, section: 0)])
    }
      
    private func finishedFetchingImagesInfo(totalImages: Int) {
        DispatchQueue.main.async {
            self.setupImageTasks(totalImages: totalImages)
            self.collectionView?.reloadData()
            self.vc.startAnimating(false)
        }
    }
        
    private func setupImageTasks(totalImages: Int) {
        let session = URLSession(configuration: URLSessionConfiguration.default)
        
        for i in 0..<totalImages {
            let indexPath = IndexPath(row: i, section: 0)
            let photo = fetchResultsController.object(at: indexPath)
            if let url = photo.url {
                let imageTask = ImageTask(position: i, url: url, session: session, delegate: self)
                imageTasks[i] = imageTask
            }
        }
    }
}
