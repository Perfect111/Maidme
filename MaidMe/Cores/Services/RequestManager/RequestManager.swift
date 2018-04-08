//
//  RequestManager.swift
//  MaidMe
//
//  Created by Viktor on2/15/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit
import Alamofire
import SSKeychain

class RequestManager: NSObject {
    //static let sharedInstance = RequestManager()
    
    var alamofireManager : Alamofire.SessionManager?
    
    func request1(_ method: HTTPMethod,
                  _ URLString: URLConvertible,
                    parameters: [String: AnyObject]? = nil,
                    encoding: ParameterEncoding ,
                    headers: [String: String]? = nil,
                    completionHandler: @escaping (DataResponse<Any>) -> ()) {
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 15
        configuration.timeoutIntervalForResource = 15
        
        self.alamofireManager = Alamofire.SessionManager(configuration: configuration)
        self.alamofireManager!.request(URLString, method: method, parameters: parameters, encoding: encoding, headers: headers)
            .responseJSON{ (response: DataResponse) -> Void in
                completionHandler(response)
        }
    }
    
    func request(_ method: HTTPMethod? = nil,
                 _ URLString: URLConvertible? = nil,
                 parameters: [String : AnyObject]? = nil,
                 encoding: ParameterEncoding? = nil,
                 headers: [String : String]? = nil,
                 completionHandler: @escaping (DataResponse<Any>) -> ()) {
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 15
        configuration.timeoutIntervalForResource = 15
        
        self.alamofireManager = Alamofire.SessionManager(configuration: configuration)
        self.alamofireManager!.request(URLString!, method: method!, parameters: parameters, encoding: encoding!, headers: headers)
            .responseJSON{ (response: DataResponse) -> Void in
                completionHandler(response)
        }
    }
    
    /**
     Get authenticated header for the request
     
     - returns: header
     */
    func getAuthenticateHeader() -> [String: String] {
        var customerID = ""
        var tokenID = ""
        
        if let token = SSKeychain.password(forService: KeychainIdentifier.appService, account: KeychainIdentifier.tokenID) {
            tokenID = token
        }
        if let customer = SSKeychain.password(forService: KeychainIdentifier.appService, account: KeychainIdentifier.customerID) {
            customerID = customer
        }
        var info: NSDictionary?
        if let path = Bundle.main.path(forResource: "Info", ofType: "plist") {
            info = NSDictionary(contentsOfFile: path)
        }
        
        var appVersion = ""
        if let dict = info {
            let version = dict["CFBundleShortVersionString"] as! String
            let build = dict["CFBundleVersion"] as! String
            appVersion = "\(version),\(build)"
        }
        
        let header = [
            Parameters.contentType: Parameters.jsonContentType,
            Parameters.customerID: customerID,
            Parameters.accessToken: tokenID,
            Parameters.appVersion: appVersion
        ]
        
        print(header)
        return header
    }
    
    static func getAuthenticateHeader() -> [String: String] {
        var customerID = ""
        var tokenID = ""
        
        if let token = SSKeychain.password(forService: KeychainIdentifier.appService, account: KeychainIdentifier.tokenID) {
            tokenID = token
        }
        if let customer = SSKeychain.password(forService: KeychainIdentifier.appService, account: KeychainIdentifier.customerID) {
            customerID = customer
        }

        var info: NSDictionary?
        if let path = Bundle.main.path(forResource: "Info", ofType: "plist") {
            info = NSDictionary(contentsOfFile: path)
        }
        
        var appVersion = ""
        if let dict = info {
            let version = dict["CFBundleShortVersionString"] as! String
            let build = dict["CFBundleVersion"] as! String
            appVersion = "\(version) \(build)"
        }
        
        let header = [
            Parameters.contentType: Parameters.jsonContentType,
            Parameters.customerID: customerID,
            Parameters.accessToken: tokenID,
            Parameters.appVersion: appVersion
        ]

        print(header)
        return header
    }
}

enum RequestType {
    case register
    case login
    case fetchWorkingArea
    case fetchServiceTypes
    case fetchAvailableWorker
    case createCardToken
    case createCustomerCard
    case lockABooking
    case fetchAllCard
    case createABooking
    case addNewBookingAddress
    case updateBookingAddress
    case fetchAllBookingAddresses
    case fetchCustomerDetails
    case updateCustomerDetails
    case changePassword
    case fetchAllUpcomingBookings
    case cancelBooking
    case clearLockedBooking
    case fetchBookingDoneNotRating
    case getRatingsAndComments
    case fetchBookingHistory
    case giveARatingComment
    case fetchTermsConditions
    case forgotPassword
    case rebookAMaid
    case getMinPeriodWorkingHour
    case createPayfortSDKToken
    
    case defaultCard
    case removeCards
    case removeAddress
    
    case fetchSugesstedWorker
    case getSearchOptionRebooking
    
    case payfortAuthorization
    case payfortPurchase
}
