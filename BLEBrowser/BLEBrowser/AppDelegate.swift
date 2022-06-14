//
//  AppDelegate.swift
//  BLEBrowser
//
//  Created by 野中淳 on 2022/05/12.
//

import UIKit
import FirebaseCore

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        FirebaseApp.configure()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        window?.backgroundColor = .systemBackground
        
        let navigatiorController = UINavigationController(rootViewController: FirstViewController())
        window?.rootViewController = navigatiorController
        
        
        return true
        
    }
}

