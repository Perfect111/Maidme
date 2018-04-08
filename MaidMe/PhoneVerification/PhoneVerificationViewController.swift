//
//  PhoneVerificationViewController.swift
//  MaidMe
//
//  Created by Viktor on 4/20/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import UIKit
import PhoneNumberKit

class PhoneVerificationViewController: BaseViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var codeTextField: UITextField!
    @IBOutlet weak var verifyButton: UIButton!
    
    fileprivate var validationKey: String?
    var phoneNumber: String!
    
    typealias Action = (_ controller: PhoneVerificationViewController) -> Void
    var didVerifyPhoneSuccessfully: Action?
    var didCancelPhoneVerification: Action?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("Verify number", comment: "")
        titleLabel.text = NSLocalizedString("Please enter the verification code texted to your number", comment: "") + " " + phoneNumber
        sendSMS()
    }

    func sendSMS() {
        do {
            let phoneKit = PhoneNumberKit()
            var phonenumber = try phoneKit.parse(phoneNumber)
            let number = phoneKit.format(phonenumber, toType: .e164)
            CheckMobiConfigurations.requestValidation(number, completion: { [weak self] (validationKey, error) in
                guard let `self` = self else { return }
                guard let validationKey = validationKey else {
                    let alert = UIAlertController(title: NSLocalizedString("Error!", comment: ""),
                        message: NSLocalizedString(error ?? "Error", comment: ""),
                        preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""),
                        style: .cancel,
                        handler: { action in
                            self.dismiss(animated: true, completion: nil)
                    }))
                    self.presentAlertView(alert)
                    return
                }
                
                self.validationKey = validationKey
                })
        }catch {
            //error
        }

    }
    
    
    @IBAction func onClickVerifyPhoneNumber(_ sender: AnyObject) {
        dismissKeyboard()
        
        guard let pin = self.codeTextField.text, !pin.isEmpty else {
            showAlertView("Invalid pin", message: "Please provide a valid pin number", requestType: nil)
            return
        }

        // Set loading view center
        setLoadingUI(.white, color: UIColor.white)
        startLoadingView()

        CheckMobiConfigurations.verifyPin(pin, validationKey: validationKey, completion: { (success, error) in
            self.stopLoadingView()
            
            if success {
                self.showAlertView("Thank you!", message: "Validation completed", requestType: nil)
                self.didVerifyPhoneSuccessfully?(self)
            }else {
                // show error
                self.showAlertView("Error", message: "Invalid PIN!", requestType: nil)
            }
        })
    }
    
    @IBAction func onClickCancelButton(_ sender: AnyObject) {
        self.didCancelPhoneVerification?(self)
    }
}
