//
//  Country.swift
//  MaidMe
//
//  Created by Viktor on 3/2/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit
import SwiftyJSON
import RealmSwift

class BillingAddress: Object {
    @objc  dynamic var firstName: String!
    @objc dynamic var lastName: String!
    @objc dynamic var phoneNumber: String!
    @objc dynamic var billingAddress: String!
    @objc dynamic var country: String!
    @objc dynamic var region: String?
    @objc dynamic var city: String!
    @objc dynamic var zipCode: Int = 0
    
    convenience init(firstName: String, lastName: String, phone: String, billingAddress: String, country: String, region: String?, city: String, zipCode: Int ) {
		self.init()
        self.firstName = firstName
        self.lastName = lastName
        self.phoneNumber = phone
        self.billingAddress = billingAddress
        self.country = country
        self.region = region
        self.city = city
        self.zipCode = zipCode
    }
	
	override static func primaryKey() -> String? {
		return "firstName"
	}

}
