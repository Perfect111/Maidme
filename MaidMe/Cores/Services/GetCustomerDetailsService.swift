//
//  GetCustomerDetailsService.swift
//  MaidMe
//
//  Created by Viktor on4/13/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class GetCustomerDetailsService: RequestManager {
    
    override func request(_ method: HTTPMethod?, _ URLString: URLConvertible?, parameters: [String : AnyObject]?, encoding: ParameterEncoding?, headers: [String : String]?, completionHandler: @escaping (DataResponse<Any>) -> ()) {
      
            super.request(.get, "\(Configuration.serverUrl)\(Configuration.getCustomerDetailsUrl)", encoding: JSONEncoding.default, headers: self.getAuthenticateHeader()) {
                response in
                completionHandler(response)
            }
        }
    
}
