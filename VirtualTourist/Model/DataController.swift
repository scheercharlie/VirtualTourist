//
//  DataController.swift
//  VirtualTourist
//
//  Created by Charlie Scheer on 9/30/19.
//  Copyright © 2019 Praxsis. All rights reserved.
//

import Foundation
import CoreData
import MapKit

class DataController {
    let persistentContainer: NSPersistentContainer!
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    init(modelName: String) {
        persistentContainer = NSPersistentContainer(name: modelName)
    }
    
    func load(completion: (() -> Void)? = nil) {
        persistentContainer.loadPersistentStores { (storeDescription, error) in
            guard error == nil else {
                //TO DO: handle the error better
                fatalError("Could not load persistent store")
            }
            completion?()
        }
    }
    
    func getPinFromUUID(uuidString: String) -> Pin {
        let predicate = NSPredicate(format: "uuid = %@", uuidString)
        let fetchRequest = NSFetchRequest<Pin>()
        fetchRequest.predicate = predicate
        
        let results = try? fetchRequest.execute()
        
        print(results?.count)
        print(results)
        
        return Pin()
    }
}
