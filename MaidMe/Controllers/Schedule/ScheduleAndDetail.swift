//
//  ScheduleAndDetail.swift
//  MaidMe
//
//  Created by Viktor on 3/1/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SSKeychain

class ScheduleAndDetail: BaseTableViewController {
    
    @IBOutlet weak var workerNameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var ratingView: RatingStars!
    @IBOutlet weak var totalHour: UILabel!
    @IBOutlet weak var serviceLabel: UILabel!
    @IBOutlet weak var totalPriceLabel: UILabel!
    @IBOutlet weak var payButton: UIButton!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var serviceImage: UIImageView!
    @IBOutlet weak var descriptionServiceLabel: UILabel!
    
    
    var tabbarDelegate : showTabbarDelegate?
    var navController : UINavigationController?
    var currentViewController: AnyObject?
    
    @IBOutlet weak var addMaterialButton: UIButton!
    
    var addMaterial = false
    var address = Address()
    var booking: Booking?
    var addressList = [Address]()

    
    let lockABooking = LockABookingService()
    let clearLockedBooking = ClearALockedBookingService()
    var messageCode: MessageCode?

    let createABooking = CreateABookingService()
    var paymentToken: String!
    
    let createPayfortSDKAPI = CreatePayfortSdkService()
    var newSDKToken = PayfortSdkToken()
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.hideTableEmptyCell()
       showSegueData()
        }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
            }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        
        if booking!.bookingID != nil {
            clearLockedBookingRequest()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - UI
    
    func showSegueData() {

        descriptionServiceLabel.text = self.booking?.service?.serviceDescription
        addressLabel.text = self.address.buildingName
        serviceLabel.text = booking?.service?.name
        workerNameLabel.text = booking!.workerName
        timeLabel.text = booking!.time?.getDayMonthAndHour()
        ratingView.setRatingLevel((booking!.maid?.rateAverage)!)
        let hours = Int(booking!.hours == 0 ? 0 : booking!.hours)
        if hours == 1 {
            totalHour.text = "\(hours) hour"
        } else {
            totalHour.text = "\(hours) hours"
        }
        caculTotalPrince()
        if let serviceImageString:String = booking?.service?.avatar {
            self.loadImageFromURL(serviceImageString, imageLoad: self.serviceImage)
        }
    }
    func caculTotalPrince(){
        let materialPrice = (booking!.materialPrice == 0 ? 0 : booking!.materialPrice)
       

        if addMaterial == true {
            totalPriceLabel.text = showPrice((booking!.price == 0 ? 0 : booking!.price) + materialPrice)
        } else {
            totalPriceLabel.text = showPrice(booking!.price == 0 ? 0 : booking!.price)
        }

    }
    func updateAddressList() {
        // Check the new current address is included in the list or not
        if address.addressID == nil {
            return
        }
        var isExisted = false
        for address in addressList {
            if address.addressID == self.address.addressID {
                isExisted = true
                break
            }
        }
        if !isExisted {
            addressList.insert(address, at: 0)
        }
    }
    
    
    func showPrice(_ price: Float) -> String {
        return LocalizedStrings.currency + " " + String.localizedStringWithFormat("%.2f", price)
    }
    // MARK: - IBActions

    
    @IBAction func onNextAction(_ sender: AnyObject) {
        lockABookingRequest()
    }
    
    @IBAction func addMaterialAction(_ sender: AnyObject) {
        addMaterial = !addMaterial
        if (addMaterial == true) {
            addMaterialButton.setImage(UIImage(named: ImageResources.checkedBox), for: UIControlState())
        } else {
            addMaterialButton.setImage(UIImage(named: ImageResources.uncheckBox), for: UIControlState())
        }
        caculTotalPrince()
    }
    
    @IBAction func cancel(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
        tabbarDelegate?.showTabar(false)
    }
    
    
    func showPaymentVC() {
        let storyboard = self.storyboard
        
        guard let paymentVC = storyboard?.instantiateViewController(withIdentifier: "PaymentVC") as? PaymentViewController else {
            return
        }
       
        paymentVC.bookingInfo = booking
        paymentVC.address = self.address
        if !addMaterial {
            paymentVC.bookingInfo.materialPrice = 0.0
        }
        guard let _ = currentViewController as? PaymentViewController else {
            self.navController?.pushViewController(paymentVC, animated: true)
            return
        }
    }
    
    // Payfort Request
    
    func sendPayfortRequest(){
        
        startLoadingView()
        
        newSDKToken.access_code = Configuration.accessCode
        newSDKToken.device_id = UIDevice.current.identifierForVendor?.uuidString
        newSDKToken.language = "en"
        newSDKToken.merchant_identifier = Configuration.merchantID
        newSDKToken.service_command = "SDK_TOKEN"
        newSDKToken.signature = createPayfortSDKAPI.getSignatureStr(newSDKToken)
        
        createSDKRequest(newSDKToken)
        
    }
    
    func createSDKRequest(_ sdkParams: PayfortSdkToken) {
        
        startLoadingView()
        
        let parameters = createPayfortSDKAPI.getSdkTokenParams(sdkParams)
        print(parameters)

        createPayfortSDKAPI.request(parameters: parameters) {
            [weak self] response in
            
            if let strongSelf = self {
                strongSelf.handleCreateSDKResponse(response)
            }
        }
    }
    
    func handleCreateSDKResponse(_ response: DataResponse<Any>){
        
        let requestData = PayfortRequest()
        let price : Float
        let email = SSKeychain.password(forService: KeychainIdentifier.appService, account: KeychainIdentifier.userName)
        let currentTime = Int64(Date().timeIntervalSince1970 * 1000)
        let merchant_reference = (booking?.bookingCode)! + "_" + String(format: "%0.2d", currentTime)
        
        let result = ResponseHandler.newPayfortResponseHandling(response)
        
        if result.tokenID == nil{
            
            self.showAlertView("payfort", message: "Error! Can't Create the SDK_TOKEN.", requestType: nil)
        }
        
        requestData.sdk_token = result.tokenID
        requestData.command = Configuration.authCommand
        requestData.currency = Configuration.payfortCurreny
        requestData.language = Configuration.payfortLanguage
        requestData.customer_email = email as String!
        requestData.merchant_reference = merchant_reference
        
        if addMaterial == true {
            price = (booking!.price + booking!.materialPrice)
        } else {
            price = (booking!.price)
        }
        
        createPayfortSDKAPI.sendRequestToPayFort(requestData, requestType: .payfortAuthorization, amount: NSNumber(value:price), currentVC: self, completionHandler: { (responseDic, status) in
            
            if status == "success"{

                self.paymentToken = responseDic!["sdk_token"] as? String
                self.booking?.responseDic = self.getBookingByResponse(responseDic!)
                self.createABookingRequest()
                
            }else if status == "canceled"{
                
                var response_message = responseDic!["resposne_message"]
                
                if response_message == nil {
                    response_message = responseDic!["response_message"]
                }
                
                self.showAlertView("payfort", message: (response_message as? String)!, requestType: nil)
                
            }else if status == "failed"{
                
                var response_message = responseDic!["resposne_message"]
                
                if response_message == nil {
                    response_message = responseDic!["response_message"]
                }
                
                self.showAlertView("payfort", message: (response_message as? String)!, requestType: nil)
                
            }

        })
    }
    
    // Create Booking Request API
    
    func createABookingRequest() {
        
        var parameters = [String: AnyObject]()
        
        parameters = createABooking.getCreateABookingParams(address, booking: booking!, isIncludeMaterial: addMaterial)
        print("PARAMETERS \(parameters)")
        sendRequest(parameters, request: createABooking, requestType: .createABooking, isSetLoadingView: true)
        
    }
    
    //Set Booking values by response data
    func getBookingByResponse(_ responseDic: NSDictionary) -> PayfortResponse{
        
        let responseData = PayfortResponse()

        responseData.fort_id = responseDic["fort_id"] as? String
        responseData.merchant_reference = responseDic["merchant_reference"] as? String
        responseData.expiry_date = responseDic["expiry_date"] as? String
        responseData.authorization_code = responseDic["authorization_code"] as? String
        responseData.token_name = responseDic["token_name"] as? String
        responseData.sdk_token = responseDic["sdk_token"] as? String
        responseData.customer_email = responseDic["customer_email"] as? String
        responseData.eci = responseDic["eci"] as? String
        responseData.payment_option = responseDic["payment_option"] as? String
        responseData.card_number = responseDic["card_number"] as? String
        responseData.customer_ip = responseDic["customer_ip"] as? String
        responseData.currency = responseDic["currency"] as? String
        responseData.amount = responseDic["amount"] as? String
        responseData.command = responseDic["command"] as? String
        
        return responseData
    
    }
    
    // MARK: - API
    func lockABookingRequest() {
        let parameters = lockABooking.getLockABookingParams(booking!, address: address, isIncludeMaterial: addMaterial)
        print("Booking param:", parameters)
        sendRequest(parameters, request: lockABooking, requestType: .lockABooking, isSetLoadingView: true)
    }
    
    func clearLockedBookingRequest() {
        guard let bookingID = booking!.bookingID else {
            return
        }
        
        let parameters = clearLockedBooking.getParams(bookingID)
        sendRequest(parameters, request: clearLockedBooking, requestType: .clearLockedBooking, isSetLoadingView: false)
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
            print("sendRequets")
            // Set loading view center
            if isSetLoadingView {
                setLoadingUI(.white, color: UIColor.white)
                self.setRequestLoadingViewCenter(payButton)
            }
            else {
                setDefaultUIForLoadingIndicator()
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
        
        if requestType == .clearLockedBooking && result.messageCode != .success {
            return
        }
        if result.messageCode != .success {
            // Show alert
            handleResponseError(result.messageCode, title: LocalizedStrings.internalErrorTitle, message: result.messageInfo, requestType: requestType)
            
            if let error = result.messageCode {
                messageCode = error
            }
            
            return
        }
        
        if requestType == .lockABooking {
            handleLockABookingResponse(result, requestType: .lockABooking)
        }
        else if requestType == .clearLockedBooking {
            booking!.bookingID = nil
        } else if requestType == .createABooking {
            
            booking!.bookingCode = createABooking.getBookingCode(result.body)
            self.performSegue(withIdentifier: SegueIdentifiers.showBookingSummary, sender: self)
            guard let reminderTime = booking!.time?.addingTimeInterval(-30.0 * 60.0) else { return }
            NotificationManager.createReminderNotification(booking!.workerName ?? "", fireDate: reminderTime)
            
        }
    }
    
    func handleLockABookingResponse(_ result: ResponseObject, requestType: RequestType) {
        if let bookingID = result.body?["_id"] {
            booking!.bookingID = bookingID.stringValue
            
            if let BookingCode = result.body?["booking_code"]{
                
                booking?.bookingCode = BookingCode.stringValue
                
            }
            
            sendPayfortRequest()

        }
        else {
            // Handle error when booking ID is nil
            showAlertView(LocalizedStrings.internalErrorTitle, message: LocalizedStrings.internalErrorMessage, requestType: .lockABooking)
            return
        }
        

        
    }
    
    override func handleAlertViewAction(_ requestType: RequestType?) {
        self.dismiss(animated: true, completion: nil)
    }
    
        // MARK: - Handle UIAlertViewAction
    override func handleTryAgainTimeoutAction(_ requestType: RequestType) {
        if requestType == .lockABooking {
            self.lockABookingRequest()
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 5 {
            if self.view.frame.size.height > 648 {
                return (self.view.frame.size.height - 568)
            } else {
                return 80
            }
        }
        return 70
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == SegueIdentifiers.showBookingAddress {
            guard let destination = segue.destination as? BookingAddressTableViewController else {
                return
            }
            
            destination.addressList = addressList
            destination.currentAddress = (address.addressID == nil ? nil : address)
            
            if address.addressID == nil {
                print("Default address nil")
            }
        }else if segue.identifier == SegueIdentifiers.showBookingSummary {
            guard let destination = segue.destination as? BookingSummaryViewController else {
                return
            }
            
            booking?.address = address
            destination.pushOderDelegate = self
            destination.bookingInfo = booking!
            
        }
    }

}


extension ScheduleAndDetail: PushToOderBookingDelegate {
    func pushToOrderBooking(_ flag: Bool){
        if flag == true {
            UIView.animate(withDuration: 0.3, animations: {
                self.dismiss(animated: true, completion: nil)
            })
        }
    }
}
