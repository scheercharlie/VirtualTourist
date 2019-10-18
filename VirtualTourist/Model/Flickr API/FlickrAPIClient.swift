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

let flickrAPIClient = FlickrAPIClient()

class FlickrAPIClient {
    static let apiKey = "8b463f94bbb5f9d350f7092dcd3753f6"
    
    enum endPoints {
        
        static let apiSecret = "42cfa013bdbf06c4"
        static let baseURL = "https://www.flickr.com/services/rest/?method=flickr.photos.search"
        static let api_key_param = "&api_key=\(FlickrAPIClient.apiKey)"
        
        case getPhotos(Double, Double, Int?)
        
        var stringValue: String {
            switch self {
            case .getPhotos(let lat, let lon, let page): return endPoints.baseURL + endPoints.api_key_param + "&lat=" + String(lat) + "&lon=" + String(lon) + "&extras=url_m" +  "&per_page=30" + "&page=\(page ?? 0)" + "&format=json&nojsoncallback=1"
                
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    //MARK: API Get requests
    //Generic Get request
    private func taskForGetRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, completion: @escaping (Bool, ResponseType?, Error?) -> Void) {
        
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
    
    //Get URLS from the Flickr API
    //For the returned images, create photo entities and add urls to them
    func fetchImageURLS(mapAnnotation: VirtualTouristMapAnnotation, dataController: DataController, page: Int, completion: @escaping (Bool,  Error?) -> Void) {
        print("page in fetchimageurls \(page)")
        guard page != 0 else {
            //If this works add an alert to say no more images found
            print("page was 0")
            return
        }
        
        flickrAPIClient.preformImageLocationSearch(from: mapAnnotation, page: page) { (success, response, error) in
            guard error == nil, let flickPhotoRepsonse = response else {
                print("Could not fetch")
                DispatchQueue.main.async {
                    completion(false, error)
                }
                return
            }
            print("page returned from api \(flickPhotoRepsonse.photos.page)")
            DispatchQueue.global().async {
                for photo in flickPhotoRepsonse.photos.photoProperties {
                    if let urlString = photo.url,
                        let url = URL(string: urlString) {
                        let newPhoto = Photo(context: dataController.viewContext)
                        newPhoto.url = url
                        newPhoto.page = Int16(page)
                        newPhoto.pin = mapAnnotation.pin
                        
                        print("new photo")
                        if dataController.viewContext.hasChanges {
                            do {
                                try dataController.viewContext.save()
                                print("saved")
                            } catch {
                                print("couldn't save")
                            }
                        }
                    }
                }
            }
            DispatchQueue.main.async {
                completion(true, nil)
            }
            
        }
    }
    
    
    //Get URLS from the Flickr API
    private func preformImageLocationSearch(from mapAnnotation: VirtualTouristMapAnnotation, page: Int, completion: @escaping (Bool, FlickrAPIPhotosSearchResonse?, Error?) -> Void) {
        let latitude = mapAnnotation.pin.latitude
        let longitude = mapAnnotation.pin.longitude
        
        let url = FlickrAPIClient.endPoints.getPhotos(latitude, longitude, page).url
        print(url)
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
    
    //MARK: Image management Functions
    //Fetch image data for the URLS saved in a photo entity
    func fetchImageDataFor(_ photo: Photo, dataController: DataController, completion: ((Data?, Error?) -> Void)? = nil) {
        
        guard let url = photo.url else {
            print("No valid url found")
            DispatchQueue.main.async {
                if let completion = completion {
                    completion(nil, nil)
                }
            }
            return
        }
        let dataTask = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard error == nil, let data = data else {
                DispatchQueue.main.async {
                    if let completion = completion {
                        completion(nil, error)
                    }
                }
                return
            }
            
            photo.photoData = data
            if let completion = completion {
                completion(data, nil)
            }
        }
        dataTask.resume()
    }


}




