//
//  FlirckrAPIResponse.swift
//  VirtualTourist
//
//  Created by Charlie Scheer on 10/4/19.
//  Copyright © 2019 Praxsis. All rights reserved.
//

import Foundation


struct FlickrAPIPhotosSearchResonse: Codable {
    let photos: PhotoResponse
    let stat: String
}

struct PhotoResponse: Codable{
    let page: Int
    let pages: Int
    let perpage: Int
    let total: String
    let photoProperties: [JSONPhotoProperty]
    
    enum CodingKeys: String, CodingKey {
        case page
        case pages
        case perpage
        case total
        case photoProperties = "photo"
    }
}

struct JSONPhotoProperty: Codable {
    let id: String
    let owner: String
    let secret: String
    let server: String
    let farm: Int
    let title: String
    let ispublic: Int
    let isfriend: Int
    let isfamily: Int
    let url: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case owner
        case secret
        case server
        case farm
        case title
        case ispublic
        case isfriend
        case isfamily
        case url = "url_o"
    }
}
