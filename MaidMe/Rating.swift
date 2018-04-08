//
//  Rating.swift
//  MaidMe
//
//  Created by Viktor on 1/9/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import UIKit
import SwiftyJSON

class Rating: NSObject{
    var ratingID: String?
    var last4: String?
    var building: String?
    var timeofService: Date?
    var serviceType: String?
    var lastName: String?
    var firstName: String?
    var rate: Float?
    var avatar: String?
    var price: Float?
    var bookingCode: String?
    var hour: Int?
    var comment: String?
    var bookingID: String?
    var rating: Int?
    var booking_ref_id: String?
    init(ratingID: String?,last4: String?,building: String?,timeofService: Date?,serviceType: String?,lastName: String?,firstName: String?,rate: Float?,avatar: String?,price: Float?,bookingCode: String?,hour: Int?,booking_ref_id: String?) {
        self.ratingID = ratingID
        self.last4 = last4
        self.building = building
        self.timeofService = timeofService
        self.serviceType = serviceType
        self.lastName = lastName
        self.firstName = firstName
        self.rate = rate
        self.avatar = avatar
        self.price = price
        self.bookingCode = bookingCode
        self.hour = hour
        self.booking_ref_id = booking_ref_id
    }
    init(ratingDic: JSON) {
        self.ratingID = ratingDic["_id"].string
        self.last4 = ratingDic["card"]["last4"].string
        self.building = ratingDic["booking_ref"]["address"]["building_name"].string
        self.timeofService = DateTimeHelper.getDateFromString(ratingDic["booking_ref"]["time_of_service"].string, format: DateFormater.twentyFourhoursFormat)
        self.serviceType = ratingDic["booking_ref"]["service_type_ref"]["name"].string
        self.lastName = ratingDic["booking_ref"]["maid"]["last_name"].string
        self.firstName = ratingDic["booking_ref"]["maid"]["first_name"].string
        self.rate = ratingDic["booking_ref"]["maid"]["rate_average"].float
        self.avatar = (ratingDic["booking_ref"]["maid"]["avatar"].string == nil ? " " : ratingDic["booking_ref"]["maid"]["avatar"].string)
        self.price = ratingDic["booking_ref"]["price"].float
        self.bookingCode = ratingDic["booking_ref"]["booking_code"].string
        self.hour = ratingDic["booking_ref"]["working_hours"].int
        self.booking_ref_id = ratingDic["booking_ref"]["_id"].string
        self.bookingID = ratingDic["booking_id"].string
        self.rating = ratingDic["rating"].int
        self.comment = ratingDic["comment"].string
        
        
    }
}
