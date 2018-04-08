//
//  AddNewCardTableViewController.swift
//  MaidMe
//
//  Created by Viktor on 1/19/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SSKeychain


class AddNewCardTableViewController: BaseTableViewController {
    

    @IBOutlet weak var cardNumberTextField: UITextField!
    @IBOutlet weak var cardLogo: UIImageView!
    @IBOutlet weak var expiryDateTextField: UITextField!
    @IBOutlet weak var cvvTextField: UITextField!
    @IBOutlet weak var addCardButton: UIButton!
    
    var expiryDate: Date!
    var newCard = Card()
     var isEnableAddButton = false
    var paymentToken: String!
    
//    let createTokenCard = CreateNewTokenCardService()
    let createCustomerCard = CreateCustomerCardService()
    let createTokenCard = CreatePayfortSdkService()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        self.navigationItem.title = "ADD CARD"
    }

    fileprivate func checkFullFillRequiredFields(_ card: Card?) {
        var isFullFilled = true
        
        if let card = card {
                isFullFilled = Validation.isFullFillRequiredTexts([card.number, (card.expiryMonth == 0 ? "" : "\(card.expiryMonth)"), card.cvv])
        }
        
        isEnableAddButton = isFullFilled
        ValidationUI.changeRequiredFieldsUI(isEnableAddButton, button: addCardButton)
    }
    
    @IBAction func addCardAction(){
        self.dismissKeyboard()
        if cardNumberTextField.text == "" || cvvTextField.text == ""{
            showAlertView(LocalizedStrings.updateSuccessTitle, message: LocalizedStrings.asteriskRequiredField, requestType: nil)
            return
        }
        
        getCardTokenRequest()
    }
    
    @IBAction func hanlderDismiss() {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func onTextFieldEditingChangedAction(_ sender: AnyObject) {
        
        guard let textField = sender as? UITextField else {
            return
        }
        
       if textField.tag == 101 {
            newCard.number = StringHelper.trimWhiteSpace(textField.text!)
			if CardHelper.getCardLogo(textField.text!, isSmall: true) != nil {
				newCard.cardLogoData = UIImagePNGRepresentation(CardHelper.getCardLogo(textField.text!, isSmall: true)!)
			}
			self.showPaymentInfo(newCard)
        }
        else if textField.tag == 102 {
            newCard.cvv = textField.text
        }
        
        checkFullFillRequiredFields(newCard)
    }
    func showPaymentInfo(_ card: Card) {
        
        cardNumberTextField.text = CardHelper.reformatCardNumber(card.number)
		if card.cardLogoData != nil {
			cardLogo.image = UIImage(data: card.cardLogoData! as Data)	
		}
        
        if card.expiryMonth != 0 && card.expiryYear != 0 {
            expiryDateTextField.text = DateTimeHelper.getExpiryDateString(card.expiryMonth, year: card.expiryYear)
            //card.expiryDate?.getStringFromDate(DateFormater.monthYearFormat)
        }
        cvvTextField.text = card.cvv
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        let currentCharacterCount = StringHelper.trimWhiteSpace(textField.text!).characters.count
        let newLength = currentCharacterCount + string.characters.count - range.length
        
        // Limit the maximum length of card number and card cvv
        if textField.tag == 101 {
            return newLength <= 19
        }
        else if textField.tag == 102 {
            return newLength <= 4
        }
        
        return true
    }
    
    func getCardTokenRequest() {
        
        let newSDKToken = PayfortSdkToken()
        newSDKToken.access_code = Configuration.accessCode
        newSDKToken.device_id = UIDevice.current.identifierForVendor?.uuidString
        newSDKToken.language = "en"
        newSDKToken.merchant_identifier = Configuration.merchantID
        newSDKToken.service_command = Configuration.sdkTokenCommand
        newSDKToken.signature = createTokenCard.getSignatureStr(newSDKToken)
        
        let parameters = createTokenCard.getSdkTokenParams(newSDKToken)
        print(parameters)
        sendRequest(parameters, request: createTokenCard, requestType: .createCardToken, isSetLoadingView: true)
    }
    
    func createCustomerCardRequest() {
        let parameters = createCustomerCard.getCustomerCardParams(paymentToken)
        sendRequest(parameters, request: createCustomerCard, requestType: .createCustomerCard, isSetLoadingView: true)
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
        if requestType == .createCardToken {
            handleCardTokenResponse(response)
            return
        } else if requestType == .createCustomerCard {
            self.navigationController?.popViewController(animated: true)
        }
      
    }
    
    func handleCardTokenResponse(_ response: DataResponse<Any>) {
        let result = ResponseHandler.newPayfortResponseHandling(response)
        
        if result.error != nil {
            if result.error == .errorCreatingCardPayfort {
                handleResponseError(nil, title: LocalizedStrings.invalidCardTitle, message: LocalizedStrings.invalidCardMessage, requestType: .createCardToken)
            }
            else {
                handleResponseError(result.error, title: LocalizedStrings.invalidCardTitle, message: LocalizedStrings.invalidCardMessage, requestType: .createCardToken)
            }
            return
        }
        
        // Create token successfully
        
        paymentToken = result.tokenID!
        createCustomerCardRequest()
        
    }

    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 2 {
            return self.tableView.frame.size.height - 300
        }
        return super.tableView(self.tableView, heightForRowAt: indexPath)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSelectExpiryDateView" {
            guard let destination = segue.destination as? SelectExprixeDateView else{
                return
            }
            destination.delegate = self
        }
    }
    
}


extension AddNewCardTableViewController: SelectExpiryDateDelegate {
    func showExpiryDate(_ expiryDate: Date) {
        self.expiryDate = expiryDate
        newCard.expiryMonth = expiryDate.getMonth()
        newCard.expiryYear = expiryDate.getYear()
         checkFullFillRequiredFields(newCard)
         expiryDateTextField.text = expiryDate.getStringFromDate(DateFormater.monthYearFormat)
    }
    
}
