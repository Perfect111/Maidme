//
//  PaymentViewController.swift
//  MaidMe
//
//  Created by Viktor on 3/5/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class PaymentViewController: BaseTableViewController {

    @IBOutlet weak var paymentHeaderCell: PaymentHeaderCell!
    @IBOutlet weak var cardSumaryCell: CardViewCell!
    @IBOutlet weak var paymentInfoCell: PaymentInfoCell!
    @IBOutlet weak var datePickerCell: DatePickerCell!
//    @IBOutlet weak var countryCell: CountryCell!
    @IBOutlet weak var storePaymentSettingCell: StoredPaymentSettingCell!
    @IBOutlet weak var payActionCell: PayActionCell!
    @IBOutlet weak var totalPaymentCell: TotalPaymentCell!
    
    var selectedCard: Card?
    var newCard = Card()
    var cardList = [Card]()
    
    var datePickerHidden = true
    let datePickerIndex = 2
    var expiryDate: Date!
    var isSaveChecked: Bool = false
    var isEnablePayButton = false
    var bookingInfo: Booking!
    var address = Address()
    
    var messageCode: MessageCode?
    let createTokenCard = CreateNewTokenCardService()
    let createCustomerCard = CreateCustomerCardService()
    let lockABooking = LockABookingService()
    let fetchAllCard = FetchAllCardsService()
    let createABooking = CreateABookingService()
    var paymentToken: String!
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showSegueData()
        
        // Fetch cards list
        fetchAllCardsRequest()
        self.bookingInfo.address = self.address
        self.navigationItem.title = "PAYMENT"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.hideBackbutton(true)
        self.tabBarController?.tabBar.isHidden = true
        checkFullFillRequiredFields(selectedCard == nil ? newCard : selectedCard)
        tableView.hideTableEmptyCell()
        updateCellLine()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UI
    
    func updateCellLine() {
        tableView.removeSeparatorLineInset([paymentHeaderCell, datePickerCell])
        
        let cell1 = self.tableView.cellForRow(at: IndexPath(row: 1, section: 0))
        let cell2 = self.tableView.cellForRow(at: IndexPath(row: 2, section: 0))
        
        
        let cell4 = self.tableView.cellForRow(at: IndexPath(row: 5, section: 0))
        let cell5 = self.tableView.cellForRow(at: IndexPath(row: 6, section: 0))
        
        guard let tableCell1 = cell1, let tableCell2 = cell2, let tableCell4 = cell4, let tableCell5 = cell5 else {
            return
        }
        
        self.tableView.removeSeparatorLine([tableCell1, tableCell2, tableCell4, tableCell5])
        
        datePickerCell.datePicker.monthPickerDelegate = self

    }
    
    func resetPaymentInfor() {
        newCard = Card()
        paymentInfoCell.resetCardInfor()
        datePickerCell.resetDatePicker()
        
    }
    
    func showSegueData() {
        totalPaymentCell.setPrice(bookingInfo.price + bookingInfo.materialPrice)
        
    }
    
    func getDefaultCard(_ cardList: [Card]) -> Card? {
        for card in cardList {
            if card.isDefault == true {
                return card
            }
        }
        
        return nil
    }
    
    // MARK: - Unwind segues
    
    @IBAction func onUpdateBillingAddressAction(_ segue: UIStoryboardSegue) {
        tableView.reloadData()
    }
    
    @IBAction func onChangeCardAction(_ segue: UIStoryboardSegue) {
        tableView.reloadData()
        
        guard let card = selectedCard else {
            return
        }
        
        cardSumaryCell.setCardInfo(card)
    }
    
    // MARK: - Time picker
    
    func toggleDatepicker() {
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    func datePickerChanged(_ date: Date, dateFormat: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        
        expiryDate = date
        newCard.expiryMonth = expiryDate.getMonth()
        newCard.expiryYear = expiryDate.getYear()
        checkFullFillRequiredFields(newCard)
        
        paymentInfoCell.expiryDateTextField.text = expiryDate.getStringFromDate(DateFormater.monthYearFormat)
    }
    
    @IBAction func onPickTimeAction(_ sender: AnyObject) {
        dismissKeyboard()
    }
    
    func showHideDatePicker() {
        datePickerHidden = !datePickerHidden
        toggleDatepicker()
    }
    
    @IBAction func backSearchResult(_ sender: AnyObject?) {
        self.navigationController?.popViewController(animated: true)
    }

    fileprivate func checkFullFillRequiredFields(_ card: Card?) {
        var isFullFilled = true
        
        if let card = card {
            if selectedCard == nil {
                isFullFilled = Validation.isFullFillRequiredTexts([card.number, (card.expiryMonth == 0 ? "" : "\(card.expiryMonth)"), card.cvv])
            }
        }
        
        isEnablePayButton = isFullFilled
        ValidationUI.changeRequiredFieldsUI(isEnablePayButton, button: payActionCell.payButton)
    }
    
    // MARK: - Textfield delegate
    
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
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if !datePickerHidden {
            showHideDatePicker()
        }
        
        return true
    }
    
    @IBAction func onTextFieldEditingChangedAction(_ sender: AnyObject) {
        guard let textField = sender as? UITextField else {
            return
        }
        
        if textField.tag == 100 {
            // Name
            newCard.ownerName = StringHelper.trimBeginningWhiteSpace(textField.text!)
        }
        else if textField.tag == 101 {
            newCard.number = StringHelper.trimWhiteSpace(textField.text!)
			if CardHelper.getCardLogo(textField.text!, isSmall: true) != nil {
				if CardHelper.getCardLogo(textField.text!, isSmall: true) != nil {
					newCard.cardLogoData = UIImagePNGRepresentation(CardHelper.getCardLogo(textField.text!, isSmall: true)!)
				}	
			}
            paymentInfoCell.showPaymentInfo(newCard)
        }
        else if textField.tag == 102 {
            newCard.cvv = textField.text
        }
        
        checkFullFillRequiredFields(newCard)
    }
    
    // MARK: - Save action
    
    @IBAction func onTickCheckboxAction(_ sender: AnyObject) {
        isSaveChecked = !isSaveChecked
        print(isSaveChecked)
        storePaymentSettingCell.updateButtonImage(isSaveChecked)
    }
    
    @IBAction func onPayAction(_ sender: AnyObject) {
        dismissKeyboard()
        
        ValidationUI.changeRequiredFieldsUI(false, button: payActionCell.payButton)
        startLoadingView()
        if selectedCard == nil {
            let validationResult = CardHelper.isValidData(newCard)
            
            if !validationResult.isValid {
                // Show invalid alert
                stopLoadingView()
                showAlertView(validationResult.title, message: validationResult.message, requestType: nil)
                return
            }
            
            let card = (selectedCard == nil ? newCard : selectedCard)
            
           /* let startCard = createTokenCard.startCard(card!)
            let price = (bookingInfo.price + bookingInfo.materialPrice)
            createTokenCard.getCardToken(startCard, amount: NSNumber(value: price as Float), completionHandler: { (token, error) in
                guard let token = token else {
                    self.stopLoadingView()
                    self.showAlertView(validationResult.title, message: validationResult.message, requestType: nil)
                    return
                }
                
                // Book with selected card
                self.paymentToken = token
                if self.isSaveChecked {
                    self.createCustomerCardRequest()
                }else {
                    self.createABookingRequest()
                }
            })*/

        }else {
            // Book with selected card
            isSaveChecked = true
            createABookingRequest()
        }
    }
    
    // MARK: - API
    func getCardTokenRequest() {
        let parameters = createTokenCard.getCardTokenParams(selectedCard, newCard: newCard)
        sendRequest(parameters as [String : AnyObject], request: createTokenCard, requestType: .createCardToken, isSetLoadingView: true)
    }
    
    func createCustomerCardRequest() {
        let parameters = createCustomerCard.getCustomerCardParams(paymentToken)
        sendRequest(parameters, request: createCustomerCard, requestType: .createCustomerCard, isSetLoadingView: true)
    }
    
    func fetchAllCardsRequest() {
        sendRequest(nil, request: fetchAllCard, requestType: .fetchAllCard, isSetLoadingView: false)
    }
    
    func createABookingRequest() {
        var parameters = [String: AnyObject]()
        
        parameters = createABooking.getCreateABookingParams(address, booking: bookingInfo, isIncludeMaterial: true)
        print("PARAMETERS \(parameters)")
        sendRequest(parameters, request: createABooking, requestType: .createABooking, isSetLoadingView: true)

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
                self.setRequestLoadingViewCenter(payActionCell.payButton)
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
        if requestType == .createCardToken {
            handleCardTokenResponse(response)
            return
        }
        else {
            handleCardResponse(response, requestType: requestType)
        }
    }
    
    func handleCardTokenResponse(_ response: DataResponse<Any>) {
        let result = ResponseHandler.payfortResponseHandling(response)
        
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
        if isSaveChecked {
            createCustomerCardRequest()
        } else {
            createABookingRequest()
        }
    }
    
    func handleCardResponse(_ response: DataResponse<Any>, requestType: RequestType) {
        let result = ResponseHandler.responseHandling(response)
        if result.messageCode != MessageCode.success {
            // Show alert
            handleResponseError(result.messageCode, title: LocalizedStrings.internalErrorTitle, message: result.messageInfo, requestType: requestType)
            
            if let error = result.messageCode {
                messageCode = error
            }
            
            return
        }
        
        if requestType == .createCustomerCard {
            let cardID = result.body?["id"]
            newCard.cardPaymentID = cardID?.stringValue
            
            // Send book request.
            createABookingRequest()
        }
        
        if requestType == .fetchAllCard {
            handleCardListResponse(result.body)
        }
        
        if requestType == .createABooking {
            bookingInfo.bookingCode = createABooking.getBookingCode(result.body)
            self.performSegue(withIdentifier: SegueIdentifiers.showBookingSummary, sender: self)
            guard let reminderTime = bookingInfo.time?.addingTimeInterval(-30.0 * 60.0) else { return }
            NotificationManager.createReminderNotification(bookingInfo.workerName ?? "", fireDate: reminderTime)
        }
    }
    
    func handleCardListResponse(_ responseBody: JSON?) {
        guard let list = responseBody else {
            return
        }
        
        cardList = fetchAllCard.getCardList(list)
        for card in cardList {
            if card.isDefault == true {
                selectedCard = card
                break
            }
        }
        
        // Reload table view
        tableView.beginUpdates()
        
        if selectedCard != nil {
            cardSumaryCell.cardView.showCardInfo(selectedCard!)
        }
        else {
            newCard = Card()
        }
        
        tableView.endUpdates()
        
        
        checkFullFillRequiredFields(selectedCard == nil ? newCard : selectedCard)
    }
    
    // MARK: - Handle UIAlertViewAction
    
    override func handleTryAgainTimeoutAction(_ requestType: RequestType) {
        if requestType == .createCardToken {
            self.getCardTokenRequest()
        }
        else if requestType == .createCustomerCard {
            self.createCustomerCardRequest()
        }
        else if requestType == .fetchAllCard {
            self.fetchAllCardsRequest()
        }
        else if requestType == .createABooking {
            self.createABookingRequest()
        }
    }
    
    override func handleAlertViewAction(_ requestType: RequestType?) {
        if messageCode == .bookingTimeout && requestType == .createABooking {
            self.performSegue(withIdentifier: SegueIdentifiers.backToAvailableWorker, sender: self)
        }
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 1 {
            if selectedCard == nil {
                return 0
            }
        }
        
        if indexPath.row == 2 || indexPath.row == 4  {
            if selectedCard != nil {
                return 0
            }
        }
        if indexPath.row == 3 {
            if datePickerHidden {
                return 0
            }
        }
        if indexPath.row == 6 {
            if selectedCard != nil {
                if self.view.frame.size.height > 440 {
                    return (self.view.frame.height - 350)
                } else {
                    return 90
                }
            } else {
                if self.view.frame.size.height > 485 {
                    return (self.view.frame.size.height - 390)
                } else {
                    return 90
                }
            }
        }
        
        return super.tableView(tableView, heightForRowAt: indexPath)
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "showSelectExpiryDateView" {
            guard let destination = segue.destination as? SelectExprixeDateView else{
                return
            }
            destination.delegate = self
        }
        
        
        if segue.identifier == SegueIdentifiers.showBookingSummary {
            guard let destination = segue.destination as? BookingSummaryViewController else {
                return
            }
            
            if selectedCard == nil && newCard.number != "" {
                newCard.lastFourDigit = newCard.getLastFourDigit()
            }
            
            bookingInfo.payerCard = (selectedCard == nil ? newCard : selectedCard)
            destination.pushOderDelegate = self
            destination.bookingInfo = bookingInfo
//            destination.navController = self.navigationController
//            destination.currentViewcontroller = self
        }
        
        if segue.identifier == SegueIdentifiers.showCardList {
            guard let destination = segue.destination as? ListCardTableViewController else {
                return
            }
            
            destination.cardList = cardList
        }
    }
    
}
extension PaymentViewController: PushToOderBookingDelegate {
    func pushToOrderBooking(_ flag: Bool){
        if flag == true {
            UIView.animate(withDuration: 0.3, animations: {
                self.tabBarController?.selectedIndex = 2
                self.navigationController?.popToRootViewController(animated: true)
            })
        }
    }
}

extension PaymentViewController: SelectExpiryDateDelegate {
    func showExpiryDate(_ expiryDate: Date) {
        self.expiryDate = expiryDate
        newCard.expiryMonth = expiryDate.getMonth()
        newCard.expiryYear = expiryDate.getYear()
        checkFullFillRequiredFields(newCard)
        paymentInfoCell.expiryDateTextField.text = expiryDate.getStringFromDate(DateFormater.monthYearFormat)
    }
    
}

extension PaymentViewController: MAKMonthPickerDelegate {
    func monthPickerDidChangeDate(_ picker: MAKMonthPicker) {
        if picker.restorationIdentifier == "expirydatePicker" {
            datePickerChanged(picker.date, dateFormat: DateFormater.monthYearFormat)
        }
    }
}
