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
            case .getPhotos(let lat, let lon): return endPoints.baseURL + endPoints.api_key_param + "&accuracy=11" + "&lat=" + String(lat) + "&lon=" + String(lon) + "&per_page=5" + "&extras=url_o" + "&format=json&nojsoncallback=1"
                
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    private class func taskForGetRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, completion: @escaping (Bool, ResponseType?, Error?) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        print(url)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard error == nil, let data = data else {
                return
            }
            
            let json = try? JSONSerialization.jsonObject(with: data, options: [])
            print(json)
            
            let decoder = JSONDecoder()
            
            do {
                let response = try decoder.decode(ResponseType.self, from: data)
    
                DispatchQueue.main.async {
                    completion(true, response, nil)
                }
            } catch {
                print(error)
                do {
                    //Decode Error if decoding fails
                    let errorResponse = try decoder.decode(FlickrAPIErrorResponse.self, from: data)
                    
                    DispatchQueue.main.async {
                        completion(false, nil, errorResponse)
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(false, nil, error)
                    }
                }
                
            }
            
        }
        task.resume()
    }

    //TO DO: add an error for the api returning no images
    static func preformImageLocationSearch(from mapAnnotation: VirtualTouristMapAnnotation, completion: @escaping (FlickrAPIPhotosSearchResonse?, Error?) -> Void) {
        let latitude = mapAnnotation.pin.latitude
        let longitude = mapAnnotation.pin.longitude
        
        let url = FlickrAPIClient.endPoints.getPhotos(latitude, longitude).url
        
        taskForGetRequest(url: url, responseType: FlickrAPIPhotosSearchResonse.self) { (success, response, error) in
            if error == nil {
                DispatchQueue.main.async {
                    completion(response, nil)
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
    }
}




