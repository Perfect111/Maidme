//
//  RebookGetTimeOptionsService.swift
//  MaidMe
//
//  Created by Viktor on5/24/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class RebookGetTimeOptionsService: RequestManager {
    override func request(_ method: HTTPMethod?, _ URLString: URLConvertible?, parameters: [String : AnyObject]?, encoding: ParameterEncoding?, headers: [String : String]?, completionHandler: @escaping (DataResponse<Any>) -> ()) {
       
            super.request(.post, "\(Configuration.serverUrl)\(Configuration.rebookingGetTimeOptionsUrl)", parameters: parameters, encoding: JSONEncoding.default, headers: self.getAuthenticateHeader()) {
                response in
                completionHandler(response)
            }
        
    }
    
    func getParams(_ booking: Booking,addressID: String?) -> [String: AnyObject] {
        return [
            "maid_id": booking.workerID! as AnyObject,
            "service_id": booking.service!.serviceID as AnyObject,
            "address_id": (addressID == nil ? "" : addressID)! as AnyObject,
            "working_hours": booking.hours as AnyObject
        ]
    }
}
