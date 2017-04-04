//
//  AppDelegate.swift
//  ProlificCodingChallenge
//
//  Created by Chad Wiedemann on 3/15/17.
//  Copyright © 2017 Chad Wiedemann LLC. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let dao = DAO.sharedInstance

    //creates first ViewContoller and embeds it in a navigation controller
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let controller = OpeningViewController()
        let navigationController = UINavigationController(rootViewController: controller)
        self.window = UIWindow.init(frame: UIScreen.main.bounds)
        self.window?.makeKeyAndVisible()
        self.window?.rootViewController = navigationController
        self.dao.loadDataFromCoreData()
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        return true
    }

    //save managed object context when app leaves activity
    func applicationWillResignActive(_ application: UIApplication) {
        dao.saveContext()
    }

    //save managed object context when enters background
    func applicationDidEnterBackground(_ application: UIApplication) {
        dao.saveContext()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    //save managed object context when app terminates
    func applicationWillTerminate(_ application: UIApplication) {
        dao.saveContext()
    }
}

