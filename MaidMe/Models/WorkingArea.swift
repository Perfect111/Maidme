//
//  WorkingArea.swift
//  MaidMe
//
//  Created by Viktor on 2/26/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit
import SwiftyJSON
import RealmSwift

class WorkingArea: Object {
    @objc dynamic var areaID: String!
    @objc dynamic var timeZone: String?
    @objc dynamic var area: String?
    @objc dynamic var emirate: String?
    @objc dynamic var country: String?
    var status: WorkingAreaStatus?
	@objc dynamic var statusInt = 0
    
    convenience init(areaID: String!, timeZone: String?, area: String?, emirate: String?, country: String?, status: WorkingAreaStatus?) {
		self.init()
		self.areaID = areaID
        self.timeZone = timeZone
        self.area = area
        self.emirate = emirate
        self.country = country
        self.status = status
		self.statusInt = (self.status?.rawValue)!
    }
    
    convenience init(areaDic: JSON) {
		self.init()
        self.areaID = areaDic["_id"].string
        self.timeZone = areaDic["time_zone"].string
        self.area = areaDic["area"].string
        self.emirate = areaDic["emirate"].string
        self.country = areaDic["country"].string
        self.status = WorkingAreaStatus.status(areaDic["status"].intValue)
		self.statusInt = (self.status?.rawValue)!
    }
	
	override static func primaryKey() -> String? {
		return "areaID"
	}

}

enum WorkingAreaStatus: Int {
    case inactive = 0
    case active
    
    static func status(_ rawValue: Int) -> WorkingAreaStatus {
        switch(rawValue) {
        case 0: return .inactive
        case 1: return .active
        default: return .inactive
        }
    }
}
