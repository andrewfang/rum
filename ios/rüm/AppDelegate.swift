//
//  AppDelegate.swift
//  rüm
//
//  Created by Andrew Fang on 4/21/16.
//  Copyright © 2016 Fang Industries. All rights reserved.
//

import UIKit
import FBSDKCoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        Lookback.setupWithAppToken("bXBu47CjJLXBtHhMy")
        Lookback.sharedLookback().shakeToRecord = true
        // Uncomment this if you want to reenable Lookback
//        Lookback.sharedLookback().feedbackBubbleVisible = true
        
//        NotificationManager.sharedInstance.registerForNotifications()
        print(NSUserDefaults.standardUserDefaults().valueForKey(NotificationManager.Constants.DEVICE_TOKEN))
        return true
    }
    
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        if (notificationSettings.types != [.None]) {
            application.registerForRemoteNotifications()
        }
    }
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let tokenChars = UnsafePointer<CChar>(deviceToken.bytes)
        var tokenString = ""
        
        for i in 0..<deviceToken.length {
            tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
        }
        
        print("Device Token", tokenString)
        NSUserDefaults.standardUserDefaults().setValue(tokenString, forKey: NotificationManager.Constants.DEVICE_TOKEN)
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print("Failed to register for remote: ", error)
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        application.applicationIconBadgeNumber = 0
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        if let groupid = NSUserDefaults.standardUserDefaults().stringForKey(MainViewController.Constants.GROUP_ID) {
            NetworkingManager.sharedInstance.getLastTask(groupid)
        }
        
        if let userInfoDict = userInfo as? [String: AnyObject] {
            if let aps = userInfoDict["aps"] as? [String: String] {
                print(aps)
            }
        }
//
//            NetworkingManager.
//            if let task = userInfoDict["userId"] as? String, person = userInfoDict["taskId"] as? String {
//                if let vc = window?.rootViewController?.childViewControllers.first?.childViewControllers.first as? MainViewController {
//                    vc.someOneJustActioned(person, action: task)
//                    vc.someOneJustActioned(person, action: <#T##String#>, photo: <#T##String#>)
//                }
//            }
//        }
    }
    
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [NSObject : AnyObject], completionHandler: () -> Void) {
        if let details = userInfo as? [String:AnyObject] {
            if let userId = details["userId"] as? String {
                application.applicationIconBadgeNumber = 0
                NetworkingManager.sharedInstance.giveKudos(userId, completionHandler: completionHandler)
            }
        }
        
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        let handled = FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
        
        return handled
    }


}

