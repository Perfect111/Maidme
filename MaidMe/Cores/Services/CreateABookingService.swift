//
//  CreateABookingService.swift
//  MaidMe
//
//  Created by Viktor on4/4/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class CreateABookingService: RequestManager {
    
    override func request(_ method: HTTPMethod?, _ URLString: URLConvertible?, parameters: [String : AnyObject]?, encoding: ParameterEncoding?, headers: [String : String]?, completionHandler: @escaping (DataResponse<Any>) -> ()) {
       
            super.request(.post, "\(Configuration.serverUrl)\(Configuration.createABookingUrl)", parameters: parameters, encoding: JSONEncoding.default, headers: self.getAuthenticateHeader()) {
                response in
                completionHandler(response)
            }
        
    }
    
    func getCreateABookingParams(_ address: Address, booking: Booking, isIncludeMaterial: Bool) -> [String: AnyObject] {
        
        var abookingParams = [String: AnyObject]()


        
        let addressq: [String: AnyObject] = [
            "building_name": address.buildingName as AnyObject,
            "apartment_no": address.apartmentNo as AnyObject,
            "floor_no": (address.floorNo == nil ? "" : address.floorNo!  ) as AnyObject,
            "street_no": (address.streetNo == nil ? "" : address.streetNo!) as AnyObject,
            "street_name": (address.streetName == nil ? "" : address.streetName!) as AnyObject,
            "zip_po": (address.zipPO == nil ? "" : "\(address.zipPO!)") as AnyObject,
            "area": address.area as AnyObject,
            "emirate": address.emirate as AnyObject,
            "city": address.city as AnyObject,
            "additional_details": (address.additionalDetails == nil ? "" : address.additionalDetails!) as AnyObject ,
            "country": address.country as AnyObject
        ]
        
        abookingParams = [
            "booking_id":booking.bookingID! as AnyObject,
            "maid_id": booking.workerID! as AnyObject,
            "service_type_ref": (booking.service?.serviceID)! as AnyObject,
            "working_area_ref": address.workingArea_ref! as AnyObject,
            "time_of_service": (booking.time?.timeIntervalSince1970)! * 1000 as AnyObject,
            "working_hours": booking.hours as AnyObject,
            "asap": false as AnyObject,
            "address": addressq as AnyObject,
            "material_price": (booking.materialPrice == 0 ? 0 : booking.materialPrice) as AnyObject,
            "booking_code": (booking.bookingCode == nil ? "" : booking.bookingCode!) as AnyObject,
            "token_name" : (booking.responseDic?.token_name)! as AnyObject
        ]
        
        if isIncludeMaterial {
            abookingParams["price"] = (booking.price == 0 ? 0 : booking.price) + (booking.materialPrice == 0 ? 0 : booking.materialPrice) as AnyObject
        }else{
            abookingParams["price"] = (booking.price == 0 ? 0 : booking.price) as AnyObject
        }
        

        
        abookingParams["merchant_reference"] = (booking.responseDic?.merchant_reference)! as AnyObject
        abookingParams["fort_id"] = (booking.responseDic?.fort_id)! as AnyObject
        abookingParams["expiry_date"] = (booking.responseDic?.expiry_date)! as AnyObject
        abookingParams["authorization_code"] = (booking.responseDic?.authorization_code)! as AnyObject
        abookingParams["customer_email"] = (booking.responseDic?.customer_email)! as AnyObject
        abookingParams["eci"] = (booking.responseDic?.eci)! as AnyObject
        abookingParams["payment_option"] = (booking.responseDic?.payment_option)! as AnyObject
        abookingParams["card_number"] = (booking.responseDic?.card_number)! as AnyObject
        abookingParams["customer_ip"] = (booking.responseDic?.customer_ip)! as AnyObject
        abookingParams["amount"] = (booking.responseDic?.amount)! as AnyObject
        abookingParams["command"] = (booking.responseDic?.command)! as AnyObject
        
        return abookingParams
    }
    
    func getBookingCode(_ result: JSON?) -> String? {
        guard let result = result else {
            return nil
        }
        
        return result["booking"]["booking_code"].string
    }
}

