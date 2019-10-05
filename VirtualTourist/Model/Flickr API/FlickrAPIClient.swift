//
//  FlickrAPIClient.swift
//  VirtualTourist
//
//  Created by Charlie Scheer on 10/4/19.
//  Copyright © 2019 Praxsis. All rights reserved.
//

import Foundation

class FlickrAPIClient {
    static let apiKey = "8b463f94bbb5f9d350f7092dcd3753f6"
    
    enum endPoints {
        
        static let apiSecret = "42cfa013bdbf06c4"
        static let baseURL = "https://www.flickr.com/services/rest/?method=flickr.photos.search"
        static let api_key_param = "&api_key=\(FlickrAPIClient.apiKey)"
        
        case getPhotos(Double, Double)
        
        var stringValue: String {
            switch self {
            case .getPhotos(let lat, let lon): return endPoints.baseURL + endPoints.api_key_param + "&accuracy=11" + "&lat=" + String(lat) + "&lon=" + String(lon) + "&format=json&nojsoncallback=1"
                
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    private class func taskForGetRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard error == nil, let data = data else {
                return
            }
            
            
            let decoder = JSONDecoder()
            
            do {
                let response = try decoder.decode(ResponseType.self, from: data)
                
                DispatchQueue.main.async {
                    completion(response, nil)
                }
            } catch {
                do {
                    //Decode Error if decoding fails
                    let errorResponse = try decoder.decode(FlickrAPIErrorResponse.self, from: data)
                    
                    DispatchQueue.main.async {
                        completion(nil, errorResponse)
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                }
                
            }
            
        }
        task.resume()
    }
    
}


