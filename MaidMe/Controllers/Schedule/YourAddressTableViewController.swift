//
//  YourAddressTableViewController.swift
//  MaidMe
//
//  Created by Viktor on3/1/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SSKeychain

class YourAddressTableViewController: BaseTableViewController {
    
    @IBOutlet weak var buildingNameTextField: UITextField!
    @IBOutlet weak var apartmentNoTextField: UITextField!
    @IBOutlet weak var floorNoTextField: UITextField!
    @IBOutlet weak var streetNoTextField: UITextField!
    @IBOutlet weak var streetNameTextField: UITextField!
    @IBOutlet weak var countryTextField: UITextField!
    @IBOutlet weak var areaTextField: UITextField!
    //    @IBOutlet weak var cityTextField: UITextField!
    //    @IBOutlet weak var zipCodeTextField: CustomTextField!
    @IBOutlet weak var zipCodePOTextField: UITextField!
    @IBOutlet weak var landmarkTextField: UITextField!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var emiratesTextField: UITextField!
    
    let textFontSize: CGFloat = 16.0
    var paymentAddress: Address?
    var isEdited: Bool = false
    var addNewAddressService = AddNewBookingAddressService()
    var updateAddressService = UpdateBookingAddressService()
    let getCustomerDetailsService = GetCustomerDetailsService()
    var messageCode: MessageCode?
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.hideTableEmptyCell()
        
        //        cityAndZipcodeTableViewCell.hidden = true
        // Set place holder font
        StringHelper.setPlaceHolderFont([buildingNameTextField, apartmentNoTextField, floorNoTextField, streetNoTextField, streetNameTextField, countryTextField, areaTextField,zipCodePOTextField, landmarkTextField], font: CustomFont.quicksanRegular, fontsize: textFontSize)
        
