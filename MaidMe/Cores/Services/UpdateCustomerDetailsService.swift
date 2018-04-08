//
//  UpdateCustomerDetailsService.swift
//  MaidMe
//
//  Created by Viktor on4/13/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class UpdateCustomerDetailsService : RequestManager {
    
    override func request(_ method: HTTPMethod?, _ URLString: URLConvertible?, parameters: [String : AnyObject]?, encoding: ParameterEncoding?, headers: [String : String]?, completionHandler: @escaping (DataResponse<Any>) -> ()) {
       
            super.request(.post, "\(Configuration.serverUrl)\(Configuration.updateCustomerDetailsUrl)", parameters: parameters, encoding: JSONEncoding.default, headers: self.getAuthenticateHeader()) {
                response in
                completionHandler(response)
            }
        
    }
    
    func getParams(_ customer: Customer) -> [String: AnyObject] {
        return [
            "first_name": customer.firstName! as AnyObject,
            "last_name": customer.lastName! as AnyObject,
            "phone": customer.phone! as AnyObject,
            "default_area": (customer.defaultArea?.areaID == nil ? "" : customer.defaultArea!.areaID) as AnyObject
        ]
    }
    
}
