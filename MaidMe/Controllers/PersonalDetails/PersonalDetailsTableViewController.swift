//
//  PersonalDetailsTableViewController.swift
//  MaidMe
//
//  Created by Viktor on4/12/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SSKeychain

class PersonalDetailsTableViewController: BaseTableViewController {
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!

    @IBOutlet weak var phoneNumberTextField: UITextField!
  
    @IBOutlet weak var saveInfoButton: UIButton!
    
  
    
    let paddingLeft: CGFloat = 15.0
    var selectedArea: String?
    var selectedWorkingArea: WorkingArea?
    var messageCode: MessageCode?
    var defaultAreaList = [WorkingArea]()
    var customer: Customer!
    
    let workingAreaAPI = FetchWorkingAreaService()
    let getCustomerDetailsAPI = GetCustomerDetailsService()
    let updateCustomerDetailAPI = UpdateCustomerDetailsService()

    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchCustomerDetailsRequest()
        self.view.backgroundColor = UIColor.white
        self.navigationItem.title = "PROFILE"
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.hideBackbutton(false)
        self.customBackButton()
        removeSeparatorLine()
        phoneNumberTextField.keyboardType = UIKeyboardType.phonePad
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
       
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UI
    
    func removeSeparatorLine() {
        let cell1 = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0))
        
        guard let tableCell1 = cell1 else {
            return
        }
        
        self.tableView.removeSeparatorLine([tableCell1])
    }
    

    
    fileprivate func setUpAreaDropdownList(_ areaDropdownList: EDropdownLists) {
        areaDropdownList.delegate = self
        areaDropdownList.superView = self.tableView
        areaDropdownList.placeHolder = ""//LocalizedStrings.defaultArea
        areaDropdownList.dropdownMaxHeight(250)
        let bgColor = UIColor(red: 246.0 / 255.0, green: 246.0 / 255.0, blue: 246.0 / 255.0, alpha: 1)
        areaDropdownList.dropdownColor(bgColor, textFieldBgColor: UIColor.clear, textFieldTextColor: UIColor.black, selectedColor: UIColor(red: 255.0 / 255.0, green: 198.0 / 255.0, blue: 227.0 / 255.0, alpha: 1.0), textColor: UIColor.lightGray)
        
        if let superView = areaDropdownList.superview?.superview {
            let width = self.view.frame.width - paddingLeft * 2
            let yLocation = superView.frame.minY + areaDropdownList.frame.maxY + 6
            areaDropdownList.updateListTableFrame(yLocation, width: width)
        }
        
        areaDropdownList.dropdownTextField.leftView = nil
    }
    
    // MARK: - IBActions
    
    @IBAction func onTextFieldEditingChangedAction(_ sender: AnyObject) {
        guard let textField = sender as? UITextField else {
            return
        }
        
        let buttonPosition = textField.convert(CGPoint.zero, to: self.tableView)
        
        guard let indexPath =  self.tableView.indexPathForRow(at: buttonPosition) else {
            return
        }
        
        if indexPath.section == 0 {
            checkFullFillRequiredFields(saveInfoButton, fields: [firstNameTextField, lastNameTextField, emailTextField, phoneNumberTextField])
        }
    }
    
    // MARK: - Textfield delegate
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == phoneNumberTextField {
            // Reformat the number
            textField.text = StringHelper.reformatPhoneNumber(textField.text!)
        }
    }
    
    // MARK: - Validation
    
    fileprivate func isValidInfoData() -> (isValid: Bool, title: String, message: String) {
        if !Validation.isValidLength(firstNameTextField.text!, minLength: 0, maxLength: 45) || !Validation.isValidLength(lastNameTextField.text!, minLength: 0, maxLength: 45) {
            return (false, LocalizedStrings.inValidNameTitle, LocalizedStrings.inValidNameMessage)
        }
        
        if !Validation.isValidRegex(emailTextField.text!, expression: ValidationExpression.email) {
            return (false, LocalizedStrings.invalidEmailTitle, LocalizedStrings.invalidEmailMessage)
        }
        
        let phone = StringHelper.getPhoneNumber(phoneNumberTextField.text!)
        if !Validation.isValidPhoneNumber(phone) {
            return (false, LocalizedStrings.inValidPhoneNumberTitle, LocalizedStrings.inValidPhoneNumberMessage)
        }
        

        
        return (true, "", "")
    }
    
    // MARK: - IBActions
    
    @IBAction func onSaveInfoAction(_ sender: AnyObject) {
        if firstNameTextField.text == "" || lastNameTextField.text == "" || emailTextField.text == "" || phoneNumberTextField.text == ""{
            showAlertView(LocalizedStrings.updateSuccessTitle, message: LocalizedStrings.asteriskRequiredField, requestType: nil)
            return
        }
        let validationResult = isValidInfoData()
        dismissKeyboard()
        
        if !validationResult.isValid {
            // Show invalid alert
            showAlertView(validationResult.title, message: validationResult.message, requestType: nil)
            return
        }
        
        updateCustomerDetailsRequest()
    }
    
    fileprivate func checkFullFillRequiredFields(_ button: UIButton, fields: [UITextField]) {
        let isFullFilled = Validation.isFullFillRequiredFields(fields)
        
        ValidationUI.changeRequiredFieldsUI(isFullFilled, button: button)
    }
    
    // MARK: - API
    
    func fetchDefaultAreaRequest() {
        sendRequest(nil, request: workingAreaAPI, requestType: .fetchWorkingArea, isSetLoadingView: false, button: nil)
    }
    
    func fetchCustomerDetailsRequest() {
        sendRequest(nil, request: getCustomerDetailsAPI, requestType: .fetchCustomerDetails, isSetLoadingView: false, button: nil)
    }
    
    func updateCustomerDetailsRequest() {
        customer.firstName = firstNameTextField.text
        customer.lastName = lastNameTextField.text
        customer.phone = StringHelper.getPhoneNumber(phoneNumberTextField.text!)
        
        let params = updateCustomerDetailAPI.getParams(customer)
        sendRequest(params, request: updateCustomerDetailAPI, requestType: .updateCustomerDetails, isSetLoadingView: true, button: saveInfoButton)
    }
    
    func sendRequest(_ parameters: [String: AnyObject]?,
        request: RequestManager,
        requestType: RequestType,
        isSetLoadingView: Bool, button: UIButton?) {
            // Check for internet connection
            if RequestHelper.isInternetConnectionFailed() {
                RequestHelper.showNoInternetConnectionAlert(self)
                return
            }
            
            // Set loading view center
            if isSetLoadingView {
                setLoadingUI(.white, color: UIColor.white)
                self.setRequestLoadingViewCenter(button!)
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
    func saveCustomerInfo() {
        let phoneNumber = customer.phone
        if let customerName: String = customer.firstName! + " " + customer.lastName! {
            SSKeychain.setPassword(customerName, forService: KeychainIdentifier.appService, account: KeychainIdentifier.customerName)
        }
        SSKeychain.setPassword(phoneNumber, forService: KeychainIdentifier.appService, account: KeychainIdentifier.phoneNumber)
        customer.defaultArea = selectedWorkingArea
    }
    
    func handleResponse(_ response: DataResponse<Any>, requestType: RequestType) {
        let result = ResponseHandler.responseHandling(response)
        
        if result.messageCode != MessageCode.success {
            // Show alert
            handleResponseError(result.messageCode, title: LocalizedStrings.internalErrorTitle, message: result.messageInfo, requestType: requestType)
            
            if let error = result.messageCode {
                messageCode = error
            }
            
            return
        }
        
        if requestType == .fetchWorkingArea {
            handleFetchWorkingAreaResponse(result, requestType: .fetchWorkingArea)
        }
        else if requestType == .fetchCustomerDetails {
            handleFetchCustomerDetailsResponse(result, requestType: .fetchCustomerDetails)
        }
        else if requestType == .updateCustomerDetails {
            // Show success alert
             saveCustomerInfo()
            showAlertView(LocalizedStrings.updateSuccessTitle, message: LocalizedStrings.updateProfileSuccess, requestType: nil)

        }
    }
    override func handleAlertViewAction(_ requestType: RequestType?) {
            self.navigationController?.popToRootViewController(animated: true)
    }
    func handleFetchWorkingAreaResponse(_ result: ResponseObject, requestType: RequestType) {
        setUserInteraction(true)
        
        var list = [String]()
        var listArea = [WorkingArea]()
        
        for (_, dic) in result.body! {
            let item = WorkingArea(areaDic: dic)
            if item.areaID == nil && item.emirate != nil && item.area != nil {
                continue
            }
            
            listArea.append(item)
            list.append("\(item.emirate!) - \(item.area!)")
        }
        
        defaultAreaList = listArea

    }
    
    func handleFetchCustomerDetailsResponse(_ result: ResponseObject, requestType: RequestType) {
        guard let body = result.body else {
            return
        }
        
        customer = Customer(customerDic: body)
        
        firstNameTextField.text = customer.firstName
        lastNameTextField.text = customer.lastName
        emailTextField.text = customer.email
        phoneNumberTextField.text = StringHelper.reformatPhoneNumber(customer.phone == nil ? "" : customer.phone!)
        
        checkFullFillRequiredFields(saveInfoButton, fields: [firstNameTextField, lastNameTextField, emailTextField, phoneNumberTextField])
        
        // Fetch working area.
        fetchDefaultAreaRequest()
    }
    
    // MARK: - Handle UIAlertViewAction
    
    override func handleTryAgainTimeoutAction(_ requestType: RequestType) {
        if requestType == .fetchWorkingArea {
            self.fetchDefaultAreaRequest()
        }
        else if requestType == .fetchCustomerDetails {
            self.fetchCustomerDetailsRequest()
        }
        else if requestType == .updateCustomerDetails {
            self.updateCustomerDetailsRequest()
        }
}
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 8 {
            if self.view.frame.size.height > 460 {
                return (self.view.frame.size.height - 380)
            } else {
                return 150
            }
        } else {
            return 42
        }
        
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueIdentifiers.showWorkingAreaList {
            guard let destination = segue.destination as? UINavigationController else {
                return
            }
            guard let destinationVC = destination.viewControllers[0] as? WorkingAreaTableViewController else {
                return
            }
            destinationVC.delegate = self
        }
    }
}

