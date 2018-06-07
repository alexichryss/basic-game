//
//  AppDelegate.swift
//  Wormhole2
//
//  Created by Alexi Chryssanthou on 5/30/18.
//  Copyright © 2018 mobi.uchicago. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var launchFromTerminated = true


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        print("Wormhole launched")
        setPreferences()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        if launchFromTerminated {
            showSplashScreen(autoDismiss: false)
            launchFromTerminated = false
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        print("Wormhole is terminating")
        if launchFromTerminated == false {
            launchFromTerminated = true
        }
    }

    //MARK: - Custom Methods for App Startup
    // set the default preferences for the Settings.bundle
    fileprivate func setPreferences() {
        let now = NSDate()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM, dd, yyyy"
        let date = dateFormatter.string(from: now as Date)
        
        let defaults = UserDefaults.standard
        
        // set developer if it's never been set
        if (defaults.string(forKey: "developer") == nil) {
            defaults.set("Alexi Chryssanthou", forKey: "developer")
        }
        // set initial launch if it's never been set
        if (defaults.string(forKey: "initial_launch") == nil) {
            defaults.set(date, forKey: "initial_launch")
        }
        
        // set or increment times app has been launched
        let count = defaults.integer(forKey: "launch_count")
        if (count == 0) {
            defaults.set(1, forKey: "launch_count")
        } else { defaults.set(count+1, forKey: "launch_count") }
        
        // set scores if it's never been set
        if (defaults.array(forKey: "highScores") == nil) {
            defaults.set(Array(repeating:0, count:15), forKey: "highScores")
        }
        
        defaults.synchronize()
        print("Initial Launch: " + (defaults.string(forKey: "initial_launch") ?? "not yet set"))
        print("Developer: " + (defaults.string(forKey: "developer") ?? "not yet set"))
        print("Settings saved.")
    }

    // load the SplashViewController from Splash.storyboard
    func showSplashScreen(autoDismiss: Bool) {
        let storyboard = UIStoryboard(name: "Splash", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "SplashViewController") as! SplashViewController
        
        // Control the behavior from suspended to launch
        controller.autoDismiss = autoDismiss
        
        // Present the view controller over the top view controller
        let vc = UIApplication.shared.keyWindow!.rootViewController!
        vc.present(controller, animated: false, completion: nil)
    }
    
}

