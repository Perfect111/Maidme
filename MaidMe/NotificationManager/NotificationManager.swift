//
//  NotificationManager.swift
//  MaidMe
//
//  Created by Mohammad Alatrash on 6/3/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import Foundation

class NotificationManager: NSObject {
    
    func setupNotificationSettings() {
        UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil))
    }

    class func createReminderNotification(_ name: String, fireDate: Date) {
        let notification = UILocalNotification()
        notification.alertBody = "\(name), \(LocalizedStrings.arrivingTimeMessage)"
        notification.fireDate = fireDate
        notification.soundName = UILocalNotificationDefaultSoundName
        
        UIApplication.shared.scheduleLocalNotification(notification)
    }
}

extension NotificationManager: UIApplicationDelegate {

    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        let rootViewController = UIApplication.shared.windows.first?.rootViewController
        let tabBarController = (rootViewController as? UINavigationController)?.viewControllers.first?.presentedViewController as? UITabBarController
        print(rootViewController)
        tabBarController?.selectedIndex = 2
    }
}
