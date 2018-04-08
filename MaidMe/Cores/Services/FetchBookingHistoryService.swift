//
//  FetchBookingHistoryService.swift
//  MaidMe
//
//  Created by Viktor on5/13/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class FetchBookingHistoryService : RequestManager {
    
    override func request(_ method: HTTPMethod?, _ URLString: URLConvertible?, parameters: [String : AnyObject]?, encoding: ParameterEncoding?, headers: [String : String]?, completionHandler: @escaping (DataResponse<Any>) -> ()) {
       
            super.request(.post, "\(Configuration.serverUrl)\(Configuration.bookingHistoryUrl)", parameters: parameters, encoding: JSONEncoding.default, headers: self.getAuthenticateHeader()) {
                response in
                completionHandler(response)
            }
        
    }
    
    func getParams(_ count: Int, limit: Int) -> [String: AnyObject] {
        return [
            "load_time": count as AnyObject,
            "items_per_load": limit as AnyObject
        ]
    }
    
    func getBookingList(_ list: JSON) -> (total: Int, bookings: [Booking]) {
        var bookingList = [Booking]()
        
        let commentDic = list["bookings"]
        
        for (_, dic) in commentDic {
            let item = Booking(bookingDic: dic)
            if item.bookingID == nil {
                continue
            }
            
            bookingList.append(item)
        }
        
        return (list["total"].intValue, bookingList)
    }
}
