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
    
    init(flowLayout: UICollectionViewFlowLayout) {
        self.flowLayout = flowLayout
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
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionCell", for: indexPath) as? CollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let imageview:UIImageView=UIImageView(frame: cell.bounds)
        imageview.image = UIImage(named: "VirtualTourist_120")
        
        cell.contentView.addSubview(imageview)
        return cell
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
