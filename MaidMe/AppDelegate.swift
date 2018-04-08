//
//  AppDelegate.swift
//  MaidMe
//
//  Created by Viktor on2/15/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit
import SSKeychain
import GooglePlaces
import SVProgressHUD
import RealmSwift
import Fabric
import Crashlytics
import Alamofire

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    let notificationManager = NotificationManager()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        window?.backgroundColor = UIColor.white
        let navBarAttributesDictionary: [NSAttributedStringKey: Any]? = [
            NSAttributedStringKey(rawValue: NSAttributedStringKey.foregroundColor.rawValue): UIColor.gray,
            NSAttributedStringKey.font: UIFont(name: CustomFont.quicksanRegular, size: 16)!
        ]
        
        UINavigationBar.appearance().titleTextAttributes = navBarAttributesDictionary
        UITabBar.appearance().tintColor = UIColor(red: 61/255, green: 185/255, blue: 216/255, alpha: 1)
        UINavigationBar.appearance().tintColor = UIColor.gray
		
		// Configure SVProgressHUD
		SVProgressHUD.setDefaultStyle(.custom)
		SVProgressHUD.setDefaultMaskType(.black)
		SVProgressHUD.setRingNoTextRadius(14)
		SVProgressHUD.setForegroundColor(UIColor(red:0.27, green:0.68, blue:0.75, alpha:1.00))
		SVProgressHUD.setBackgroundColor(UIColor.white)
		SVProgressHUD.setBackgroundLayerColor(UIColor(white: 0, alpha: 0.25))
		// Store Payfort public key into keychain
        SSKeychain.setPassword(PaymentKey.payfort, forService: KeychainIdentifier.appService, account: KeychainIdentifier.payfortkey)

		Realm.Configuration.defaultConfiguration.deleteRealmIfMigrationNeeded = true
		let realm = try! Realm()
        debugPrint("Path to realm file: " + realm.configuration.fileURL!.absoluteString)

        //GooglePlaces search address
        GMSPlacesClient.provideAPIKey(GooglePlacesSearchAddress.key)
        
//        #if DEVELOPMENT
//        enableDevelopmentMode(true)
//        #else
//        enableDevelopmentMode(false)
//        #endif
        
        enableDevelopmentMode(true)
        
        Fabric.with([Crashlytics.self])
        CheckMobiConfigurations.setup()
        notificationManager.setupNotificationSettings()
        
        
        return true
    }


    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        notificationManager.application(application, didReceive: notification)
    }
    
    func enableDevelopmentMode(_ flag: Bool) {
        
        if flag {
            
            Configuration.serverUrl = Configuration.serverDevUrl
            Configuration.payfortUrl = Configuration.payfortDevUrl
            Configuration.startSDKUrl = Configuration.startSDKDevUrl
            PaymentKey.payfort = PaymentKey.payfortDev
            PaymentKey.payfortApiKey = PaymentKey.payfortApiKeyDev
            Configuration.requestPhrase = Configuration.payfortDevPhrase
            Configuration.accessCode = Configuration.payfortDevAccessCode
            Configuration.merchantID = Configuration.payfortDevMerchantID
            
        }
        else {
            
            Configuration.serverUrl = Configuration.serverProductionUrl
            Configuration.payfortUrl = Configuration.payfortProductionUrl
            Configuration.startSDKUrl = Configuration.startSDKProductionUrl
            PaymentKey.payfort = PaymentKey.payfortProduction
            PaymentKey.payfortApiKey = PaymentKey.payfortApiKeyLive
            Configuration.requestPhrase = Configuration.payfortProductPhrase
            Configuration.accessCode = Configuration.payfortProductAccessCode
            Configuration.merchantID = Configuration.payfortProductMerchantID
            
        }
        
    }
    
}

extension NSData {
    
    /// Return hexadecimal string representation of NSData bytes
    
    public var hexadecimalString: NSString {
        var bytes = [UInt8](repeating: 0, count: length)
        getBytes(&bytes, length: length)
        
        let hexString = NSMutableString()
        for byte in bytes {
            hexString.appendFormat("%02x", UInt(byte))
        }
        
        return NSString(string: hexString)
    }
}

