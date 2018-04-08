//
//  FetchAllCardsService.swift
//  MaidMe
//
//  Created by Viktor on4/1/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class FetchAllCardsService: RequestManager {
    
    override func request(_ method: HTTPMethod?, _ URLString: URLConvertible?, parameters: [String : AnyObject]?, encoding: ParameterEncoding?, headers: [String : String]?, completionHandler: @escaping (DataResponse<Any>) -> ()) {
       
            super.request(.get, "\(Configuration.serverUrl)\(Configuration.fetchAllCardUrl)", encoding: JSONEncoding.default, headers: self.getAuthenticateHeader()) {
                response in
                completionHandler(response)
            }
        
    }
    
    func getCardList(_ list: JSON) -> [Card] {
        var cardList = [Card]()
        
        for (_, dic) in list {
            let item = Card(cardDic: dic)
            if item.cardPaymentID == nil && item.cardID != nil {
                continue
            }
            
            cardList.append(item)
        }
        
        return cardList
    }
}

