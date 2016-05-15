//
//  NotificationManager.swift
//  rüm
//
//  Created by Andrew Fang on 4/29/16.
//  Copyright © 2016 Fang Industries. All rights reserved.
//

import Foundation
class NotificationManager {
    
    // Singleton
    static let sharedInstance = NotificationManager()
    
    struct Constants {
        static let ACTION_CATEGORY = "KudosCategory"
        static let DEVICE_TOKEN = "DEVICE_TOKEN"
    }
    
    func registerForNotifications() {
        let action = UIMutableUserNotificationAction()
        action.activationMode = .Background
        action.title = "Give kudos"
        action.identifier = "kudos"
        action.destructive = false
        action.authenticationRequired = false
        
        let actionCategory = UIMutableUserNotificationCategory()
        actionCategory.identifier = Constants.ACTION_CATEGORY
        actionCategory.setActions([action], forContext: .Default)
        
        let notificationSettings = UIUserNotificationSettings(forTypes: [.Alert ,.Badge , .Sound], categories: [actionCategory])
        UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
    }
    
     func sendNotification() {
        let notification = UILocalNotification()
        notification.fireDate = NSDate(timeIntervalSinceNow: 10)
        
        let names = ["Sarah", "Jare", "Jorge"]
        notification.alertBody = "\(names[Int(arc4random()) % 3]) just \(Database.tasks[Int(arc4random()) % 4].lowercaseString)!";
        notification.timeZone = NSTimeZone.defaultTimeZone()
        notification.soundName = UILocalNotificationDefaultSoundName
        notification.applicationIconBadgeNumber = UIApplication.sharedApplication().applicationIconBadgeNumber
        notification.category = Constants.ACTION_CATEGORY
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
    
    func notificationsAllowed() -> Bool {
        return UIApplication.sharedApplication().isRegisteredForRemoteNotifications()
    }
    
}