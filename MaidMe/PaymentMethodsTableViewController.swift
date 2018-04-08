//
//  ListCardTableViewController.swift
//  MaidMe
//
//  Created by Viktor on 1/6/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import UIKit
import SWTableViewCell
import Alamofire
import SwiftyJSON
import SSKeychain

class PaymentMethodsTableViewController: BaseTableViewController {
    
    @IBOutlet weak var customerNameLabel: UILabel!
    @IBOutlet weak var customerEmailLabel: UILabel!
    @IBOutlet weak var customerPhoneLabel: UILabel!
    
    var listCard = [Card]()
    var removeCardAPI = RemoveCardService()
    var defaultCardAPI = DefaultCardService()
    var messageCode: MessageCode?
    let fetchAllCardAPI = FetchAllCardsService()
    var isMoveFromViewPersonal: Bool?
    
    let createPayfortSDKAPI = CreatePayfortSdkService()
    var newSDKToken = PayfortSdkToken()
    
    let createTokenCard = CreateNewTokenCardService()
    let createCustomerCard = CreateCustomerCardService()
    var paymentToken: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchAllCardsRequest()
        showCustomerInfor()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = false
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isMoveFromViewPersonal != true {
            fetchAllCardsRequest()
            showCustomerInfor()
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isMoveFromViewPersonal = false
    }
    
    func showCustomerInfor(){
        let email = SSKeychain.password(forService: KeychainIdentifier.appService, account: KeychainIdentifier.userName)
        let phoneNumber = SSKeychain.password(forService: KeychainIdentifier.appService, account: KeychainIdentifier.phoneNumber)
        let customerName = SSKeychain.password(forService: KeychainIdentifier.appService, account: KeychainIdentifier.customerName)
        customerEmailLabel.text = email
        customerPhoneLabel.text = StringHelper.reformatPhoneNumber(phoneNumber == nil ? "" : phoneNumber!)
        customerNameLabel.text = customerName
    }

    func rightButtons() -> NSMutableArray{
        let leftUtilityButtons = NSMutableArray()
        leftUtilityButtons.sw_addUtilityButton(with: UIColor(red:  91.0/255,green: 194.0/255,blue: 209.0/255.0,alpha: 1.0), icon: UIImage(named: "default_button"))
        leftUtilityButtons.sw_addUtilityButton(with: UIColor.lightGray, icon: UIImage(named: "deletee_button" ))
        return leftUtilityButtons
    }
    
    @IBAction func backAction(_ sender: AnyObject?) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func removeCardRequest(_ cardRemove: Card?) {
        let params = removeCardAPI.getRemoveCardParams(cardRemove)
        sendRequest(params as [String : AnyObject], request: removeCardAPI, requestType: .removeCards, isSetLoadingView: true, button: nil)
        
    }
    func defaultCardRequest(_ card: Card) {
        let params = defaultCardAPI.getDefaultCardParams(card)
        sendRequest(params as [String : AnyObject], request: defaultCardAPI, requestType: .defaultCard, isSetLoadingView: true, button: nil)
    }
    func fetchAllCardsRequest() {
        sendRequest(nil, request: fetchAllCardAPI, requestType: .fetchAllCard, isSetLoadingView: false,button: nil)
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
        if requestType == .defaultCard {
            fetchAllCardsRequest()
        } else if requestType == .fetchAllCard {
            handleCardListResponse(result.body)
        } else if requestType == .createCardToken {
            handleCardTokenResponse(response)
            return
        }
        
    }
    
     func handleCardListResponse(_ responseBody: JSON?) {
        guard let list = responseBody else {
            return
        }
        
        listCard = fetchAllCardAPI.getCardList(list)
        self.tableView.reloadData()
      
    }
    
    @IBAction func editPersonalAction(_ sender: AnyObject) {
        let storyboard = self.storyboard
        guard let personalVC = storyboard?.instantiateViewController(withIdentifier: StoryboardIDs.personalDetails) else {
            return
        }
        self.navigationController?.pushViewController(personalVC, animated: true)
        
    }
    func showAddNewCardVC(){
        let storyboard = self.storyboard
        guard let addNewCardVC = storyboard?.instantiateViewController(withIdentifier: StoryboardIDs.addNewCardVC) else {
            return
        }
        self.navigationController?.pushViewController(addNewCardVC,animated: true)
    }
    
    func displayDeleteCard(_ index: Int) {
        let alert = UIAlertController(title: "Do you want to delete this card?", message: "**** **** **** \(listCard[index].lastFourDigit)", preferredStyle: .alert)
        let cancelButton = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        let okButton = UIAlertAction(title: "Ok", style: .default) { (action) in
            self.removeCardRequest(self.listCard[index])
            self.listCard.remove(at: index)
            self.tableView.reloadData()
        }
        alert.addAction(cancelButton)
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if listCard.count != 0 {
            return listCard.count + 1
        } else {
            return 1
        }
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if listCard.count != 0 && indexPath.row < listCard.count {
            let cellID = "defaultCardCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? DefaultCardCell
                let card = listCard[indexPath.row]
                if card.isDefault == true {
                    cell!.defaultCardLabel.text = "DEFAULT CARD"
                } else {
                    cell?.delegate = self
                    cell?.setRightUtilityButtons(rightButtons() as [AnyObject], withButtonWidth: 70)
                    cell!.defaultCardLabel.text = "CARD"
                }
                cell!.endCardNumber.text = "**** **** **** \(card.lastFourDigit)"
            return cell!
        } else {
                let cellId = "addNewCardCell"
                let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? AddNewCardCell
                return cell!
        }
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == listCard.count {
            
            self.showAddNewCardVC()
            
        }
    }
    
    // Payfort Request
    
    func sendPayfortRequest(){
        
        newSDKToken.access_code = Configuration.accessCode
        newSDKToken.device_id = UIDevice.current.identifierForVendor?.uuidString
        newSDKToken.language = "en"
        newSDKToken.merchant_identifier = Configuration.merchantID
        newSDKToken.service_command = Configuration.sdkTokenCommand
        newSDKToken.signature = createPayfortSDKAPI.getSignatureStr(newSDKToken)
        
        createSDKRequest(newSDKToken)
        
    }
    
    func createSDKRequest(_ sdkParams: PayfortSdkToken) {
        
        let parameters = createPayfortSDKAPI.getSdkTokenParams(sdkParams)
        print(parameters)
        
        createPayfortSDKAPI.request( parameters: parameters) {
            [weak self] response in
            
            if let strongSelf = self {
                strongSelf.handleCardTokenResponse(response)
            }
        }
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


}
extension PaymentMethodsTableViewController: SWTableViewCellDelegate {
    func swipeableTableViewCell(_ cell: SWTableViewCell!, didTriggerRightUtilityButtonWith index: Int) {
        switch (index) {
        case 0:
            cell.hideUtilityButtons(animated: true)
            let index = self.tableView.indexPath(for: cell)
            self.defaultCardRequest(listCard[(index?.row)!])
        case 1:
            cell.hideUtilityButtons(animated: true)
            let index = self.tableView.indexPath(for: cell)
            self.displayDeleteCard((index?.row)!)
        default:
            break
        }
    }
    func swipeableTableViewCellShouldHideUtilityButtons(onSwipe cell: SWTableViewCell) -> Bool {
        return true
    }
    
}
