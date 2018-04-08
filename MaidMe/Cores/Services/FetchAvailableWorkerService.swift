//
//  AvailableWorkerService.swift
//  MaidMe
//
//  Created by Viktor on3/11/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class FetchAvailableWorkerService: RequestManager {
    
    override func request(_ method: HTTPMethod?, _ URLString: URLConvertible?, parameters: [String : AnyObject]?, encoding: ParameterEncoding?, headers: [String : String]?, completionHandler: @escaping (DataResponse<Any>) -> ()) {
       
            super.request(.post, "\(Configuration.serverUrl)\(Configuration.availableWorkerUrl)", parameters: parameters, encoding: JSONEncoding.default, headers: self.getAuthenticateHeader()) {
                response in
                completionHandler(response)
            }
        
    }
    
    func getWorkerList(_ list: JSON) -> [Worker] {
        var workerList = [Worker]()
        
        for (_, dic) in list {
            let item = Worker(workerDic: dic)
            if item.workerID == nil && item.firstName != nil {
                continue
            }
            
            workerList.append(item)
        }
        
        return workerList
    }
}
