//
//  UIViewController+Helpers.swift
//  VirtualTourist
//
//  Created by Charlie Scheer on 9/30/19.
//  Copyright © 2019 Praxsis. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func presentNoActionAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okay = UIAlertAction.init(title: "Okay", style: .default, handler: nil)
        alert.addAction(okay)
        
        present(alert, animated: true, completion: nil)
    }
}
