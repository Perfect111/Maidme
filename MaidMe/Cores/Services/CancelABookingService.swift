//
//  CancelABookingService.swift
//  MaidMe
//
//  Created by Viktor on4/20/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class CancelABookingService : RequestManager {
    
    override func request(_ method: HTTPMethod?, _ URLString: URLConvertible?, parameters: [String : AnyObject]?, encoding: ParameterEncoding?, headers: [String : String]?, completionHandler: @escaping (DataResponse<Any>) -> ()) {
       
            super.request(.post, "\(Configuration.serverUrl)\(Configuration.cancelABookingUrl)", parameters: parameters, encoding: JSONEncoding.default, headers: self.getAuthenticateHeader()) {
                response in
                completionHandler(response)
            
        }
    }
    
    func getParams(_ bookingID: String) -> [String: AnyObject] {
        return [
            "booking_id": bookingID as AnyObject
        ]
    }
}
