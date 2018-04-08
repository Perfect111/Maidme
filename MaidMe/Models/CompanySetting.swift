//
//  CompanySetting.swift
//  MaidMe
//
//  Created by Viktor on4/20/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit
import SwiftyJSON
import RealmSwift

class CompanySetting: Object {
    @objc dynamic var compID: String!
    @objc dynamic var minCancelTime: Int = 0
    @objc dynamic var minPeriodWorkingHour: Int = 0
    @objc dynamic var preMinTimeForBooking: Int = 0
    @objc dynamic var periodTimeBetweenTwoBooking: Int = 0
    @objc dynamic var refundFee: Double = 0
    
    convenience init(companyDic: JSON) {
		self.init()
        self.compID = companyDic["_id"].string
		if companyDic["min_cancel_time"] != nil {
			self.minCancelTime = companyDic["min_cancel_time"].int!
		}
		
		if companyDic["min_period_working_hour"] != nil {
			self.minPeriodWorkingHour = companyDic["min_period_working_hour"].int!
		}
		
		if companyDic["pre_min_time_for_booking"] != nil {
			self.preMinTimeForBooking = companyDic["pre_min_time_for_booking"].int!
		}
		
		if companyDic["period_of_time_two_booking"] != nil {
			self.periodTimeBetweenTwoBooking = companyDic["period_of_time_two_booking"].int!
		}
		if companyDic["refund_fee"] != nil {
			self.refundFee = companyDic["refund_fee"].double!
		}
		
    }
	
	override static func primaryKey() -> String? {
		return "compID"
	}

}
