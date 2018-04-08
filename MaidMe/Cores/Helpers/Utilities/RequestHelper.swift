//
//  RequestHelper.swift
//  MaidMe
//
//  Created by Viktor on2/15/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit
import Reachability
import SwiftyJSON
import SSKeychain

class RequestHelper: NSObject {
    
    // MARK: - Check Internet connection
    
    class func isInternetConnectionFailed() -> Bool {
        do {
            let readchability: Reachability = (try Reachability())!
            let internetStatus = readchability.connection
            
            if internetStatus != .none {
                return false
            }
            else {
                return true
            }
        }
        catch _ {
            return false
        }
    }
    
    class func showNoInternetConnectionAlert(_ viewController: UIViewController) {
        let alert = UIAlertController(title: LocalizedStrings.noInternetConnectionTitle, message: LocalizedStrings.noInternetConnectionMessage, preferredStyle: .alert)
        let action = UIAlertAction(title: LocalizedStrings.okButton, style: UIAlertActionStyle.default, handler: nil)
        
        alert.addAction(action)
        
        DispatchQueue.main.async(execute: {
            viewController.present(alert, animated: true, completion: nil)
        })
    }
    
    class func saveLoginSuccessData(_ result: JSON?) {
        // Get the customer_id and token_id
        guard let body = result else {
            return
        }
		
        let customerID = body[APIKeys.customerID]
        let userTokenId = body[APIKeys.tokenID]
        
        if customerID != nil {
            SSKeychain.setPassword(customerID.stringValue, forService: KeychainIdentifier.appService, account: KeychainIdentifier.customerID)
        }
        
        if userTokenId != nil {
            SSKeychain.setPassword(userTokenId.stringValue, forService: KeychainIdentifier.appService, account: KeychainIdentifier.tokenID)
        }
        
        SessionManager.sharedInstance.isLoggedIn = true
    }
}
