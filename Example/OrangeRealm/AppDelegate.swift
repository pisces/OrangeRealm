//
//  AppDelegate.swift
//  OrangeRealm
//
//  Created by hh963103@gmail.com on 04/23/2017.
//  Copyright (c) 2017 hh963103@gmail.com. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        SampleRealmManager.shared.initialize()
        
        return true
    }
}

