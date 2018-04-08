//
//  TermsAndConditions.swift
//  MaidMe
//
//  Created by Viktor on5/18/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON



class TermsAndConditions: BaseTableViewController,UIGestureRecognizerDelegate {

    @IBOutlet weak var termsTextView: UITextView!
    
    @IBOutlet weak var termsTextViewBottomLayout: NSLayoutConstraint!
    let fetchTermsConditions = GetTermsAndConditionsService()
    let createTokenCard = CreateNewTokenCardService()
    var isMovedFromLogin: Bool = false
    var isMoveFromRegister: Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchTermsAndConditionsRequest()
		
		if let cachedTS :String = UserDefaults.standard.string(forKey: "TCCache") {
			do {
				let string = "<span style=\"font-family: SFUIDisplay-Regular; font-size: 15\">\(cachedTS)</span>"
                let attributedString = try NSAttributedString(data: string.data(using: String.Encoding.unicode)!, options: [.documentType: NSAttributedString.DocumentType.html,.characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
				termsTextView.attributedText = attributedString
				self.tableView.reloadData()
				
			} catch _ {
				print("Error on parsing")
			}
		}
		
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.customBackButton()
        if isMoveFromRegister {
            termsTextViewBottomLayout.constant = 15
        }
        tableView.alwaysBounceVertical = false
        self.navigationController?.interactivePopGestureRecognizer!.delegate = self
        self.navigationController?.navigationBar.isHidden = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.tableView.frame.height
    }

    // MARK: - API
    
    func fetchTermsAndConditionsRequest() {
        sendRequest(nil, request: fetchTermsConditions, requestType: .fetchTermsConditions, isSetLoadingView: true, view: nil)
    }
    
    func sendRequest(_ parameters: [String: AnyObject]?,
        request: RequestManager,
        requestType: RequestType,
        isSetLoadingView: Bool, view: UIView?) {
            // Check for internet connection
            if RequestHelper.isInternetConnectionFailed() && UserDefaults.standard.value(forKey: "TCCache") == nil{
                RequestHelper.showNoInternetConnectionAlert(self)
                return
            }
            
            // Set loading view center
            if isSetLoadingView && view != nil {
                self.setRequestLoadingViewCenter1(view!)
            }
			if UserDefaults.standard.value(forKey: "TCCache") == nil {
				self.startLoadingView()
			}
		
            
            request.request(parameters: parameters) {
                [weak self] response in
                
                if let strongSelf = self {
                    strongSelf.handleAPIResponse()
                    strongSelf.handleResponse(response, requestType: requestType)
                }
            }
    }
    
    func handleResponse(_ response: DataResponse<Any>, requestType: RequestType) {
        let result = ResponseHandler.responseHandling(response)
        
        if result.messageCode != MessageCode.success {
            // Show alert
            handleResponseError(result.messageCode, title: LocalizedStrings.internalErrorTitle, message: result.messageInfo, requestType: requestType)
            
            return
        }
        
        setUserInteraction(true)
        
        if requestType == .fetchTermsConditions {
            handleFetchTCResponse(result, requestType: .fetchTermsConditions)
        }
    }
    
    func handleFetchTCResponse(_ result: ResponseObject, requestType: RequestType) {
        guard let list = result.body else {
            return
        }
		
		UserDefaults.standard.setValue(list.stringValue, forKey: "TCCache")
		
        do {
            let string = "<span style=\"font-family: SFUIDisplay-Regular; font-size: 15\">\(list.stringValue)</span>"
            
            
            let attributedString = try NSAttributedString(data: string.data(using: String.Encoding.unicode)!, options: [.documentType: NSAttributedString.DocumentType.html,.characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
            termsTextView.attributedText = attributedString
            self.tableView.reloadData()
            
        } catch _ {
            print("Error on parsing")
        }
    }
    
    // MARK: - Handle UIAlertViewAction
    
    override func handleTryAgainTimeoutAction(_ requestType: RequestType) {
        if requestType == .fetchTermsConditions {
            self.fetchTermsAndConditionsRequest()
        }
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}