// MARK: - EdropdownListsDelegate

extension PersonalDetailsTableViewController: EdropdownListsDelegate {
    func didSelectItem(_ selectedItem: String, index: Int) {
        selectedArea = selectedItem
        checkFullFillRequiredFields(saveInfoButton, fields: [firstNameTextField, lastNameTextField, emailTextField, phoneNumberTextField])
    }
    
    func didSelectItemFromList(_ selectedItem: String) {
//        areaDropdownList.dropdownTextField.endEditing(true)
    }
    
    func getWorkingAreaIDFromArea(_ area: String?, list: [WorkingArea]) -> String? {
        guard let workingArea = area else {
            return nil
        }
        
        guard list.count > 0 else {
            return nil
        }
        
        for item in list {
            let itemName = item.emirate! + " - " + item.area!
            if workingArea.lowercased() == itemName.lowercased() {
                return item.areaID
            }
        }
        
        return nil
    }
}

extension PersonalDetailsTableViewController: WorkingAreaTableViewControllerDelegate {
    func didSelectArea(_ selectedArea: WorkingArea?) {
        self.selectedWorkingArea = selectedArea
        
        if selectedArea?.emirate != nil && selectedArea?.area != nil {
            if selectedArea?.emirate != "" && selectedArea?.area != "" {
               
                checkFullFillRequiredFields(saveInfoButton, fields: [firstNameTextField, lastNameTextField, emailTextField, phoneNumberTextField])
            }
        }
    }
}