        if let _ = paymentAddress {
            setAddressData()
        }
        else {
            paymentAddress = Address()
            setDefaultAddress()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Segue Data
    
    func setAddressData() {
        buildingNameTextField.text = paymentAddress!.buildingName
        apartmentNoTextField.text = paymentAddress!.apartmentNo
        floorNoTextField.text = paymentAddress!.floorNo
        streetNoTextField.text = paymentAddress!.streetNo
        streetNameTextField.text = paymentAddress!.streetName
        countryTextField.text = paymentAddress!.country
        areaTextField.text = paymentAddress!.area
        
        if let emirate = paymentAddress!.emirate {
            if emirate != "" {
                //                areaTextField.text = paymentAddress!.emirate + " - " + paymentAddress!.area
                emiratesTextField.text = paymentAddress!.emirate
            }
        }
        zipCodePOTextField.text = (paymentAddress!.zipPO == nil ? "" : "\(paymentAddress!.zipPO!)")
        //        cityTextField.text = paymentAddress!.city
        //        zipCodeTextField.text = (paymentAddress!.zipPO == nil ? "" : "\(paymentAddress!.zipPO!)")
        landmarkTextField.text = paymentAddress!.additionalDetails
        
        checkFullFillRequiredFields()
    }
    
    func setDefaultAddress() {
        let emirate = SSKeychain.password(forService: KeychainIdentifier.appService, account: KeychainIdentifier.emirate)
        let area = SSKeychain.password(forService: KeychainIdentifier.appService, account: KeychainIdentifier.area)
        //        
        //        if emirate != nil && area != nil {
        //            if emirate != "" && area != "" {
        //                areaTextField.text = emirate + " - " + area
        //                return
        //            }
        //        }
        areaTextField.text = area
        emiratesTextField.text = emirate
        
        // Call API to request default area
        fetchCustomerDetailsRequest()
    }
    
    // MARK: - IBActions
    
    @IBAction func onTextFieldEditingChangedAction(_ sender: AnyObject) {
        checkFullFillRequiredFields()
    }
    
    @IBAction func onDoneAction(_ sender: AnyObject) {
        dismissKeyboard()
               paymentAddress!.buildingName = buildingNameTextField.text
        paymentAddress!.apartmentNo = apartmentNoTextField.text
        paymentAddress!.floorNo = floorNoTextField.text
        paymentAddress!.streetNo = streetNoTextField.text
        paymentAddress!.streetName = streetNameTextField.text
        paymentAddress!.zipPO = zipCodePOTextField.text
        paymentAddress!.area = areaTextField.text
        paymentAddress!.emirate = emiratesTextField.text
        paymentAddress!.city = emiratesTextField.text
        paymentAddress!.additionalDetails = landmarkTextField.text
        paymentAddress!.country = countryTextField.text
        
        if isEdited {
            updateBookingAddressRequest()
        }
        else {
            addNewBookingAddressRequest()
        }
    }
    
    // MARK: - UI
    
    fileprivate func checkFullFillRequiredFields() {
        let isFullFilled = Validation.isFullFillRequiredFields([buildingNameTextField, apartmentNoTextField , areaTextField])
        
        ValidationUI.changeRequiredFieldsUI(isFullFilled, button: doneButton)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueIdentifiers.saveUserAddress {
            guard segue.destination is ScheduleAndDetail else {
                return
            }
            
//            destination.address = paymentAddress!
        }
    }
    
    // MARK: - API
    
    func addNewBookingAddressRequest() {
        let parameters = addNewAddressService.getParams(paymentAddress!, areaID: paymentAddress!.workingArea_ref)
        sendRequest(parameters, request: addNewAddressService, requestType: .addNewBookingAddress, isSetLoadingView: true)
    }
    
    func updateBookingAddressRequest() {
        let parameters = updateAddressService.getParams(paymentAddress!, areaID: nil,isDefault: nil)
        sendRequest(parameters, request: updateAddressService, requestType: .updateBookingAddress, isSetLoadingView: true)
    }
    
    func fetchCustomerDetailsRequest() {
        sendRequest(nil, request: getCustomerDetailsService, requestType: .fetchCustomerDetails, isSetLoadingView: false)
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
            
            // Set loading view center
            if isSetLoadingView {
                setLoadingUI(.white, color: UIColor.white)
                self.setRequestLoadingViewCenter(doneButton)
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
        
        if result.messageCode != MessageCode.success {
            // Show alert
            handleResponseError(result.messageCode, title: LocalizedStrings.internalErrorTitle, message: result.messageInfo, requestType: requestType)
            
            if let error = result.messageCode {
                messageCode = error
            }
            
            return
        }
        
        if requestType == .addNewBookingAddress {
            handleAddNewBookingResponse(result, requestType: .addNewBookingAddress)
        }
        else if requestType == .updateBookingAddress {
            handleUpdateBookingAddressResponse(result, requestType: .updateBookingAddress)
        }
        else if requestType == .fetchCustomerDetails {
            handleFetchCustomerDetailsResponse(result, requestType: .fetchCustomerDetails)
        }
    }
    
    func handleAddNewBookingResponse(_ result: ResponseObject, requestType: RequestType) {
        if let addressID = result.body?["address_id"] {
            paymentAddress!.addressID = addressID.stringValue
        }
        else {
            // Handle error when address ID is nil
            showAlertView(LocalizedStrings.internalErrorTitle, message: LocalizedStrings.internalErrorMessage, requestType: .addNewBookingAddress)
            return
        }
        
        // Move to payment screen
        self.performSegue(withIdentifier: SegueIdentifiers.saveUserAddress, sender: self)
    }
    
    func handleUpdateBookingAddressResponse(_ result: ResponseObject, requestType: RequestType) {
        self.performSegue(withIdentifier: SegueIdentifiers.saveUserAddress, sender: self)
    }
    
    func handleFetchCustomerDetailsResponse(_ result: ResponseObject, requestType: RequestType) {
        guard let body = result.body else {
            return
        }
        
        let customer = Customer(customerDic: body)
        let emirate = (customer.defaultArea?.emirate == nil ? "" : customer.defaultArea!.emirate!)
        let area = (customer.defaultArea?.area == nil ? "" : customer.defaultArea!.area!)
        
        if emirate == "" || area == "" {
            // Inform error here
            showAlertView(LocalizedStrings.internalErrorTitle, message: LocalizedStrings.getAreaErrorMessage, requestType: nil)
            setUserInteraction(false)
            return
        }
        
        
    }
    
    // MARK: - Handle UIAlertViewAction
    
    override func handleTryAgainTimeoutAction(_ requestType: RequestType) {
        if requestType == .addNewBookingAddress {
            self.addNewBookingAddressRequest()
        }
        else if requestType == .updateBookingAddress {
            self.updateBookingAddressRequest()
        }
        else if requestType == .fetchCustomerDetails {
            self.fetchCustomerDetailsRequest()
        }
    }
}
