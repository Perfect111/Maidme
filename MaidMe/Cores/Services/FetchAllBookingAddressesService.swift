//
//  FetchAllBookingAddressesService.swift
//  MaidMe
//
//  Created by Viktor on4/6/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class FetchAllBookingAddressesService: RequestManager {
    
    override func request(_ method: HTTPMethod?, _ URLString: URLConvertible?, parameters: [String : AnyObject]?, encoding: ParameterEncoding?, headers: [String : String]?, completionHandler: @escaping (DataResponse<Any>) -> ()) {
       
            //print(parameters)
            super.request(.get, "\(Configuration.serverUrl)\(Configuration.fetchAllBookingAddressesUrl)", encoding: JSONEncoding.default, headers: self.getAuthenticateHeader()) {
                response in
                completionHandler(response)
            }
        
    }
    
    func getAddressList(_ list: JSON) -> [Address] {
        var addressList = [Address]()
        
        for (_, dic) in list {
            let item = Address(addressDic: dic)
            if item.addressID == nil {
                continue
            }
            
            addressList.append(item)
        }
        
        return addressList
    }
}
