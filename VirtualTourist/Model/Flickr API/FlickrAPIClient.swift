//
//  FlickrAPIClient.swift
//  VirtualTourist
//
//  Created by Charlie Scheer on 10/4/19.
//  Copyright © 2019 Praxsis. All rights reserved.
//

import Foundation
import UIKit
import CoreData

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
            
            let decoder = JSONDecoder()
            
            do {
                let response = try decoder.decode(ResponseType.self, from: data)
                
                DispatchQueue.main.async {
                    completion(true, response, nil)
                }
            } catch {
                
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
    
    static func fetchPhotos(mapAnnotation: VirtualTouristMapAnnotation, dataController: DataController, completion: @escaping (Bool, Error?) -> Void) {
        FlickrAPIClient.fetchURLS(mapAnnotation: mapAnnotation, dataController: dataController) { (success, urls, error) in
            if success {
                
                if let urls = urls {
                    
                    for url in urls {
                        let dataTask = URLSession.shared.dataTask(with: url) { (data, response, error) in
                            guard error == nil, let data = data else {
                                return
                            }
                            
                            let photo = Photo.init(context: dataController.viewContext)
                            photo.photoData = data
                            photo.pin = mapAnnotation.pin
                            
                            
                            print(dataController.backgroundContext.hasChanges)
                            do {
                                try dataController.backgroundContext.save()
                            } catch {
                                print("Save failed!")
                            }
                            print(dataController.backgroundContext.hasChanges)
                        }
                        
                        dataTask.resume()
                        
                    }
                }
            } else {
                DispatchQueue.main.async {
                    completion(false, error)
                }
            }
            
        }
    }
    
    static func fetchURLS(mapAnnotation: VirtualTouristMapAnnotation, dataController: DataController, completion: @escaping (Bool, [URL]?, Error?) -> Void) {
        FlickrAPIClient.preformImageLocationSearch(from: mapAnnotation) { (success, response, error) in
            guard error == nil, let flickPhotoRepsonse = response else {
                print("Could not fetch")
                DispatchQueue.main.async {
                    completion(false, nil, error)
                }
                return
            }
            
            var URLArray: [URL] = []
            
            for photo in flickPhotoRepsonse.photos.photoProperties {
                guard let url = URL(string: photo.url) else {
                    print("Could not create URL")
                    return
                }
             
                URLArray.append(url)
            }
            DispatchQueue.main.async {
                completion(true, URLArray, nil)
            }
        }
    }
    
    //TO DO: add an error for the api returning no images
    static private func preformImageLocationSearch(from mapAnnotation: VirtualTouristMapAnnotation, completion: @escaping (Bool, FlickrAPIPhotosSearchResonse?, Error?) -> Void) {
        let latitude = mapAnnotation.pin.latitude
        let longitude = mapAnnotation.pin.longitude
        
        let url = FlickrAPIClient.endPoints.getPhotos(latitude, longitude).url
        
        taskForGetRequest(url: url, responseType: FlickrAPIPhotosSearchResonse.self) { (success, response, error) in
            if error == nil {
                DispatchQueue.main.async {
                    completion(true, response, nil)
                }
            } else {
                DispatchQueue.main.async {
                    completion(false, nil, error)
                }
            }
        }
    }
    
    private static func saveImageDataToContextFrom(url: URL, dataController: DataController) {
        let dataTask = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard error == nil, let data = data else {
                return
            }
            
            let photo = Photo.init(context: dataController.backgroundContext)
            photo.photoData = data
        }
        dataTask.resume()
    }
    
    static func getImageFromSavedImageData(photoObject: Photo) -> UIImage? {
        var image = UIImage()
        
        guard let data = photoObject.photoData else {
            print("No photo data found")
            return nil
        }
        if let photo = UIImage(data: data) {
            image = photo
        } else {
            print("Could not convert image")
        }
        
        
        return image
    }
}




