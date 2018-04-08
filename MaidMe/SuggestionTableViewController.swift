//
//  SuggestionTableViewController.swift
//  MaidMe
//
//  Created by Viktor on 1/11/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SSKeychain
import RealmSwift
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


var isReloadSuggestion : Bool?
class SuggestionTableViewController: BaseTableViewController {
    
    @IBOutlet weak var noResultLabel: UILabel!
    
    
    var suggestionWorkerAPI = FetchSuggestedWorkerService()
    let fetchAllAddresses = FetchAllBookingAddressesService()
    let getCustomerDetailsAPI = GetCustomerDetailsService()
    var addressList = [Address]()
    
    var selectedAddress: Address?
    var messageCode : MessageCode?
    var sugesstionWorkerParams : [String : AnyObject]?
    var suggestedWorkers : [SuggesstedWorker]?
    var selectedIndex : Int?
    var ratingList = [Rating]()
    var customer: Customer!
    var timesShowRatingAndComment = 0
    var indexItemBookingList = 0
    var isPopView: Bool?
    var isObserver: Bool?
    var refreshItemControl: UIRefreshControl!
    @IBOutlet weak var loadingAddressBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isPopView = false
		
		let realm = try! Realm()
		let cachedAddresses = realm.objects(Address.self)
		if cachedAddresses.count > 0 {
			addressList = Array(cachedAddresses)
		}
		
        fetchAllBookingAddressesRequest()
        fetchCustomerDetailsRequest()
        setupRefreshControl()
        refreshItemControl.addTarget(self, action: #selector(SuggestionTableViewController.Refresh), for: UIControlEvents.valueChanged)
		
		if let cachedAddressName: String = UserDefaults.standard.string(forKey: "cachedAddressName"){
			self.navTitleView.buildingNameLabel.text = cachedAddressName
		}
    }
    @objc func Refresh(){
        sendFetchSuggestionWorkerRequest()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.hideTableEmptyCell()
        setNoResultLabelFrame()
        setDefaultUIForLoadingIndicator()
        setupMenuAddressButton(btn: loadingAddressBtn)
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.navigationBar.isHidden = false
        self.navTitleView.showListAddressButton.addTarget(self, action: #selector(showAddressMenu), for: .touchUpInside)
        let topView = UIView()
        topView.backgroundColor = UIColor(red: 91/255, green: 194/255, blue: 209/255, alpha: 1)
        topView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 1)
        self.tabBarController?.tabBar.addSubview(topView)
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isPopView = true
        isObserver = false
        isReloadSuggestion = false
    }
    override func viewDidAppear(_ animated: Bool) {
        if customerSelectedAddress != nil && customerSelectedAddress?.addressID != selectedAddress?.addressID  {
           
            selectedAddress = customerSelectedAddress
            if let buildingName = selectedAddress?.buildingName {
                self.navTitleView.buildingNameLabel.text = cutString(buildingName)
            }
            if isPopView != false{
                sendFetchSuggestionWorkerRequest()
            }
        }
		
        if isReloadSuggestion == true {
            updateSuggestion()
        }
     
    }
    
    // MARK: - UI
    
    func setupRefreshControl() {
        refreshItemControl = UIRefreshControl()
        refreshItemControl.backgroundColor = UIColor(red: 173.0 / 255.0, green: 185.0 / 255.0, blue: 202.0 / 255.0, alpha: 0.3)
        refreshItemControl.tintColor = UIColor.lightGray
        tableView.addSubview(refreshItemControl)
    }
    func stopRefreshing() {
        if refreshItemControl.isRefreshing {
            refreshItemControl.endRefreshing()
        }
    }

    override func setDefaultUIForLoadingIndicator() {
        self.loadingIndicator.activityIndicatorViewStyle = .whiteLarge
        self.loadingIndicator.color = UIColor.black
        if let window = UIApplication.shared.keyWindow {
            self.loadingIndicator.center = window.center
            window.addSubview(self.loadingIndicator)
        }
    }
    func updateSuggestion(){
        isObserver = true
        isPopView = false
        fetchAllBookingAddressesRequest()
    }
    
