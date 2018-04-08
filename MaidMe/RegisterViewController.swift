//
//  RegisterViewController.swift
//  MaidMe
//
//  Created by Viktor on2/17/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit

class RegisterViewController: BaseViewController {

    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: CustomTextField!
    @IBOutlet weak var defaultArea: EDropdownList!
    @IBOutlet weak var registerButton: UIButton!
    
    var isKeyboardShown: Bool = false
    var currentChangedHeight: CGFloat = 0.0
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        createFakeDataForDefaultArea()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Listen to show keyboard events.
        NotificationCenter.default.addObserver(self, selector: #selector(RegisterViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(RegisterViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        // Scroll the view to the top
        mainScrollView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        if isKeyboardShown {
            adjustingHeight(true, height: -currentChangedHeight)
        }
        
        currentChangedHeight = 0
        isKeyboardShown = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Nofitications
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if !isKeyboardShown {
            var userInfo = notification.userInfo!
            let keyboarFrame: CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
            currentChangedHeight = keyboarFrame.height// + 40
            
            adjustingHeight(true, height: currentChangedHeight)
            isKeyboardShown = true
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        adjustingHeight(false, height: -currentChangedHeight)
        isKeyboardShown = false
        currentChangedHeight = 0
    }
    
    /**
     Change the scroll view height to move up the textfield
     
     - parameter show:
     - parameter notification:
     - parameter height:
     */
    func adjustingHeight(_ show:Bool, height: CGFloat) {
        mainScrollView.contentInset.bottom += height
        mainScrollView.scrollIndicatorInsets.bottom += height
    }
    

    // MARK: - UI
    
    fileprivate func createFakeDataForDefaultArea() {
        let listValue = ["USA - New York", "Vietnam - Danang", "Canada - Torronto", "USA - WDC", "Vietnam - Hue", "Vietnam - Hanoi", "Vietnam - Hoian"]
        defaultArea.delegate = self
        defaultArea.valueList = listValue
        defaultArea.placeHolder = "Default area"
        defaultArea.buttonTextAlignment = UIControlContentHorizontalAlignment.left
        defaultArea.dropdownColor(UIColor.white, buttonBgColor: UIColor.clear, buttonTextColor: UIColor.lightGray, textColor: UIColor.lightGray)
//        defaultArea.downArrow = "arrow_down"
//        defaultArea.upArrow = "arrow_up"
    }
    
    // MARK: - IBActions
    
    @IBAction func onTextFieldEditingChangedAction(_ sender: AnyObject) {
        let isFullFilled = Validation.isFullFillRequiredFields([emailTextField,passwordTextField, confirmPasswordTextField, phoneNumberTextField])
        ValidationUI.changeRequiredFieldsUI(isFullFilled, button: registerButton)
    }
    
    // MARK: - Textfield delegate
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        // Hide the default area dropdown
        defaultArea.hideDropdownList(true)
        return true
    }
    
    @IBAction func onRegisterAction(_ sender: AnyObject) {
        
        let validationResult = isValidData()
        
        if !validationResult.isValid {
            // Show invalid alert
            showAlertView(validationResult.title, message: validationResult.message, requestType: nil)
            return
        }
        
        // Send request to server.
        print("Send request to server here")
    }
    
    // MARK: - Validation
    
    fileprivate func isValidData() -> (isValid: Bool, title: String, message: String) {
        if !Validation.isValidLength(firstNameTextField.text!, minLength: 0, maxLength: 45) || !Validation.isValidLength(lastNameTextField.text!, minLength: 0, maxLength: 45) {
            return (false, LocalizedStrings.inValidNameTitle, LocalizedStrings.inValidNameMessage)
        }
        
        if !Validation.isValidRegex(emailTextField.text!, expression: ValidationExpression.email) {
            return (false, LocalizedStrings.invalidEmailTitle, LocalizedStrings.invalidEmailMessage)
        }
        
        if !Validation.isValidLength(passwordTextField.text!, minLength: 6, maxLength: 45) {
            return (false, LocalizedStrings.invalidPasswordTitle, LocalizedStrings.invalidPasswordMessage)
        }
        
        if !Validation.matchedStrings(passwordTextField.text!, stringTwo: confirmPasswordTextField.text!) {
            return (false, LocalizedStrings.notMatchedPasswordTitle, LocalizedStrings.notMatchedPasswordMessage)
        }
        
        let phone = StringHelper.createPhoneNumber("", number: phoneNumberTextField.text!)
        if !Validation.isValidPhoneNumber(phone) {
            return (false, LocalizedStrings.inValidPhoneNumberTitle, LocalizedStrings.inValidPhoneNumberMessage)
        }
        
        return (true, "", "")
    }
}

extension RegisterViewController: EdropdownListDelegate {
    func didSelectItem(_ selectedItem: String, index: Int) {
        print("select: \(selectedItem), index: \(index)")
    }
    
    func didTouchDownDropdownList() {
        dismissKeyboard()
    }
}

