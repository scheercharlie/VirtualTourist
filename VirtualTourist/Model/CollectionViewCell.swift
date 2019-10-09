//
//  CollectionViewCell.swift
//  VirtualTourist
//
//  Created by Charlie Scheer on 10/3/19.
//  Copyright © 2019 Praxsis. All rights reserved.
//

import Foundation
import UIKit

class CollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func prepareForReuse() {
        print("reuse")
        super.prepareForReuse()
        self.bounds = CGRect(x: 0, y: 0, width: 50, height: 50)
        self.imageView.image = nil
        backgroundColor = UIColor.lightGray
        
        
    }
}
