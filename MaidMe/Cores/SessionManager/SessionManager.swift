//
//  SessionManager.swift
//  Edgar
//
//  Created by Viktor on 2/1/16.
//  Copyright © 2016 smartlink. All rights reserved.
//

import UIKit
import SSKeychain

class SessionManager: NSObject {
    static let sharedInstance = SessionManager()
    var isLoggedIn: Bool = false
    var defaultAreaCustomer: String = ""
    
    func deleteLoginToken() {
        SSKeychain.deletePassword(forService: KeychainIdentifier.appService, account:  KeychainIdentifier.customerID)
        SSKeychain.deletePassword(forService: KeychainIdentifier.appService, account:  KeychainIdentifier.tokenID)
    }
}
