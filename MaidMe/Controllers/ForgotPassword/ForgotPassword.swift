//
//  ForgotPassword.swift
//  MaidMe
//
//  Created by Viktor on5/18/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ForgotPassword: BaseTableViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var sendButton: UIBarButtonItem!
    
    var forgotPasswordAPI = ForgotPasswordService()
    var delegate: RegisterTableViewControllerDelegate?
    var messageCode: MessageCode?
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set place holder font
        StringHelper.setPlaceHolderFont([emailTextField, emailTextField], font: CustomFont.quicksanRegular, fontsize: 16.0)
        checkFullFillRequiredFields()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        delegate?.didDismissRegisterTableViewController()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - IBActions
    
    @IBAction func onTextFieldEditingChangedAction(_ sender: AnyObject) {
        checkFullFillRequiredFields()
    }
    
    fileprivate func checkFullFillRequiredFields() {
        let isFullFilled = Validation.isFullFillRequiredFields([emailTextField])
        sendButton.isEnabled = isFullFilled
    }
    
    @IBAction func onSendResetPasswordAction(_ sender: AnyObject) {
        // Check validation
        let validationResult = isValidData()
        
        if !validationResult.isValid {
            // Show invalid alert
            showAlertView(validationResult.title, message: validationResult.message, requestType: nil)
            return
        }
        
        // Send forgot password request
        forgotPasswordRequest()
    }
    
    // MARK: - Validation
    
    fileprivate func isValidData() -> (isValid: Bool, title: String, message: String) {
        if !Validation.isValidRegex(emailTextField.text!, expression: ValidationExpression.email) {
            return (false, LocalizedStrings.invalidEmailTitle, LocalizedStrings.invalidEmailMessage)
        }
        
        return (true, "", "")
    }
    
    // MARK: - API
    
    func forgotPasswordRequest() {
        dismissKeyboard()
        let params = forgotPasswordAPI.getParams(emailTextField.text!)
        sendRequest(params, request: forgotPasswordAPI, requestType: .forgotPassword, isSetLoadingView: true, view: nil)
    }
    
    func sendRequest(_ parameters: [String: AnyObject]?,
        request: RequestManager,
        requestType: RequestType,
        isSetLoadingView: Bool, view: UIView?) {
            // Check for internet connection
            if RequestHelper.isInternetConnectionFailed() {
                RequestHelper.showNoInternetConnectionAlert(self)
                return
            }
            
            // Set loading view center
            if isSetLoadingView && view != nil {
                self.setRequestLoadingViewCenter1(view!)
            }
            self.startLoadingView()
            
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
        messageCode = result.messageCode
        
        if result.messageCode != MessageCode.success {
            // Show alert
            handleResponseError(result.messageCode, title: LocalizedStrings.internalErrorTitle, message: result.messageInfo, requestType: requestType)
            
            return
        }
        
        setUserInteraction(true)
        
        if requestType == .forgotPassword {
            handleForgotPasswordResponse(result, requestType: .forgotPassword)
        }
    }
    
    func handleForgotPasswordResponse(_ result: ResponseObject, requestType: RequestType) {
        guard let _ = result.body else {
            showAlertView(LocalizedStrings.internalErrorTitle, message: LocalizedStrings.internalErrorMessage, requestType: nil)
            return
        }
        
        showAlertView(LocalizedStrings.updateSuccessTitle, message: LocalizedStrings.resetSuccessMessage, requestType: .forgotPassword)
    }
    
    // MARK: - Handle UIAlertViewAction
    
    override func handleTryAgainTimeoutAction(_ requestType: RequestType) {
        if requestType == .forgotPassword {
            self.forgotPasswordRequest()
        }
    }
    
    override func handleAlertViewAction(_ requestType: RequestType?) {
        if requestType == .forgotPassword && messageCode == .success {
            self.performSegue(withIdentifier: SegueIdentifiers.backFromForgotPasswordSegue, sender: self)
        }
    }
}
