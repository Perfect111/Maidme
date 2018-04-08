//
//  Customer.swift
//  MaidMe
//
//  Created by Viktor on 4/13/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit
import SwiftyJSON
import RealmSwift

class Customer: Object {
    @objc dynamic var customerID: String!
    @objc dynamic var phone: String?
    @objc dynamic var email: String?
    @objc dynamic var defaultArea: WorkingArea?
    @objc dynamic var firstName: String?
    @objc dynamic var lastName: String?
    
    convenience init(customerID: String!, phone: String?, email: String?, defaultArea: WorkingArea?, firstName: String?, lastName: String?) {
		self.init()
        self.customerID = customerID
        self.phone = phone
        self.email = email
        self.defaultArea = defaultArea
        self.firstName = firstName
        self.lastName = lastName
    }
    
    convenience init(customerDic: JSON) {
		self.init()
        self.customerID = customerDic["_id"].string
        self.phone = customerDic["phone"].string
        self.email = customerDic["email"].string
        self.defaultArea = WorkingArea(areaDic: customerDic["default_area"])
        self.firstName = customerDic["first_name"].string
        self.lastName = customerDic["last_name"].string
    }
	
	override static func primaryKey() -> String? {
		return "customerID"
	}

}

