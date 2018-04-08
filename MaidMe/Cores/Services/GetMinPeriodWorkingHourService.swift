//
//  GetMinPeriodWorkingHourService.swift
//  MaidMe
//
//  Created by Viktor on6/1/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class GetMinPeriodWorkingHourService: RequestManager {
    override func request(_ method: HTTPMethod?, _ URLString: URLConvertible?, parameters: [String : AnyObject]?, encoding: ParameterEncoding?, headers: [String : String]?, completionHandler: @escaping (DataResponse<Any>) -> ()) {
        
            super.request(.post, "\(Configuration.serverUrl)\(Configuration.minPeriodWorkingHourUrl)", parameters: parameters, encoding: JSONEncoding.default, headers: self.getAuthenticateHeader()) {
                response in
                completionHandler(response)
            }
        
    }
    
    func getParams(_ maidID: String) -> [String: AnyObject] {
        return [
            "maid_id": maidID as AnyObject
        ]
    }
}
