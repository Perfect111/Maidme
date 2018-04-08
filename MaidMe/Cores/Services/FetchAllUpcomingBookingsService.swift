//
//  FetchAllUpcomingBookingsService.swift
//  MaidMe
//
//  Created by Viktor on4/14/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class FetchAllUpcomingBookingsService: RequestManager {
    
    override func request(_ method: HTTPMethod?, _ URLString: URLConvertible?, parameters: [String : AnyObject]?, encoding: ParameterEncoding?, headers: [String : String]?, completionHandler: @escaping (DataResponse<Any>) -> ()) {
       
            super.request(.post, "\(Configuration.serverUrl)\(Configuration.fetchAllUpcomingBookingUrl)", parameters: parameters, encoding: JSONEncoding.default, headers: self.getAuthenticateHeader()) {
                response in
                completionHandler(response)
            }
        
    }
    
    func getParams() -> [String: AnyObject] {
        return [
            "from_date": Date().timeIntervalSince1970 * 1000 as AnyObject
        ]
    }
    
    func getBookingList(_ list: JSON) -> [Booking] {
        var bookingList = [Booking]()
        
        for (_, dic) in list {
            let item = Booking(bookingDic: dic)
            if item.bookingID == nil {
                continue
            }
            
            bookingList.append(item)
        }
        
        return bookingList
    }
}
