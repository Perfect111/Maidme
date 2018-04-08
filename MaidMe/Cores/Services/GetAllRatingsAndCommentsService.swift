//
//  GetAllRatingsAndCommentsService.swift
//  MaidMe
//
//  Created by Viktor on5/11/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class GetAllRatingsAndCommentsService : RequestManager {
    
    override func request(_ method: HTTPMethod? = nil,
        _ URLString: URLConvertible? = nil,
        parameters: [String : AnyObject]?,
        encoding: ParameterEncoding? = nil,
        headers: [String : String]? = nil,
        completionHandler: @escaping (DataResponse<Any>) -> ()) {
            super.request(.post, "\(Configuration.serverUrl)\(Configuration.getRatingsAndCommentsUrl)", parameters: parameters, encoding: JSONEncoding.default, headers: self.getAuthenticateHeader()) {
                response in
                completionHandler(response)
            }
    }
    
    func getParams(_ maidID: String, fromDate: Double, limit: Int) -> [String: AnyObject] {
        return [
            "maid_id": maidID as AnyObject,
            "from_date": fromDate as AnyObject, //NSDate().timeIntervalSince1970 * 1000,//"\(fromDate)",
            "limit": limit as AnyObject
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
