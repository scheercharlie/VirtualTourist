//
//  TempViewController.swift
//  VirtualTourist
//
//  Created by Charlie Scheer on 10/5/19.
//  Copyright © 2019 Praxsis. All rights reserved.
//

import Foundation
import UIKit

class TempViewController: UIViewController {
 
    @IBOutlet weak var image: UIImageView!
    
    var urlString: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(urlString)
        
        if let url = URL(string: "https://live.staticflickr.com/65535/48834192888_683aa5087b_o.jpg") {
            print(url)
            let dataTask = URLSession.shared.dataTask(with: url) { (data, response, error) in
                print("task")
                guard error == nil, let data = data else {
                    print("in guard")
                    return
                }
                
                print("in data task after guard")
                if let downloadedImage = UIImage(data: data) {
                    DispatchQueue.main.async {
                        
                        
                        self.image.image = downloadedImage
                            
                        print("in iflet")
                    }
                }
                
                
            }
            dataTask.resume()
        }
    }
}
