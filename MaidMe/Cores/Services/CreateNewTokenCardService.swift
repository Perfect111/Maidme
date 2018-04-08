//
//  CreateNewTokenCardService.swift
//  MaidMe
//
//  Created by Viktor on3/29/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SSKeychain


class CreateNewTokenCardService: RequestManager {
    
    override func request(_ method: HTTPMethod?, _ URLString: URLConvertible?, parameters: [String : AnyObject]?, encoding: ParameterEncoding?, headers: [String : String]?, completionHandler: @escaping (DataResponse<Any>) -> ()) {
        
            super.request(.post, "\(Configuration.startSDKUrl)", parameters: parameters, encoding: JSONEncoding.default, headers: self.authenticatedHeader()) {
                response in
                completionHandler(response)
            }
        
    }
    
    func getCardTokenParams(_ selectedCard: Card?, newCard: Card?) -> [String: String] {
        let card = (selectedCard == nil ? newCard : selectedCard)
        
        return [
            "number": card!.number!,
            "exp_month": "\(card!.expiryMonth)",
            "exp_year": "\(card!.expiryYear)",
            "cvc": card!.cvv!,
            "name": "",
        ]
    }
    
    func authenticatedHeader() -> [String: String] {
        var key = ""
        
        if let publicKey = SSKeychain.password(forService: KeychainIdentifier.appService, account: KeychainIdentifier.payfortkey) {
            key = publicKey
        }
        
        /*if let data = key.dataUsingEncoding(NSUTF8StringEncoding) {
            encryptedKey = data.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
        }*/
        
        let header = [
            Parameters.contentType: Parameters.jsonContentType,
            Parameters.authorization: Parameters.basic + key]
        
        return header
    }
    
   /* func startCard(_ card: Card) -> StartCard {
        return try! StartCard(cardholder: "maidme",
                              number: card.number!,
                              cvc: card.cvv!,
                              expirationMonth: card.expiryMonth,
                              expirationYear: card.expiryYear)
    }
    
    func getCardToken(_ card: StartCard, amount: NSNumber, completionHandler: @escaping (String?, NSError?) -> Void) {

        let start = Start(apiKey: PaymentKey.payfortApiKey)

        start.createToken(for: card, amount: amount.intValue * 100, currency: "AED",
                                 successBlock: { (token) in
                                    completionHandler(token.tokenId, nil)
            },
                                 errorBlock: { (error) in
                                    completionHandler(nil, error as NSError)
            },cancel: {})
        
    }*/
}
