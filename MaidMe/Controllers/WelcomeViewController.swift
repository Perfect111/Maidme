//
//  WelcomeViewController.swift
//  MaidMe
//
//  Created by Viktor on 12/27/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit

class WelcomeViewController: BaseViewController {
    @IBOutlet weak var createNewButton: UIButton!
    @IBOutlet weak var alreadyUserButton: UIButton!
    var navController: UINavigationController?
    var currentViewController: AnyObject!
    override func viewDidLoad() {
        super.viewDidLoad()
        createNewButton.layer.cornerRadius = 5
        alreadyUserButton.layer.cornerRadius = 5
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        disableBackToPreviousScreen(true)
        //hidden navigationbar
        self.navigationController?.navigationBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    @IBAction func login(_ sender: AnyObject) {
        if !SessionManager.sharedInstance.isLoggedIn {
            return
        }
        
//        SessionManager.sharedInstance.deleteLoginToken()
        
        let storyboard = self.storyboard
        
        if let loginScreen = storyboard?.instantiateViewController(withIdentifier: StoryboardIDs.login) as? LoginTableViewController {
            loginScreen.isAutoLogin = false
            navController?.pushViewController(loginScreen, animated: true)
            self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
            SessionManager.sharedInstance.isLoggedIn = false
        }
    }
    @IBAction func createNew(_ sender: AnyObject) {
        let storyboard = self.storyboard
        
        guard let registerScreen = storyboard?.instantiateViewController(withIdentifier: StoryboardIDs.register) as? RegisterViewController else {
            return
        }
        
        guard let _ = currentViewController as? RegisterViewController else {
            navController?.pushViewController(registerScreen, animated: true)
            return
        }
    }

}
