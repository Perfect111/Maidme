//
//  LockABookingService.swift
//  MaidMe
//
//  Created by Viktor on3/31/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class LockABookingService: RequestManager {
    
    override func request(_ method: HTTPMethod?, _ URLString: URLConvertible?, parameters: [String : AnyObject]?, encoding: ParameterEncoding?, headers: [String : String]?, completionHandler: @escaping (DataResponse<Any>) -> ()) {
       
            super.request(.post, "\(Configuration.serverUrl)\(Configuration.lockABookingUrl)", parameters: parameters, encoding: JSONEncoding.default, headers: self.getAuthenticateHeader()) {
                response in
                completionHandler(response)
            }
        
    }
    
    func getLockABookingParams(_ bookingInfo: Booking, address: Address, isIncludeMaterial: Bool) -> [String: AnyObject] {
        let addressq: [String: AnyObject] = [
            "building_name": address.buildingName as AnyObject,
            "apartment_no": address.apartmentNo as AnyObject,
            "floor_no": (address.floorNo == nil ? "" : address.floorNo! ) as AnyObject,
            "street_no": (address.streetNo == nil ? "" : address.streetNo!) as AnyObject,
            "street_name": (address.streetName == nil ? "" : address.streetName!) as AnyObject,
            "zip_po": (address.zipPO == nil ? "" : "\(address.zipPO!)") as AnyObject,
            "area": address.area as AnyObject,
            "emirate": address.emirate as AnyObject,
            "city": address.city as AnyObject,
            "additional_details": (address.additionalDetails == nil ? "" : address.additionalDetails!) as AnyObject,
            "country": address.country as AnyObject
        ]
		
        var materialPrice: Float = 0.0
        
        if isIncludeMaterial {
            materialPrice = (bookingInfo.materialPrice == 0.0 ? 0.0 : bookingInfo.materialPrice)
        }
        
        let params: [String: AnyObject] = [
            "maid_id": bookingInfo.workerID! as AnyObject,
            "service_type_ref": bookingInfo.service!.serviceID as AnyObject,
            "working_area_ref": address.workingArea_ref! as AnyObject,
            "time_of_service": (bookingInfo.time?.timeIntervalSince1970)! * 1000 as AnyObject,
            "working_hours": bookingInfo.hours as AnyObject,
            "price": Float(bookingInfo.price + materialPrice) as AnyObject,
            "asap": false as AnyObject,
            "address": addressq as AnyObject,
            "material_price": materialPrice as AnyObject
        ]
        
        return params
    }
}
