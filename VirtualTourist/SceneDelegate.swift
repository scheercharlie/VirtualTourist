//
//  SceneDelegate.swift
//  VirtualTourist
//
//  Created by Charlie Scheer on 9/28/19.
//  Copyright © 2019 Praxsis. All rights reserved.
//

import UIKit
import SwiftUI
import CoreData


class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        //Create Storyboard and initial ViewControllers
        let storyboard = UIStoryboard(name: "MapStoryboard", bundle: Bundle.main)
        let initialVC = storyboard.instantiateInitialViewController() as! UINavigationController
        let firstVC = initialVC.topViewController as! TravelLocationsViewController
        
        //Create a DataController and pass it to the first ViewController
        let dataController = DataController(modelName: "VirtualTourist")
        firstVC.dataController = dataController

        // Use a UIHostingController as window root view controller.
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = initialVC
            self.window = window
            window.makeKeyAndVisible()
        }
    }

    func sceneWillResignActive(_ scene: UIScene) {
        //ADD: Save to persistent store
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        //ADD: Save to persistent store
    }


}

