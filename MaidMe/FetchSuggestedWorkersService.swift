//
//  FetchSuggestedWorkersService.swift
//  MaidMe
//
//  Created by Viktor on 1/11/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON


class FetchSuggestedWorkerService: RequestManager {
    override func request(_ method: HTTPMethod?, _ URLString: URLConvertible?, parameters: [String : AnyObject]?, encoding: ParameterEncoding?, headers: [String : String]?, completionHandler: @escaping (DataResponse<Any>) -> ()) {
       
            super.request(.post, "\(Configuration.serverUrl)\(Configuration.suggetedWorker)", parameters: parameters, encoding: JSONEncoding.default, headers: self.getAuthenticateHeader()) {
                response in
                completionHandler(response)
            }
        
    }

    func getSuggesstedWorkerList(_ list: JSON) -> [SuggesstedWorker] {
        var suggesetdWorkerList = [SuggesstedWorker]()
        
        for (_, dic) in list {
            let item = SuggesstedWorker(suggesstedWorkerDic: dic)
            if item.workerID == nil && item.firstName != nil {
                continue
            }
            
            suggesetdWorkerList.append(item)
        }
        
        return suggesetdWorkerList
    }
    
    func getSuggestionWorkerParams(_ address : Address) -> [String: AnyObject] {
        return [ "address" : [
            "building_name": address.buildingName ?? "",
            "apartment_no": address.apartmentNo ?? "",
            "floor_no": address.floorNo ?? "",
            "zip_po": address.zipPO ?? "",
            "area": address.area,
            "city": address.city ?? "",
            "emirate": address.emirate,
            "additional_details": address.additionalDetails ?? "",
            "country": "United Arab Emirates",
            "working_area_ref": address.workingArea_ref,
            
            ] as AnyObject]
    
    }

}
