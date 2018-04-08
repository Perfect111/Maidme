//
//  Booking.swift
//  MaidMe
//
//  Created by Viktor on 3/16/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit
import SwiftyJSON
import RealmSwift

class Booking: Object, NSCopying {
   
    
    
    @objc dynamic var bookingID: String?
    @objc dynamic var workerName: String?
    @objc dynamic var workerID: String?
    @objc dynamic var time: Date?
    @objc dynamic var service: WorkingService?
    @objc dynamic var hours: Int = 0
    @objc dynamic var price: Float = 0
    @objc dynamic var materialPrice: Float = 0
    @objc dynamic var address: Address?
    @objc dynamic var payerCard: Card?
    @objc dynamic var maid: Worker?
    @objc dynamic var bookingCode: String?
    var companySetting: CompanySetting?
    @objc dynamic var timeOfRating: Date?
    @objc dynamic var comment: String?
    @objc dynamic var rating: Float = 0
    @objc dynamic var workingAreaRef: WorkingArea?
    var status: BookingStatus?
    @objc dynamic var avartar: String?
    @objc dynamic var bookingStatus: Int = 0
    @objc dynamic var isRebookable: Bool = false
    
    //payfort ResponseData
//    dynamic var merchant_reference: String?
//    dynamic var expiry_date: String?
//    dynamic var authorization_code: String?
//    dynamic var token_name: String?
//    dynamic var amount: String?
//    dynamic var sdk_token: String?
//    dynamic var customer_email: String?
//    dynamic var card_holder_name: String?
//    dynamic var eci: String?
//    dynamic var fort_id: String?
//    dynamic var payment_option: String?
//    dynamic var card_number: String?
//    dynamic var customer_ip: String?
//    dynamic var currency: String?
    
    @objc dynamic var responseDic: PayfortResponse?
    
    
    
    
    convenience init(bookingID: String?, workerName: String?, workerID: String?, time: Date?, service: WorkingService?, workingAreaRef: WorkingArea?, hours: Int?, price: Float?, materialPrice: Float?, payerCard: Card?, avartar: String?,maid: Worker?, responseDic: PayfortResponse?) {
		self.init()
        self.bookingID = bookingID
        self.workerName = workerName
        self.workerID = workerID
        self.time = time
        self.service = service
        self.workingAreaRef = workingAreaRef
		if hours != nil {
			self.hours = hours!
		}
		
		if price != nil {
			self.price = price!
		}
		
		if payerCard != nil {
			self.payerCard = payerCard
		}
		
		if materialPrice != nil {
			self.materialPrice = materialPrice!
		}
		
		if avartar != nil {
			self.avartar = avartar
		}
		
		if maid != nil {
			self.maid = maid
		}
        
        if responseDic != nil{
            self.responseDic = responseDic
        }
		
    }
    
    convenience init(bookingDic: JSON) {
		self.init()
        self.bookingID = bookingDic["_id"].string
        self.time = DateTimeHelper.getDateFromString(bookingDic["time_of_service"].string, format: DateFormater.twentyFourhoursFormat)
        self.service = WorkingService(serviceDic: bookingDic["service_type_ref"])
        self.hours = bookingDic["working_hours"].int!
        self.price = bookingDic["price"].float!
//        self.materialPrice = bookingDic["material_price"].float!
        self.address = Address(dic: bookingDic["address"])
        self.maid = Worker(workerDic: bookingDic["maid"])
        self.bookingCode = bookingDic["booking_code"].string
        self.companySetting = CompanySetting(companyDic: bookingDic["company_ref"])
        self.timeOfRating = DateTimeHelper.getDateFromString(bookingDic["time_of_rating"].string, format: DateFormater.twentyFourhoursFormat)
        self.comment = bookingDic["comment"].string
        self.rating = bookingDic["maid"]["rate_average"].float!
        self.workingAreaRef = WorkingArea(areaDic: bookingDic["working_area_ref"])
        self.status = BookingStatus(rawValue: bookingDic["status"].intValue)
        self.bookingStatus = bookingDic["status"].int!
		if  bookingDic["is_rebookable"].bool != nil {
			self.isRebookable = bookingDic["is_rebookable"].bool!	
		}
		
	}
    func copy(with zone: NSZone? = nil) -> Any {
   
        let copy = Booking(bookingID: bookingID, workerName: workerName, workerID: workerID, time: time, service: service, workingAreaRef: workingAreaRef, hours: hours, price: price, materialPrice: materialPrice, payerCard: payerCard, avartar: avartar,maid: maid, responseDic: responseDic)
        return copy
    }
	
	override static func primaryKey() -> String? {
		return "bookingID"
	}

}

enum BookingStatus: Int {
    case locked = 0
    case booked
    case done
    case canceledRefundFree
    case canceledRefundCharged
    case canceledNoRefund
    case paid
    
    static func status(_ rawValue: Int) -> BookingStatus {
        switch(rawValue) {
        case 0: return .locked
        case 1: return .booked
        case 2: return .done
        case 3: return .canceledRefundFree
        case 4: return .canceledRefundCharged
        case 5: return .canceledNoRefund
        case 6: return .paid
        default: return .booked
        }
    }
    
    static func getRawString(_ status: BookingStatus) -> String {
        switch(status) {
        case .locked: return "LOCKED"
        case .booked: return "BOOKED"
        case .paid,
             .done: return "DONE"
        case .canceledRefundFree,
             .canceledRefundCharged,
             .canceledNoRefund: return "CANCELED"
        }
    }
    
    static func getColorCode(_ status: BookingStatus) -> UIColor {
        switch(status) {
        case .locked: return UIColor.blue
        case .booked: return UIColor.purple
        case .done: return UIColor.green
        case .canceledRefundFree,
        .canceledRefundCharged,
        .canceledNoRefund: return UIColor.red
        case .paid: return UIColor.orange
        }
    }
}


