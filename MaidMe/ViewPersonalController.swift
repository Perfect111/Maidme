//
//  ViewPersonalController.swift
//  MaidMe
//
//  Created by Viktor on 1/5/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SSKeychain
import RealmSwift


class ViewPersonalController: BaseViewController {
    
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var cardNumberLabel: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    var isPopView : Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isPopView = false
        showCustomerInfor()
        displayVersion()
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = false
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isPopView = true
    }
    override func viewDidAppear(_ animated: Bool) {
        if isPopView == true {
            showCustomerInfor()
        }
    }
    
    func displayVersion() {
        var myDict: NSDictionary?
        if let path = Bundle.main.path(forResource: "Info", ofType: "plist") {
            myDict = NSDictionary(contentsOfFile: path)
        }
        if let dict = myDict {
            let version = dict["CFBundleShortVersionString"] as! String
            let build = dict["CFBundleVersion"] as! String
            
            #if DEVELOPMENT
            versionLabel.text = "\(version) - \(build)"
            #else
            versionLabel.text = "\(version)"
            #endif
        }
    }

    func showCustomerInfor(){
        let email = SSKeychain.password(forService: KeychainIdentifier.appService, account: KeychainIdentifier.userName)
        let phoneNumber = SSKeychain.password(forService: KeychainIdentifier.appService, account: KeychainIdentifier.phoneNumber)
        let customerName = SSKeychain.password(forService: KeychainIdentifier.appService, account: KeychainIdentifier.customerName)
        emailLabel.text = email
        phoneLabel.text = StringHelper.reformatPhoneNumber(phoneNumber == nil ? "" : phoneNumber!)
        nameLabel.text = customerName
    }
    
    @IBAction func editPersonalDetailAction(_ sender: AnyObject?) {
        let storyboard = self.storyboard
        guard let personalVC = storyboard?.instantiateViewController(withIdentifier: StoryboardIDs.personalDetails) else {
            return
        }
        self.navigationController?.pushViewController(personalVC, animated: true)
        
    }
    
    @IBAction func savedPlacesAction(_ sender: AnyObject?) {
        let storyboard = self.storyboard
        guard let SavePlaceVC = storyboard?.instantiateViewController(withIdentifier: "SavePlaceVC") as? BookingAddressTableViewController else {
               return }

        SavePlaceVC.isMoveFromViewPersonal = true
        self.navigationController?.pushViewController(SavePlaceVC, animated: true)
    }
    
    @IBAction func showChangePasswordVC(_ sender: AnyObject?) {
        let storyboard = self.storyboard
        guard let changePassVC = storyboard!.instantiateViewController(withIdentifier: "ChangePasswordVC") as? ChangePasswordTableViewController else {
            return
        }
        self.navigationController?.pushViewController(changePassVC,animated: true)
    }
    
    @IBAction func showTermAndConditionsAction(_ sender: AnyObject?) {
        let storyboard = self.storyboard
        guard let termAndConditionsVC = storyboard?.instantiateViewController(withIdentifier: "TermsAndConditionsVC") as? TermsAndConditions else{
            return
        }
        termAndConditionsVC.isMovedFromLogin = true
        self.navigationController?.pushViewController(termAndConditionsVC, animated: true)
    }
    
    @IBAction func paymentMethodAction(_ sender: AnyObject?) {
       let storyboard = self.storyboard
        guard let paymentMethodsVC = storyboard?.instantiateViewController(withIdentifier: "PaymentMethods") as? PaymentMethodsTableViewController else {
            return        }
        paymentMethodsVC.isMoveFromViewPersonal = true
        self.navigationController?.pushViewController(paymentMethodsVC, animated: true)
        
    }
    
    @IBAction func signOutAction(_ sender: AnyObject?) {
        logOutUser()
    }
    func logOutUser() {
        if !SessionManager.sharedInstance.isLoggedIn {
            return
        }
		
		let realm = try! Realm()
		try! realm.write {
			realm.deleteAll()
		}
        
        SessionManager.sharedInstance.deleteLoginToken()
        let storyboard = self.storyboard
        
        if let welcomeScreen = storyboard?.instantiateViewController(withIdentifier: StoryboardIDs.welcom) as? WelcomeViewController {
            //loginScreen.isAutoLogin = false
            self.navigationController?.pushViewController(welcomeScreen, animated: true)
            SessionManager.sharedInstance.isLoggedIn = false
        }
    }
    
}
