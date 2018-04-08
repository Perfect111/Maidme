//
//  RemoveAddressService.swift
//  MaidMe
//
//  Created by Vo Minh Long on 1/10/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import Alamofire

class RemoveAddress: RequestManager{
   
    override func request(_ method: HTTPMethod?, _ URLString: URLConvertible?, parameters: [String : AnyObject]?, encoding: ParameterEncoding?, headers: [String : String]?, completionHandler: @escaping (DataResponse<Any>) -> ()) {
       
            super.request(.post, "\(Configuration.serverUrl)\(Configuration.removeAddressUrl)",parameters: parameters, encoding: JSONEncoding.default, headers: self.getAuthenticateHeader()) {
                response in
                completionHandler(response)
            }
        
    }
    func getRemoveAddressParams(_ addressRemove: Address?) -> [String:String] {
    return [
        "address_id" : (addressRemove?.addressID)!
        ]
    }
}
