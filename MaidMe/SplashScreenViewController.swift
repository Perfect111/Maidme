//
//  SplashScreenViewController.swift
//  MaidMe
//
//  Created by Viktor on 1/18/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SSKeychain
import SDVersion

class SplashScreenViewController: BaseViewController {
    var email: String?
    var pass:String?
    var isAutoLogin: Bool = true
    let loginAPI = LoginService()
    var messageCode: MessageCode?
    let fetchAllAddresses = FetchAllBookingAddressesService()
    var addressList = [Address]()
    var selectedAddress: Address?
    
    
    
	@IBOutlet var activityLoader: UIActivityIndicatorView!
	@IBOutlet var backgroundImageView: UIImageView!
	@IBOutlet var logoImageView: UIImageView!
	
    override func viewDidLoad() {
        super.viewDidLoad()
        if let account = SSKeychain.password(forService: KeychainIdentifier.appService, account: KeychainIdentifier.userName) {
            email = account
        }
        if let password = SSKeychain.password(forService: KeychainIdentifier.appService, account: KeychainIdentifier.password) {
            pass = password
        }
        if email != nil || pass != nil{
            loginAuto()
        }
        else {
            if email == nil || pass == nil {
                pushtoWelcomeScreen()
            }
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    func loginAuto() {
        var userName: String?
        var pass: String?
        
        if let account = SSKeychain.password(forService: KeychainIdentifier.appService, account: KeychainIdentifier.userName) {
            userName = account
        }
		
        if let password = SSKeychain.password(forService: KeychainIdentifier.appService, account: KeychainIdentifier.password) {
            pass = password
        }
        if isAutoLogin {
            onLoginAction()
        }
    }
    func onLoginAction(){
        let validationResult = isValidData()
        
        if !validationResult.isValid {
            // Show invalid alert
//            showAlertView(validationResult.title, message: validationResult.message, requestType: nil)
			pushtoWelcomeScreen()
            return
        }
        
        // Send request to server.
        sendLoginRequest()
        
    }
    fileprivate func isValidData() -> (isValid: Bool, title: String, message: String) {
        if !Validation.isValidRegex(email!, expression: ValidationExpression.email) {
            return (false, LocalizedStrings.invalidEmailTitle, LocalizedStrings.invalidEmailMessage)
        }
        
        if !Validation.isValidLength(pass!, minLength: 6, maxLength: 45) {
            return (false, LocalizedStrings.invalidPasswordTitle, LocalizedStrings.invalidPasswordMessage)
        }
        return (true, "", "")
    }
    func sendLoginRequest() {
        // Check for internet connection
        if RequestHelper.isInternetConnectionFailed() {
            //  RequestHelper.showNoInternetConnectionAlert(self)
            let alertController = UIAlertController(title: LocalizedStrings.noInternetConnectionTitle, message: LocalizedStrings.noInternetConnectionMessage, preferredStyle: .alert)
            
            // Create the actions
            let okAction = UIAlertAction(title: "Retry", style: UIAlertActionStyle.default) {
                UIAlertAction in
                self.sendLoginRequest()
                
            }
            alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: { (alertController) -> Void in
                self.pushtoWelcomeScreen()
            }))
            // Add the actions
            alertController.addAction(okAction)
            //  alertController.addAction(cancelAction)
            
            // Present the controller
            self.present(alertController, animated: true, completion: nil)
            return
        }
        
        // Set loading view center
        // setRequestLoadingViewCenter(loginButton)
        
        let parameters = getParams()
		
		startSpecialAnimation()
//		activityLoader.startAnimating()
		
        loginAPI.request(parameters: parameters as [String : AnyObject]) {
            [weak self] response in
            
            if let strongSelf = self {
                strongSelf.handleResponse(response)
                strongSelf.handleAPIResponse()
            }
        }
    }
	
	let rectShape = CAShapeLayer()
	func startSpecialAnimation() {
		var bounds = CGRect(x: 0, y: 0, width: 100, height: 100)
		bounds = logoImageView.bounds
		var treshold:CGFloat = 5.0
		if SDiOSVersion.deviceSize() == .Screen4Dot7inch {
			treshold = -1.6
		}else if SDiOSVersion.deviceSize() == .Screen4inch {
			treshold = -12.4
		}
		bounds.size = CGSize(width: logoImageView.frame.size.width+treshold, height: logoImageView.frame.size.height+treshold)
		rectShape.bounds = bounds
		rectShape.position = view.center
		rectShape.cornerRadius = 18
		view.layer.addSublayer(rectShape)
		rectShape.path = UIBezierPath(roundedRect: rectShape.bounds, cornerRadius: 10).cgPath
		rectShape.lineWidth = 4
		rectShape.strokeColor = UIColor.white.cgColor
		rectShape.fillColor = UIColor.clear.cgColor
		rectShape.strokeStart = 0
		rectShape.strokeEnd = 0.5
		let start = CABasicAnimation(keyPath: "strokeStart")
		start.toValue = 0.7
		let end = CABasicAnimation(keyPath: "strokeEnd")
		end.toValue = 1
		let group = CAAnimationGroup()
		group.animations = [start, end]
		group.duration = 1.5
		group.autoreverses = true
		group.repeatCount = HUGE // repeat forver
		rectShape.add(group, forKey: nil)
	}

