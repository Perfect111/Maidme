//
//  GetSearchOptionRebookingService.swift
//  MaidMe
//
//  Created by Viktor on 1/16/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class GetSearchOptionRebookingService: RequestManager {
    
    override func request(_ method: HTTPMethod?, _ URLString: URLConvertible?, parameters: [String : AnyObject]?, encoding: ParameterEncoding?, headers: [String : String]?, completionHandler: @escaping (DataResponse<Any>) -> ()) {
        
        super.request(.post, "\(Configuration.serverUrl)/api/bookings/rebook/getOption", parameters: parameters, encoding: JSONEncoding.default, headers: self.getAuthenticateHeader()) { (response) in
            completionHandler(response)
        }
        
        
    }
    
    
    
    
    func getSearchOptionsForRebookingParams(_ booking: Booking) -> [String: String] {
        return ["booking_id" : booking.bookingID == nil ? "" : booking.bookingID!]
    }
    
    func getAddressList(_ list: JSON) -> [Address] {
        var addressList = [Address]()
        
        for (_, dic) in list["addresses"] {
            let item = Address(addressDic: dic)
            if item.addressID == nil {
                continue
            }
            
            addressList.append(item)
        }
        
        return addressList
    }
    
    func getServiceList(_ list: JSON ) -> [WorkingService] {
        var serviceList = [WorkingService]()
        for (_,dic) in list["services"] {
            let item = WorkingService(serviceDic: dic)
            if item.serviceID == nil {
                continue
            }
            serviceList.append(item)
        }
        return serviceList
        
    }
    
}
