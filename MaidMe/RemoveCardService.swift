//
//  RemoveCardService.swift
//  MaidMe
//
//  Created by Viktor on 1/9/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON


class RemoveCardService: RequestManager {
    override func request(_ method: HTTPMethod?, _ URLString: URLConvertible?, parameters: [String : AnyObject]?, encoding: ParameterEncoding?, headers: [String : String]?, completionHandler: @escaping (DataResponse<Any>) -> ()) {
               super.request(.post, "\(Configuration.serverUrl)\(Configuration.removeCardUrl)",parameters: parameters, encoding: JSONEncoding.default, headers: self.getAuthenticateHeader()) {
                response in
                completionHandler(response)
            }
        }
    
    
    
    
    func getRemoveCardParams(_ cardRemove: Card?) -> [String:String] {
        return [
            "id" : (cardRemove?.cardID)!,
            "card_id": (cardRemove?.cardPaymentID)!,
        ]
    }
}
