//
//  ForgotPasswordService.swift
//  MaidMe
//
//  Created by Viktor on5/18/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ForgotPasswordService: RequestManager {
    override func request(_ method: HTTPMethod? = nil,
        _ URLString: URLConvertible? = nil,
        parameters: [String : AnyObject]?,
        encoding: ParameterEncoding? = nil,
        headers: [String : String]? = nil,
        completionHandler: @escaping  (DataResponse<Any>) -> ()) {
            super.request(.post, "\(Configuration.serverUrl)\(Configuration.forgotPasswordUrl)", parameters: parameters, encoding: JSONEncoding.default, headers: self.getAuthenticateHeader()) {
                response in
                completionHandler(response)
            }
    }
    
    func getParams(_ email: String) -> [String: AnyObject] {
        return [
            "email": email as AnyObject
        ]
    }
}
