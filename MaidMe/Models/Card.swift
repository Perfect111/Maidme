//
//  Card.swift
//  MaidMe
//
//  Created by Viktor on 3/3/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit
import SwiftyJSON
import RealmSwift

class Card: Object {
    @objc dynamic var cardPaymentID: String!
    @objc dynamic var cardID: String!
	var brand: CardType?
	@objc dynamic var brandInt: Int = 0
    @objc dynamic var lastFourDigit: String!
    @objc dynamic var number: String?
    @objc dynamic var expiryMonth: Int = 0
    @objc dynamic var expiryYear: Int = 0
    @objc dynamic var ownerName: String!
    @objc dynamic var cvv: String?
//    var cardLogo: UIImage?
	@objc dynamic var cardLogoData: Data?
    @objc dynamic var country: String!
    @objc dynamic var countryCode: String!
    @objc dynamic var isDefault: Bool = true

	convenience init(type: CardType, last4: String, number: String, expiryMonth: Int, expiryYear: Int, ownerName: String, cvv: String, cardLogo: UIImage? = nil, country: String, countryCode: String, isDefault: Bool) {
		self.init()
		self.brand = type
        self.lastFourDigit = last4
        self.number = number
        self.expiryMonth = expiryMonth
        self.expiryYear = expiryYear
        self.ownerName = ownerName
        self.cvv = cvv
//        self.cardLogo = cardLogo
        self.country = country
        self.countryCode = countryCode
        self.isDefault = false
		self.brandInt = self.brand!.rawValue
//		self.cardLogoData = UIImagePNGRepresentation(self.cardLogo!)
    }
    
    convenience init(cardDic: JSON) {
		self.init()
        self.cardPaymentID = cardDic["card_id"].string
        self.cardID = cardDic["id"].string
        self.brand = CardType.brand(cardDic["brand"].string)
        self.lastFourDigit = cardDic["last4"].string
        self.number = cardDic["description"].string
        self.expiryMonth = cardDic["exp_month"].intValue
        self.expiryYear = cardDic["exp_year"].intValue
        self.ownerName = cardDic["name"].string
        self.country = cardDic["country_name"].string
        self.countryCode = cardDic["country_code_name"].string
        self.isDefault = cardDic["default_card"].boolValue
//		self.cardLogoData = UIImagePNGRepresentation(self.cardLogo!)
    }
	
	override static func primaryKey() -> String? {
		return "cardID"
	}

}

extension Card {
    func getLastFourDigit() -> String {
		
		if number == nil {
			return "****"
		}
		
        let count = number!.characters.count
        var endingNumber = ""
        
        guard count >= 4 else {
            return endingNumber
        }
        // for var i = count - 1; i >= count - 4; i -= 1
        for i in stride(from: count-1, to: (count - 4), by: -1)
        {
            let index = number!.characters.index(number!.startIndex, offsetBy: i)
            endingNumber = "\(number![index])" + endingNumber
        }
        
        return endingNumber
    }
}

enum CardType:Int {
    case visa = 0
    case master
    case amex
    case discover
    case diners
    case jcb
    
    static func brand(_ rawValue: String?) -> CardType? {
        guard let code = rawValue else {
            return nil
        }
        
        switch(code) {
        case "visa": return .visa
        case "mastercard": return .master
        default: return nil
        }
    }
}
