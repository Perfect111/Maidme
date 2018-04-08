//
//  WorkingService.swift
//  MaidMe
//
//  Created by Viktor on 3/7/16.
//  Copyright © 2016 Mac. All rights reserved.
// avatar

import UIKit
import SwiftyJSON
import RealmSwift

class WorkingService: Object {
    @objc dynamic var serviceID: String!
    @objc dynamic var serviceDescription: String?
    @objc dynamic var name: String?
    var status: WorkingAreaStatus?
    @objc dynamic var avatar: String?
	@objc dynamic var statusInt = 0
    

	convenience init(serviceID: String!, serviceDescription: String?, name: String?, status: WorkingAreaStatus?) {
		self.init()
        self.serviceID = serviceID
        self.serviceDescription = serviceDescription
        self.name = name
        self.status = status
		self.statusInt = (self.status?.rawValue)!
    }
	
    convenience init(serviceDic: JSON) {
		self.init()
        self.serviceID = serviceDic["_id"].string
        self.serviceDescription = serviceDic["description"].string
        self.name = serviceDic["name"].string
        self.avatar = serviceDic["avatar"].string
        self.status = WorkingAreaStatus.status(serviceDic["status"].intValue)
		self.statusInt = (self.status?.rawValue)!
    }
	
	override static func primaryKey() -> String? {
		return "serviceID"
	}

}

extension WorkingService {
    class func getService(_ serviceName: String?, list: [WorkingService]) -> WorkingService? {
        guard let workingService = serviceName else {
            return nil
        }
        
        guard list.count > 0 else {
            return nil
        }
        
        for item in list {
            let itemName = item.name!
            if workingService.lowercased() == itemName.lowercased() {
                return item
            }
        }
        
        return nil
    }
}
