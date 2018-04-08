//
//  FetchServiceTypeService.swift
//  MaidMe
//
//  Created by Viktor on3/15/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class FetchServiceTypeService: RequestManager {
    
    override func request(_ method: HTTPMethod? = nil, _ URLString: URLConvertible?  = nil, parameters: [String : AnyObject]?, encoding: ParameterEncoding?  = nil, headers: [String : String]?  = nil, completionHandler: @escaping (DataResponse<Any>) -> ()) {
        
            super.request(.get, "\(Configuration.serverUrl)\(Configuration.serviceTypesUrl)", parameters: parameters, encoding: JSONEncoding.default, headers: self.getAuthenticateHeader()) {
                response in
                completionHandler(response)
            }
        
    }
}

