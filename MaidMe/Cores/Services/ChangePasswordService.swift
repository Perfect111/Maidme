//
//  ChangePasswordService.swift
//  MaidMe
//
//  Created by Viktor on4/13/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ChangePasswordService : RequestManager {
    
    override func request(_ method: HTTPMethod? = nil,
        _ URLString: URLConvertible? = nil,
        parameters: [String : AnyObject]?,
        encoding: ParameterEncoding? = nil,
        headers: [String : String]? = nil,
        completionHandler: @escaping (DataResponse<Any>) -> ()) {
            super.request(.post, "\(Configuration.serverUrl)\(Configuration.updateCustomerPasswordUrl)", parameters: parameters, encoding: JSONEncoding.default, headers: self.getAuthenticateHeader()) {
                response in
                completionHandler(response)
            }
    }
    
    func getParams(_ currentPass: String, newPass: String) -> [String: AnyObject] {
        return [
            "current_password": currentPass as AnyObject,
            "new_password": newPass as AnyObject
        ]
    }
    
}
