//
//  PayfortRequest.swift
//  MaidMe
//
//  Created by Viktor on 12/25/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import UIKit
import SwiftyJSON
import RealmSwift

class PayfortRequest: Object {
    
    @objc dynamic var command : String!
    @objc dynamic var language : String?
    @objc dynamic var sdk_token : String?
    @objc dynamic var merchant_reference  : String?
    @objc dynamic var amount :String?
    @objc dynamic var currency :String?
    @objc dynamic var customer_email :String?
    @objc dynamic var payment_option :String?
    @objc dynamic var eci :String?
    @objc dynamic var order_description :String?
    @objc dynamic var customer_ip : String?
    @objc dynamic var customer_name : String?
    @objc dynamic var settlement_reference : String?
    @objc dynamic var merchant_extra : String?
    @objc dynamic var merchant_extra1 : String?
    @objc dynamic var merchant_extra2 : String?
    @objc dynamic var merchant_extra3 : String?
    @objc dynamic var merchant_extra4 : String?
    @objc dynamic var phone_number : String?
    
    
    convenience init(fortRequestDic: JSON) {
        self.init()
        
        self.command  = fortRequestDic["command"].string
        self.language = fortRequestDic["language"].string
        self.sdk_token = fortRequestDic["sdk_token"].string
        self.merchant_reference = fortRequestDic["merchant_reference "].string
        self.amount = fortRequestDic["amount"].string
        self.currency = fortRequestDic["currency"].string
        self.customer_email = fortRequestDic["customer_email"].string
        self.payment_option = fortRequestDic["payment_option"].string
        self.eci = fortRequestDic["eci"].string
        self.order_description = fortRequestDic["order_description"].string
        self.customer_ip = fortRequestDic["customer_ip"].string
        self.customer_name = fortRequestDic["customer_name"].string
        self.settlement_reference = fortRequestDic["settlement_reference"].string
        self.merchant_extra = fortRequestDic["merchant_extra"].string
        self.merchant_extra1 = fortRequestDic["merchant_extra1"].string
        self.merchant_extra2 = fortRequestDic["merchant_extra2"].string
        self.merchant_extra3 = fortRequestDic["merchant_extra3"].string
        self.merchant_extra4 = fortRequestDic["merchant_extra4"].string
        self.phone_number = fortRequestDic["phone_number"].string
        
    }
    
}

