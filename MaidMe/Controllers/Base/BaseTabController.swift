//
//  BaseTabController.swift
//  MaidMe
//
//  Created by Vo Minh Long on 12/14/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit
import SVProgressHUD

class BaseTabController: UITabBarController {
    var alert: UIAlertController!
    var loadingIndicator: UIActivityIndicatorView!
    var isShownAlert: Bool = false
    var rightMenuButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createLoadingIndicator()
        customBackButton()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // End editing
        dismissKeyboard()
    }
    // MARK: - Loading View
    
    func createLoadingIndicator() {
        self.loadingIndicator = UIActivityIndicatorView()
        setDefaultUIForLoadingIndicator()
    }
    
    func setDefaultUIForLoadingIndicator() {
        self.loadingIndicator.activityIndicatorViewStyle = .whiteLarge
        self.loadingIndicator.color = UIColor.black
        self.view.addSubview(self.loadingIndicator)
        
        let viewBounds = self.view.bounds
        self.loadingIndicator.center = CGPoint(x: viewBounds.midX, y: viewBounds.midY)
    }
    
    func setLoadingUI(_ type: UIActivityIndicatorViewStyle, color: UIColor? = nil) {
        loadingIndicator.activityIndicatorViewStyle = type
        if let color = color {
            loadingIndicator.color = color
        }
    }
    
    func setRequestLoadingViewCenter(_ button: UIButton) {
        let x = button.frame.width - 10
        var y: CGFloat = 100
        if let superView = button.superview?.superview {
            y = superView.frame.minY + button.frame.maxY - 25
        }
        setLoadingViewCenter(x, y: y)
    }
    
    func setRequestLoadingViewCenter1(_ view: UIView) {
        var x = view.frame.width - 10
        var y: CGFloat = 100
        if let superView = view.superview {
            x = view.center.x
            y = superView.frame.minY / 2 + view.center.y
        }
        
        setLoadingViewCenter(x, y: y)
    }
    
    func setLoadingViewCenter(_ x: CGFloat, y: CGFloat) {
        self.loadingIndicator.center = CGPoint(x: x, y: y)
    }
    
    func startLoadingView() {
        DispatchQueue.main.async { () -> Void in
			if !SVProgressHUD.isVisible() {
				SVProgressHUD.show()
			}
            self.view.isUserInteractionEnabled = false
            self.navigationController?.navigationBar.isUserInteractionEnabled = false
            self.disableBackToPreviousScreen(true)
        }
    }
    
    func stopLoadingView() {
        DispatchQueue.main.async { () -> Void in
            SVProgressHUD.dismiss()
            self.view.isUserInteractionEnabled = true
            self.navigationController?.navigationBar.isUserInteractionEnabled = true
            self.disableBackToPreviousScreen(false)
        }
    }
    
    func setUserInteraction(_ isEnable: Bool) {
        self.view.isUserInteractionEnabled = isEnable
    }
    
    // MARK: - Textfield Delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    // MARK: - UI
    func customBackButton() {
        // Uncomment the following code to set custom back image
        /*self.navigationController?.navigationBar.backIndicatorImage = UIImage(named: "back_arrow")
         self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "back_arrow")*/
        
        // Remove the default back title
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    func hideBackbutton(_ isHidden: Bool) {
        // Disable/Enable wipe back to previous screen
        disableWipeBack(isHidden)
        
        // Hide back button
        self.navigationItem.hidesBackButton = isHidden
    }
    
    func disableBackToPreviousScreen(_ isDisable: Bool) {
        // Disable/Enable wipe back to previous screen
        disableWipeBack(isDisable)
        
        self.navigationItem.backBarButtonItem?.isEnabled = !isDisable
    }
    
    func disableWipeBack(_ isDisable: Bool) {
        if let navController = self.navigationController {
            if (navController.responds(to: #selector(getter: UINavigationController.interactivePopGestureRecognizer))) {
                navController.interactivePopGestureRecognizer?.isEnabled = !isDisable
            }
        }
    }
    
 
    func imageWithColor(_ color: UIColor) -> UIImage {
        let rect = CGRect(x: 0.0, y: 0.0, width: 44.0, height: 44.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
    
    // MARK: - Handle response
    
    func handleAPIResponse() {
        // Hide the loading indicator
        stopLoadingView()
    }
    
    func handleResponseError(_ messageCode: MessageCode?, title: String, message: String?, requestType: RequestType) {
        if messageCode == nil {
            DispatchQueue.main.async(execute: {
                self.showAlertView(LocalizedStrings.connectionFailedTitle, message: LocalizedStrings.connectionFailedMessage, requestType: requestType)
            })
        }
            
        else if messageCode == .timeout {
            // Show alert with two button
            DispatchQueue.main.async(execute: {
                self.showTimeOutAlert(LocalizedStrings.timeoutTitle, message: LocalizedStrings.timeoutMessage, requestType: requestType)
            })
        }
        else {
            DispatchQueue.main.async(execute: {
                var alertTitle = title
                
                if messageCode == .cannotCharge {
                    alertTitle = LocalizedStrings.paymentFailedTitle
                }
                
                if let messageInfo = message {
                    self.showAlertView(alertTitle, message: messageInfo, requestType: requestType)
                }
                else {
                    self.showAlertView(title, message: LocalizedStrings.connectionFailedMessage, requestType: requestType)
                }
            })
        }
    }
    
    // MARK: - UIAlertView
    
    func presentAlertView(_ alert: UIAlertController) {
        
        DispatchQueue.main.async(execute: {
            if self.isShownAlert {
                //self.alert.dismissViewControllerAnimated(true, completion: nil)
                return
            }
            else {
                self.present(self.alert, animated: true, completion: nil)
            }
            self.isShownAlert = true
        })
    }
    
    func showAlertView(_ title: String?, message: String, requestType: RequestType?) {
        alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: LocalizedStrings.okButton, style: UIAlertActionStyle.default) { (action) -> Void in
            self.handleAlertViewAction(requestType)
            self.isShownAlert = false
        }
        
        alert.addAction(action)
        
        presentAlertView(self.alert)
    }
    
    func showTimeOutAlert(_ title: String, message: String, requestType: RequestType) {
        alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: LocalizedStrings.okButton, style: .default){ (action) -> Void in
            // Resend the sign up request
            self.handleTimeoutOKAction(requestType)
            self.isShownAlert = false
        }
        
        let tryAgainAction = UIAlertAction(title: LocalizedStrings.tryAgainButton, style: .default) { (action) -> Void in
            // Resend the sign up request
            self.handleTryAgainTimeoutAction(requestType)
            self.isShownAlert = false
        }
        
        alert.addAction(okAction)
        alert.addAction(tryAgainAction)
        
        presentAlertView(self.alert)
    }
    
    // MARK: - Handle UIAlertViewAction
    
    func handleAlertViewAction(_ requestType: RequestType?) {}
    func handleTryAgainTimeoutAction(_ requestType: RequestType) {}
    func handleTimeoutOKAction(_ requestType: RequestType) {}
    
}


extension BaseTabController: UITextFieldDelegate {
    
    /**
     Close keyboard when touch on empty area.
     
     - parameter touches:
     - parameter event:
     */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}
