//
//  PayfortResponse.swift
//  MaidMe
//
//  Created by Viktor on 12/25/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import UIKit
import SwiftyJSON
import RealmSwift

class PayfortResponse: Object {
    
    @objc dynamic var command : String?
    @objc dynamic var merchant_reference :String?
    @objc dynamic var sdk_token : String?
    @objc dynamic var amount :String?
    @objc dynamic var currency :String?
    @objc dynamic var customer_email :String?
    @objc dynamic var payment_option :String?
    @objc dynamic var eci :String?
    @objc dynamic var order_description :String?
    @objc dynamic var customer_ip :String?
    @objc dynamic var customer_name :String?
    @objc dynamic var settlement_reference :String?
    @objc dynamic var merchant_extra :String?
    @objc dynamic var merchant_extra1 :String?
    @objc dynamic var merchant_extra2 :String?
    @objc dynamic var merchant_extra3 :String?
    @objc dynamic var merchant_extra4 :String?
    @objc dynamic var fort_id :String?
    @objc dynamic var authorization_code :String?
    @objc dynamic var response_message :String?
    @objc dynamic var response_code :String?
    @objc dynamic var expiry_date :String?
    @objc dynamic var card_number :String?
    @objc dynamic var status :String?
    @objc dynamic var phone_number :String?
    @objc dynamic var token_name:String?

    
    
    convenience init(fortResponseDic: JSON) {
        self.init()
        
        self.command = fortResponseDic["command"].string
        self.merchant_reference = fortResponseDic["merchant_reference"].string
        self.sdk_token = fortResponseDic["sdk_token"].string
        self.amount = fortResponseDic["amount"].string
        self.currency = fortResponseDic["currency"].string
        self.customer_email = fortResponseDic["customer_email"].string
        self.payment_option = fortResponseDic["payment_option"].string
        self.order_description = fortResponseDic["order_description"].string
        self.eci = fortResponseDic["eci"].string
        self.customer_ip = fortResponseDic["customer_ip"].string
        self.customer_name = fortResponseDic["customer_name"].string
        self.settlement_reference = fortResponseDic["settlement_reference"].string
        self.merchant_extra = fortResponseDic["merchant_extra"].string
        self.merchant_extra1 = fortResponseDic["merchant_extra1"].string
        self.merchant_extra2 = fortResponseDic["merchant_extra2"].string
        self.merchant_extra3 = fortResponseDic["merchant_extra3"].string
        self.merchant_extra4 = fortResponseDic["merchant_extra4"].string
        self.fort_id = fortResponseDic["fort_id"].string
        self.authorization_code = fortResponseDic["authorization_code"].string
        self.response_message = fortResponseDic["response_message"].string
        self.response_code = fortResponseDic["response_code"].string
        self.expiry_date = fortResponseDic["expiry_date"].string
        self.card_number = fortResponseDic["card_number"].string
        self.status = fortResponseDic["status"].string
        self.phone_number = fortResponseDic["phone_number"].string
        self.token_name = fortResponseDic["token_name"].string
        
    }
    
}
