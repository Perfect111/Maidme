//
//  AddNewBookingAddressService.swift
//  MaidMe
//
//  Created by Viktor on4/6/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class AddNewBookingAddressService: RequestManager {
    
    override func request(_ method: HTTPMethod?, _ URLString: URLConvertible?, parameters: [String : AnyObject]?, encoding: ParameterEncoding?, headers: [String : String]?, completionHandler: @escaping (DataResponse<Any>) -> ()) {
       
            super.request(.post, "\(Configuration.serverUrl)\(Configuration.addNewBookingAddressUrl)", parameters: parameters, encoding: JSONEncoding.default, headers: self.getAuthenticateHeader()) {
                response in
                completionHandler(response)
            }
        
    }
    func getParams(_ address: Address, areaID: String?, isDefault: Bool = true) -> [String: AnyObject] {
        return [
            "building_name": address.buildingName as AnyObject,
            "apartment_no": address.apartmentNo as AnyObject,
            "floor_no": (address.floorNo == nil ? "" : address.floorNo!) as AnyObject,
            "street_no": (address.streetNo == nil ? "" : address.streetNo!) as AnyObject,
            "street_name": (address.streetName == nil ? "" : address.streetName!) as AnyObject,
            "zip_po": (address.zipPO == nil ? "" : address.zipPO!) as AnyObject,
            "area": address.area as AnyObject,
            "emirate": address.emirate as AnyObject,
            "city": address.city as AnyObject,
            "additional_details": (address.additionalDetails == nil ? "" : address.additionalDetails!) as AnyObject,
            "country": address.country as AnyObject,
            "working_area_ref":  areaID! as AnyObject,
            "latitude": address.latitude as AnyObject,
            "longitude": address.longitude as AnyObject,
            "is_default" : isDefault as AnyObject
        ]
    }
}
