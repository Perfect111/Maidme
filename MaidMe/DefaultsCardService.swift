//
//  DefaultsCardService.swift
//  MaidMe
//
//  Created by Viktor on 1/9/17.
//  Copyright © 2017 Mac. All rights reserved.
//
import UIKit
import Alamofire
import SwiftyJSON


class DefaultCardService: RequestManager {
    override func request(_ method: HTTPMethod?, _ URLString: URLConvertible?, parameters: [String : AnyObject]?, encoding: ParameterEncoding?, headers: [String : String]?, completionHandler: @escaping (DataResponse<Any>) -> ()) {
        
            super.request(.post, "\(Configuration.serverUrl)\(Configuration.setDefaultCardUrl)",parameters: parameters, encoding: JSONEncoding.default, headers: self.getAuthenticateHeader()) {
                response in
                completionHandler(response)
            }
        
    }
    func getDefaultCardParams(_ card: Card?) -> [String:String] {
        return [
            "card_id": (card!.cardPaymentID)!,
        ]
    }
}

