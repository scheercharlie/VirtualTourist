//
//  FlirckrAPIResponse.swift
//  VirtualTourist
//
//  Created by Charlie Scheer on 10/4/19.
//  Copyright © 2019 Praxsis. All rights reserved.
//

import Foundation


struct FlickrAPIPhotosSearchResonse: Codable {
    let page: Int
    let pages: Int
    let perpage: Int
    let total: Int
    let photo: [JSONPhoto]
    let stat: String
}

struct JSONPhoto: Codable {
    let id: Int
    let owner: String
    let secret: String
    let server: Int
    let farm: Int
    let title: String
    let ispublic: Int
    let isfriend: Int
    let isfamily: Int
}
