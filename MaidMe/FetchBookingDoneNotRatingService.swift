//
//  FetchBookingDoneNotRatingService.swift
//  MaidMe
//
//  Created by LuanVo on 5/5/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class FetchBookingDoneNotRatingService: RequestManager {
    
    override func request(_ method: HTTPMethod?, _ URLString: URLConvertible?, parameters: [String : AnyObject]?, encoding: ParameterEncoding?, headers: [String : String]?, completionHandler: @escaping (DataResponse<Any>) -> ()) {
        
        super.request(.get, "\(Configuration.serverUrl)\(Configuration.getBookingDoneNotRatingUrl)", parameters: parameters, encoding: JSONEncoding.default, headers: self.getAuthenticateHeader()) {
            response in
            completionHandler(response)
        }
    }
    
    
    
    func getBookingList(_ list: JSON) -> ([Rating]) {
        var bookingList = [Rating]()
        
        for (_, dic) in list {
            let item = Rating(ratingDic: dic)
            if item.ratingID == nil {
                continue
            }
            
            bookingList.append(item)
        }
        
        return bookingList
    }
}



