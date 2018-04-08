//
//  ResponseHandler.swift
//  MaidMe
//
//  Created by Viktor on2/15/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ResponseHandler: NSObject {
    class func responseHandling(_ response: DataResponse<Any>) -> ResponseObject {
        var messageCode: MessageCode?
        
        switch response.result {
        case .success(let value):
            return ResponseObject(response: JSON(value))
            
        case .failure(let error):
            messageCode = MessageCode.code(error._code)
            return ResponseObject(messageCode: messageCode, messageInfo: (messageCode == .cannotConnectServer ? LocalizedStrings.connectToServerFailedMessage : nil))
        }
    }
    
    class func payfortResponseHandling(_ response: DataResponse<Any>) -> (error: MessageCode?, tokenID: String?){
        switch response.result {
        case .success(let value):
            let error = JSON(value)["error"]
            
            if error != nil {
                return (error: .invalidCardPayfort, tokenID: nil)
            }
            
            return (error: nil, tokenID: JSON(value)["id"].stringValue)
            
        case .failure(let error):
            print("Error:", error)
            var message = MessageCode.code(error._code)
            if message == nil {
                message = .errorCreatingCardPayfort
            }
            
            return (error: message, tokenID: nil)
        }
    }
    
    
    
    class func newPayfortResponseHandling(_ response: DataResponse<Any>) -> (error: MessageCode?, tokenID: String?){
        switch response.result {
        case .success(let value):
            let error = JSON(value)["error"]
            
            if error != nil {
                return (error: .invalidCardPayfort, tokenID: nil)
            }
            
            return (error: nil, tokenID: JSON(value)["sdk_token"].stringValue)
            
        case .failure(let error):
            print("Error:", error)
            var message = MessageCode.code(error._code)
            if message == nil {
                message = .errorCreatingCardPayfort
            }
            
            return (error: message, tokenID: nil)
        }
    }
    
}

class ResponseObject {
    var status: Int?
    var messageCode: MessageCode?
    var messageInfo: String?
    var body: JSON?
    
    init(status: Int? = nil,
        messageCode: MessageCode?,
        messageInfo: String?,
        body: JSON? = nil) {
            self.status = status
            self.messageCode = messageCode
            self.messageInfo = messageInfo
            self.body = body
    }
    
    init(response: JSON) {
        //print("Response: ", response)
        self.status = response["status"].intValue
        
        if let message = response["messageInfo"].string {
            self.messageInfo = message
        }
        else {
            self.messageInfo = LocalizedStrings.connectionFailedMessage
        }
        
        self.messageCode = MessageCode.code(response["messageCode"].intValue)
        self.body = response["body"]
    }
}

enum MessageCode {
    case success
    case existedAccount
    case notAvailableAccount
    case invalidEmailPass
    case addressExisted
    case addressNotFound
    case repeatedPassword
    case noServiceForArea
    case internalServerError
    case permissionDenied
    case validationError
    case timeout
    case cannotConnectServer
    case invalidCardPayfort
    case errorCreatingCardPayfort
    case unauthorize
    case maidNotFound
    case inactivateMaid
    case bookingNotFound
    case bookingTimeout
    case bookingConflict
    case invalidWorkingHours
    case bookingTimeInvalid
    case cannotCharge
    case paymentParamsInvalid
    case canGetTermsAndCondition
    case serviceTypeNotFound
    case passwordWasReset
    
    static func code(_ rawValue: Int?) -> MessageCode? {
        guard let code = rawValue else {
            return nil
        }
        
        switch(code) {
            case 200: return .success
            case 30001: return .existedAccount
            case 30002: return .notAvailableAccount
            case 30003: return .invalidEmailPass
            case 30004: return .addressExisted
            case 30005: return .addressNotFound
            case 30006: return .repeatedPassword
            case 90003: return .serviceTypeNotFound
            case 90006: return .noServiceForArea
            case 150001: return .internalServerError
            case 150002: return .permissionDenied
            case 150003: return .validationError
            case -1001: return .timeout
            case -1004: return .cannotConnectServer
            case 100002: return .maidNotFound
            case 100004: return .inactivateMaid
            case 110001: return .unauthorize
            case 110006: return .cannotCharge
            case 110007: return .paymentParamsInvalid
            case 120001: return .bookingNotFound
            case 120002: return .bookingTimeout
            case 120003: return .bookingConflict
            case 120007: return .invalidWorkingHours
            case 120006: return .bookingTimeInvalid
            case 160001: return .canGetTermsAndCondition
             case 30008: return .passwordWasReset
            default: return nil
        }
    }
}
