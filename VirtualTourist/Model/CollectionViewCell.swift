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
    var imageView: UIImageView!

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        imageView = UIImageView(frame: self.bounds)
        contentView.addSubview(imageView)
    }
}
