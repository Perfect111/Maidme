//
//  PayfortSdkToken.swift
//  MaidMe
//
//  Created by Viktor on 12/22/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import UIKit
import SwiftyJSON
import RealmSwift

class PayfortSdkToken: Object {
    
    @objc dynamic var service_command : String!
    @objc dynamic var access_code : String?
    @objc dynamic var language : String?
    @objc dynamic var device_id : String?
    @objc dynamic var signature : String?
    @objc dynamic var sdk_token : String?
    @objc dynamic var merchant_identifier : String?
    
    

    
    convenience init(service_command: String!, access_code: String?, merchant_identifier: String?, language: String?, device_id: String?, signature: String?, sdk_token: String?){
    
        self.init()
        
        self.service_command = service_command
        self.access_code = access_code
        self.language = language
        self.device_id = device_id
        self.signature = signature
        self.sdk_token = sdk_token
        self.merchant_identifier = merchant_identifier

    }
    
    convenience init(sdkTokenDic: JSON) {
        self.init()
        
        self.service_command = sdkTokenDic["service_command"].string
        self.access_code = sdkTokenDic["access_code"].string
        self.language = sdkTokenDic["language"].string
        self.device_id = sdkTokenDic["device_id"].string
        self.signature = sdkTokenDic["signature"].string
        self.sdk_token = sdkTokenDic["sdk_token"].string
        self.merchant_identifier = sdkTokenDic["merchant_identifier"].string
    }
    
}
