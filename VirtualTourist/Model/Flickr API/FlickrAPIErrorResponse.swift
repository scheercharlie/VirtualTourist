//
//  FlickrAPIErrorResponse.swift
//  VirtualTourist
//
//  Created by Charlie Scheer on 10/4/19.
//  Copyright © 2019 Praxsis. All rights reserved.
//

import Foundation

struct FlickrAPIErrorResponse: Codable {
    let stat: String
    let code: Int
    let error: String
    
    enum CodingKeys: String, CodingKey {
        case stat
        case code
        case error = "message"
    }
}



extension FlickrAPIErrorResponse: LocalizedError {
    var errorDescription: String? {
        return error
    }
}
