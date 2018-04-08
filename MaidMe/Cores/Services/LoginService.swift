//
//  LoginService.swift
//  MaidMe
//
//  Created by Viktor on3/15/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SSKeychain

class LoginService: RequestManager {
    
    override func request(_ method: HTTPMethod? = nil, _ URLString: URLConvertible? = nil, parameters: [String : AnyObject]?, encoding: ParameterEncoding? = nil, headers: [String : String]? = nil, completionHandler: @escaping (DataResponse<Any>) -> ()) {
       
            //print(parameters)
            
            super.request(.post, "\(Configuration.serverUrl)\(Configuration.loginUrl)", parameters: parameters, encoding: JSONEncoding.default) {
                response in
                
                SSKeychain.setPassword(parameters!["password"] as! String, forService: KeychainIdentifier.appService, account: parameters!["email"] as! String)
                SSKeychain.setPassword(parameters!["email"] as! String, forService: KeychainIdentifier.appService, account: KeychainIdentifier.userName)
                if parameters!["decryptedPass"] != nil {
                    SSKeychain.setPassword(parameters!["decryptedPass"] as! String, forService: KeychainIdentifier.appService, account: KeychainIdentifier.password)
                }
                
                completionHandler(response)
                
            }
        }
    
}