    @objc func showAddressMenu() {
        if addressList.count > 1{
        let storyboard = self.storyboard
        guard let addressMenu = storyboard?.instantiateViewController(withIdentifier: StoryboardIDs.customerAddressMenu) as? AddressMenu else {
            return
        }
        addressMenu.suggestedWorkerVC = self
        addressMenu.addressList = self.addressList
        addressMenu.navController = self.navigationController
        addressMenu.currentViewController = self
        addressMenu.view.backgroundColor = .clear
        addressMenu.modalPresentationStyle = .overCurrentContext
        self.present(addressMenu, animated: true, completion: nil)
        }
    }

    
    func selectAddressFromAddressMenu(_ address : Address) {
        self.selectedAddress = address
        if let buildingName: String = selectedAddress?.buildingName! {
                self.navTitleView.buildingNameLabel.text = cutString(buildingName)
        }
        self.selectedAddress = address
        sugesstionWorkerParams = suggestionWorkerAPI.getSuggestionWorkerParams(address)
        sendFetchSuggestionWorkerRequest()
    }
    
    func setNoResultLabelFrame() {
    noResultLabel.frame = CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: self.tableView.frame.size.height - 44)
    }
    func sendFetchSuggestionWorkerRequest () {
        sugesstionWorkerParams = suggestionWorkerAPI.getSuggestionWorkerParams((selectedAddress)!)
        sendRequest(sugesstionWorkerParams, request: suggestionWorkerAPI, requestType: .fetchSugesstedWorker, isSetLoadingView: true, button: nil)
    }
    func fetchCustomerDetailsRequest() {
        sendRequest(nil, request: getCustomerDetailsAPI, requestType: .fetchCustomerDetails, isSetLoadingView: false, button: nil)
    }
    func fetchAllBookingAddressesRequest() {
        sendRequest(nil, request: fetchAllAddresses, requestType: .fetchAllBookingAddresses, isSetLoadingView: false,button: nil)
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
//                strongSelf.handleAPIResponse()
                strongSelf.handleResponse(response, requestType: requestType)
            }
        }
    }
 
    


    func handleResponse(_ response: DataResponse<Any>, requestType: RequestType) {
        let result = ResponseHandler.responseHandling(response)
        //end refresh
        stopRefreshing()
		if suggestedWorkers?.count > 0 || (requestType == .fetchAllBookingAddresses && addressList.count == 0){
			stopLoadingView()
		}
        if result.messageCode != MessageCode.success {
            // Show alert
            print("ERROR")
            print("msssage info \(result.messageInfo)")
            handleResponseError(result.messageCode, title: LocalizedStrings.internalErrorTitle, message: result.messageInfo, requestType: requestType)
            if let error = result.messageCode {
                messageCode = error
            }
            return
        }
        if requestType == .fetchAllBookingAddresses {
            handleFetchAllBookingAddressesResponse(result, requestType: .fetchAllBookingAddresses)
        }
        else if  requestType == .fetchSugesstedWorker {
            handleFetchSuggestedWorkersResponse(result, requestType: .fetchSugesstedWorker)
        } else if requestType == .fetchCustomerDetails {
            handleFetchCustomerDetailsResponse(result, requestType: .fetchCustomerDetails)
        }
		
    }
    
    func handleFetchSuggestedWorkersResponse(_ result: ResponseObject, requestType: RequestType) {
        setUserInteraction(true)
        suggestedWorkers = suggestionWorkerAPI.getSuggesstedWorkerList(result.body!)
		stopLoadingView()
        if suggestedWorkers == nil || suggestedWorkers?.count == 0 {
            showNoResultLabel(true)
        }
        else {
            showNoResultLabel(false)
        }
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
    }
    func handleFetchCustomerDetailsResponse(_ result: ResponseObject, requestType: RequestType) {
        guard let body = result.body else {
            return
        }
        
        customer = Customer(customerDic: body)
        saveCustomerInfo()
        
    }
    func saveCustomerInfo() {
        let phoneNumber = customer.phone
        let userName = customer.email
        if let customerName: String = customer.firstName! + " " + customer.lastName! {
            SSKeychain.setPassword(customerName, forService: KeychainIdentifier.appService, account: KeychainIdentifier.customerName)
        }
        SSKeychain.setPassword(phoneNumber, forService: KeychainIdentifier.appService, account: KeychainIdentifier.phoneNumber)
        SSKeychain.setPassword(userName, forService: KeychainIdentifier.appService, account: KeychainIdentifier.userName)
    }
    func handleFetchAllBookingAddressesResponse(_ result: ResponseObject, requestType: RequestType) {
        guard let list = result.body else {
            return
        }
        addressList = fetchAllAddresses.getAddressList(list)
        if addressList.count == 1{
            self.navTitleView.dropDownImage.image = UIImage(named: "")
        } else {
            self.navTitleView.dropDownImage.image = UIImage(named: "dropIcon")
        }
       
        for address in addressList {
            if (address.isDefault == true) {
                self.selectedAddress = address
            }
        }
        
        if let buildingNAME: String = selectedAddress?.buildingName{
            self.navTitleView.buildingNameLabel.text = cutString(buildingNAME)
        }
        sendFetchSuggestionWorkerRequest()
    }
    func showNoResultLabel(_ flag: Bool) {
        if flag {
            tableView.addSubview(noResultLabel)
            return
        }
        noResultLabel.removeFromSuperview()
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if suggestedWorkers?.count == 0 {
            return tableView.frame.size.height - 40
        }
        return super.tableView(self.tableView, heightForRowAt: indexPath)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let suggestedWorkers = suggestedWorkers else {
            return 0
        }
        return (suggestedWorkers.count)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellID = "suggestedWorkerCell"
        var cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? SuggestedWorkerCell
        cell?.backgroundColor = UIColor.white
        if cell == nil {
            cell = SuggestedWorkerCell(style: UITableViewCellStyle.default, reuseIdentifier: cellID)
        }
        if suggestedWorkers != nil {
            cell?.showWorkerInfo(suggestedWorkers![indexPath.row])
        }
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        self.tabBarController?.tabBar.isHidden = true
        self.performSegue(withIdentifier: SegueIdentifiers.showScheduleDetail, sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueIdentifiers.showScheduleDetail {
            guard let destination = segue.destination as? ScheduleAndDetail else {
                return
            }
            guard let selectedIndex = selectedIndex else {
                return
            }
            guard let suggestedWorkers = suggestedWorkers else {
                return
            }
            let suggestedWorker = suggestedWorkers[selectedIndex]
            
            let avatar = suggestedWorker.avartar
            let workerName = suggestedWorker.firstName! + " " + suggestedWorker.lastName!
            
            let bookingPrice = suggestedWorker.price
            let bookingMaterialPrice = suggestedWorker.materialPrice
            let workerID = suggestedWorker.workerID
            let time = suggestedWorker.availableTime
            destination.tabbarDelegate = self
            destination.booking = Booking(bookingID: nil, workerName: workerName, workerID: workerID, time: Date(timeIntervalSince1970: time / 1000), service: suggestedWorker.serviceType, workingAreaRef: nil, hours: suggestedWorker.hour, price: bookingPrice, materialPrice: bookingMaterialPrice, payerCard: nil, avartar: avatar,maid: Worker(suggestedWorker: suggestedWorker), responseDic: nil)
            destination.address = selectedAddress!
            destination.navController = self.navigationController
            destination.currentViewController = self
        }
        if segue.identifier == SegueIdentifiers.giveCommentAndRating {
            guard let commentAndRatingVC = segue.destination as? GiveRatingTableViewController else {
                return
            }
            commentAndRatingVC.listBookingDoneWithoutRating2 = ratingList
            commentAndRatingVC.timesShow = timesShowRatingAndComment
            commentAndRatingVC.indexItemShow = indexItemBookingList
            commentAndRatingVC.delegate = self
        }
    }
}
extension SuggestionTableViewController: showTabbarDelegate,UITabBarDelegate {
    func showTabar(_ visable: Bool) {
        self.tabBarController?.tabBar.isHidden = visable
    }
}
extension SuggestionTableViewController: GiveRatingTableViewControllerDelegate {
    func didDismissRatingAndCommentBooking(_ isSubmitted: Bool) {
        if isSubmitted {
            timesShowRatingAndComment = timesShowRatingAndComment - 1
            indexItemBookingList = indexItemBookingList + 1
//            prepareToRatingAndComment()
        }
        else {
        }
    }
}