	func stopSpecialAnimation() {
		let fadeAnimation = CAKeyframeAnimation(keyPath:"opacity")
		fadeAnimation.duration = 1.0
		fadeAnimation.values = [1.0, 0.0]
		fadeAnimation.isRemovedOnCompletion = false
		fadeAnimation.fillMode = kCAFillModeForwards
		rectShape.add(fadeAnimation, forKey:"animateOpacity")
		rectShape.opacity = 0.0
	}
	
	func getParams() -> [String: String] {
        let email1 = email
        let pass1 = StringHelper.encryptStringsha256(pass!) // Encrypt password
        
        return ["email": email1!,
                "password": pass1]
    }
    func handleResponse(_ response: DataResponse<Any>) {
        let result = ResponseHandler.responseHandling(response)
        
        if result.messageCode != MessageCode.success {
            // Show alert
            //handleResponseError(result.messageCode, title: LocalizedStrings.loginFailedTitle, message: result.messageInfo, requestType: .Login)
            //if result.messageInfo == MessageCode.InvalidEmailPass
            let alertController = UIAlertController(title: LocalizedStrings.loginFailedTitle, message: result.messageInfo, preferredStyle: .alert)
            
            // Create the actions
            let okAction = UIAlertAction(title: "Retry", style: UIAlertActionStyle.default) {
                UIAlertAction in
                self.sendLoginRequest()
                
            }
            alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: { (alertController) -> Void in
                self.pushtoWelcomeScreen()
            }))
            // Add the actions
            alertController.addAction(okAction)
            //  alertController.addAction(cancelAction)
            
            // Present the controller
            self.present(alertController, animated: true, completion: nil)
            if let error = result.messageCode {
                messageCode = error
            }
            return
        }
        
        // Login successful
        RequestHelper.saveLoginSuccessData(result.body)
        fetchAllBookingAddressesRequest()
    }
    
    func fetchAllBookingAddressesRequest() {
        sendRequest(nil, request: fetchAllAddresses, requestType: .fetchAllBookingAddresses, isSetLoadingView: false)
    }
    func handleFetchAllBookingAddressesResponse(_ result: ResponseObject, requestType: RequestType) {
		activityLoader.stopAnimating()
        guard let list = result.body else {
            return
        }
        addressList = fetchAllAddresses.getAddressList(list)
        
        for address in addressList {
            if (address.isDefault == true) {
                self.navTitleView.buildingNameLabel.text = address.buildingName
                selectedAddress = address
            }
        }
        if addressList.count == 0 {
            self.performSegue(withIdentifier: SegueIdentifiers.showDetailBookingAddress, sender: self)
        }
        else{
            //push availabel service
			stopSpecialAnimation()
			UIView.animate(withDuration: 0.6, animations: {
				self.logoImageView.alpha = 0
				}, completion: { (finished) in
					UIView.animate(withDuration: 0.3, animations: { 
						self.backgroundImageView.alpha = 0
						}, completion: {(fin) in
							self.performSegue(withIdentifier: SegueIdentifiers.loginSuccess, sender: self)
					})
			})

            print("done")
        }
    }
    func sendRequest(_ parameters: [String: AnyObject]?,
                     request: RequestManager,
                     requestType: RequestType,
                     isSetLoadingView: Bool) {
        // Check for internet connection
        if RequestHelper.isInternetConnectionFailed() {
            RequestHelper.showNoInternetConnectionAlert(self)
            return
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
            //handleResponseError(result.messageCode, title: LocalizedStrings.internalErrorTitle, message: result.messageInfo, requestType: requestType)
            let alertController = UIAlertController(title: LocalizedStrings.loginFailedTitle, message: result.messageInfo , preferredStyle: .alert)
            
            // Create the actions
            let okAction = UIAlertAction(title: "Retry", style: UIAlertActionStyle.default) {
                UIAlertAction in
                self.sendLoginRequest()
                
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default) {
                UIAlertAction in
                self.pushtoWelcomeScreen()
            }
            
            // Add the actions
            alertController.addAction(okAction)
            alertController.addAction(cancelAction)
            
            // Present the controller
            self.present(alertController, animated: true, completion: nil)
            if let error = result.messageCode {
                messageCode = error
            }
            return
        }
        if requestType == .fetchAllBookingAddresses {
            handleFetchAllBookingAddressesResponse(result, requestType: .fetchAllBookingAddresses)
        }
    }
    func pushtoWelcomeScreen() {
        SessionManager.sharedInstance.deleteLoginToken()
        let storyboard = self.storyboard
        
        if let welcomeScreen = storyboard?.instantiateViewController(withIdentifier: StoryboardIDs.welcom) as? WelcomeViewController {
            //loginScreen.isAutoLogin = false
            self.navigationController?.pushViewController(welcomeScreen, animated: true)
            SessionManager.sharedInstance.isLoggedIn = false
        }
    }
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueIdentifiers.loginSuccess {
            guard let destination = segue.destination as? AvailabelServicesViewController else {
                return
            }
            
            destination.isMovedFromLogin = true
        }
        if segue.identifier == SegueIdentifiers.showDetailBookingAddress {
            guard let destination = segue.destination as? CustomersAddressController else {
                return
            }
            
            destination.isMovedFromLogin = true
        }
        
    }
    

    // MARK: - Handle UIAlertViewAction
    
    override func handleTryAgainTimeoutAction(_ requestType: RequestType) {
        if requestType == .login {
            self.sendLoginRequest()
        }
    }
    

}

