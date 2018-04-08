//
//  CreatePayfortSdkService.swift
//  MaidMe
//
//  Created by 123 on 12/22/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SSKeychain

class CreatePayfortSdkService: RequestManager {
    
    override func request(_ method: HTTPMethod? = nil, _ URLString: URLConvertible? = nil, parameters: [String : AnyObject]?, encoding: ParameterEncoding? = nil, headers: [String : String]? = nil, completionHandler: @escaping (DataResponse<Any>) -> ()) {
       
            
            super.request(.post, "\(Configuration.payfortUrl)", parameters: parameters, encoding: JSONEncoding.default) {
                response in
                
                print(Configuration.payfortUrl)
                completionHandler(response)
                
            }
        
    }
    
    
    func getSdkTokenParams(_ payfortToken: PayfortSdkToken) -> [String: AnyObject] {
        return [
            "service_command": (payfortToken.service_command == nil ? "" : payfortToken.service_command! ) as AnyObject,
            "access_code": (payfortToken.access_code == nil ? "" : payfortToken.access_code!) as AnyObject,
            "merchant_identifier": (payfortToken.merchant_identifier == nil ? "" : payfortToken.merchant_identifier!) as AnyObject,
            "language": (payfortToken.language == nil ? "" : payfortToken.language!) as AnyObject,
            "device_id": (payfortToken.device_id == nil ? "" : payfortToken.device_id!) as AnyObject,
            "signature": (payfortToken.signature == nil ? "" : payfortToken.signature!) as AnyObject,

        ]
    }
    
    func authenticatedHeader() -> [String: String] {
        
        let header = [
            Parameters.contentType: Parameters.jsonContentType
            ]
        
        return header
    }
    
    
    func sendRequestToPayFort(_ requestData: PayfortRequest, requestType: RequestType, amount: NSNumber, currentVC: UIViewController, completionHandler: @escaping (NSDictionary?, String?) -> Void){

        let request = NSMutableDictionary.init(capacity: 30)
        let payFort = PayFortController.init(enviroment: KPayFortEnviromentSandBox)
        
        request.setValue(amount.intValue * 100 , forKey: "amount")
        request.setValue(requestData.command, forKey: "command")
        request.setValue(requestData.currency, forKey: "currency")
        request.setValue(requestData.customer_email, forKey: "customer_email")
        request.setValue(requestData.language, forKey: "language")
        request.setValue(requestData.merchant_reference, forKey: "merchant_reference")
        request.setValue(requestData.sdk_token , forKey: "sdk_token")
        
        payFort?.hideLoading = true;
        
        payFort?.callPayFort(withRequest: request, currentViewController: currentVC,
                                       success: { (requestDic, responseDic) in
                                        print("success")
                                        completionHandler(responseDic as! NSDictionary, "success")

                                        
            },
                                       canceled: { (requestDic, responseDic) in
                                        print("canceled")
                                        completionHandler(responseDic as! NSDictionary, "canceled")

            },
                                       faild: { (requestDic, responseDic, message) in
                                        print("failed")
                                        completionHandler(responseDic as! NSDictionary, "failed")

        })
        
    }
    
    
    func sha256(_ data : Data) -> Data {
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        CC_SHA256((data as NSData).bytes, CC_LONG(data.count), &hash)
        let res = Data(bytes: UnsafePointer<UInt8>(hash), count: Int(CC_SHA256_DIGEST_LENGTH))
        return res
    }
    
    
    func getSignatureStr(_ newToken: PayfortSdkToken) -> String {
        
        var signature = Configuration.requestPhrase + "access_code=" + newToken.access_code! + "device_id=" + newToken.device_id! + "language=" + newToken.language!
        signature += "merchant_identifier=" + newToken.merchant_identifier! + "service_command=SDK_TOKEN" + Configuration.requestPhrase
        
        return sha256(signature.data(using: String.Encoding.utf8)! as Data).toHexString() 
        
    }
  
}
