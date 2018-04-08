//
//  CreateCustomerCardService.swift
//  MaidMe
//
//  Created by Viktor on3/29/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class CreateCustomerCardService: RequestManager {

    override func request(_ method: HTTPMethod?, _ URLString: URLConvertible?, parameters: [String : AnyObject]?, encoding: ParameterEncoding?, headers: [String : String]?, completionHandler: @escaping (DataResponse<Any>) -> ()) {
        
            super.request(.post, "\(Configuration.serverUrl)\(Configuration.createCustomerCardUrl)", parameters: parameters, encoding: JSONEncoding.default, headers: self.getAuthenticateHeader()) {
                response in
                completionHandler(response)
            }
        
    }
    
    func getCustomerCardParams(_ paymentToken: String) -> [String: AnyObject] {
        return [
            "token_card": paymentToken as AnyObject,
            "default_card" : "false" as AnyObject,
            "country_code_name" : Locale.locales("United Arab Emirates") as AnyObject,
            "country_name" : "United Arab Emirates" as AnyObject,
        ]
    }
}
