//
//  Worker.swift
//  MaidMe
//
//  Created by Viktor on3/11/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit
import SwiftyJSON
import RealmSwift

class Worker: Object {
    @objc dynamic var workerID: String!
    @objc dynamic var availableTime: Double = 0
    @objc dynamic var lastName: String!
    @objc dynamic var firstName: String!
    @objc dynamic var price: Float = 0
    @objc dynamic var pricePerHour: Float = 0
    @objc dynamic var materialPrice: Float = 0
    @objc dynamic var rateAverage: Float = 0
    @objc dynamic var phone: String?
    @objc dynamic var avartar: String?
    
    convenience init(workerID: String!, availableTime: Double?, lastName: String?, firstName: String?, price: Float?, pricePerHour: Float?, materialPrice: Float?, rateAverage: Float?, phone: String?, avartar: String?) {
		self.init()
		self.workerID = workerID
        self.availableTime = availableTime!
        self.lastName = lastName ?? ""
        self.firstName = firstName ?? ""
        self.price = price!
        self.pricePerHour = pricePerHour!
        self.materialPrice = materialPrice!
        self.rateAverage = rateAverage!
        self.phone = phone
        self.avartar = avartar
    }
    
	convenience init(workerDic: JSON) {
		self.init()
        self.workerID = workerDic["_id"].string
        self.availableTime = workerDic["available_time"].doubleValue
        self.lastName = workerDic["last_name"].stringValue
        self.firstName = workerDic["first_name"].stringValue
		if workerDic["price"] != nil {
			self.price = workerDic["price"].float!
		}
        if workerDic["price_per_hour"] != nil {
            self.pricePerHour = workerDic["price_per_hour"].float!
        }
        self.materialPrice = (workerDic["material_price"].float == nil ? 0 : workerDic["material_price"].floatValue)
		if  workerDic["rate_average"].float != nil {
				self.rateAverage = workerDic["rate_average"].float!
		}
        self.phone = workerDic["phone"].string
        self.avartar = workerDic["avatar"].string ?? ""
    }
	
    convenience init(suggestedWorker: SuggesstedWorker) {
		self.init()
        self.workerID = suggestedWorker.workerID
        self.availableTime = suggestedWorker.availableTime
        self.lastName = suggestedWorker.lastName ?? ""
        self.firstName = suggestedWorker.firstName ?? ""
        self.price = suggestedWorker.price
        self.pricePerHour = suggestedWorker.price_per_hour
        self.materialPrice = suggestedWorker.materialPrice
        self.rateAverage = suggestedWorker.rateAverage
        self.phone = suggestedWorker.phone
        self.avartar = suggestedWorker.avartar
    }

	override static func primaryKey() -> String? {
		return "workerID"
	}

}

extension Worker {
    func getWorkerList(_ list: JSON) -> [Worker] {
        var workerList = [Worker]()
        
        for (_, dic) in list {
            let item = Worker(workerDic: dic)
            if item.workerID == nil && !item.firstName.isEmpty {
                continue
            }
            
            workerList.append(item)
        }
        
        return workerList
    }
}
