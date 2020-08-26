//
//  AppDelegate.swift
//  Pokemons Info Test
//
//  Created by Vadym on 25.08.2020.
//  Copyright © 2020 Vadym. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        setupWindow()
        
        return true
    }
    
    func setupWindow() {
        let navController = UINavigationController()
        let assemblyBuilder = AssemblyModelBuilder()
        let router = Router(navConroller: navController, assemblyBuilder: assemblyBuilder)
        router.initialVC()
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = navController
        window.makeKeyAndVisible()
        self.window = window
    }
}

