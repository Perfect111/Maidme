//
//  SearchResultsViewController.swift
//  MaidMe
//
//  Created by Viktor on 12/8/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit
import SWTableViewCell
import Alamofire
import EasyTipView

var isReloadSearchResult: Bool?
class SearchResultsViewController: BaseTableViewController {
    
    
    @IBOutlet weak var noResultLabel: UILabel!
    @IBOutlet weak var menuHomeButton: UIButton!
    
    var selectedIndex: Int?
    var availableWorkerParams: [String: AnyObject]?
    var availableWorkers: [Worker]?
    var messageCode: MessageCode?
    let availableWorkerAPI = FetchAvailableWorkerService()
    let rebookAPI = RebookGetTimeOptionsService()
    var isRebook: Bool?
    var rebookParams: [String: AnyObject]?
    var workService: WorkingService?
    var serviceList = [WorkingService]()
    var booking: Booking?
    var hour : Int?
    var searchTime:Double?
    var asap : Bool?
    var selectedAddress: Address?
     var isMoveFromSearchDetails : Bool?
    var isMoveFromRebook : Bool?
    var addressList = [Address]()
    var customer: Customer?
	var tipView : EasyTipView?
	
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customBackButton()
        guard let _ = isRebook else {
            sendFetchAvailableWorkerRequest()
            return
        }
        // Rebook a maid
        rebookParams = rebookAPI.getParams(booking!, addressID: selectedAddress!.addressID)
        rebookAMaidRequest()
		
	}
	
	override func scrollViewDidScroll(_ scrollView: UIScrollView) {
		tipView?.dismiss()
	}
	
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if addressList.count == 1{
            self.navTitleView.dropDownImage.image = UIImage(named: "")
        } else {
            self.navTitleView.dropDownImage.image = UIImage(named: "dropIcon")
        }
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        setupView()
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isReloadSearchResult == true && isMoveFromSearchDetails != true && isMoveFromRebook != true {
            updateAddressObeserver()
        }
        }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isReloadSearchResult = false
        isMoveFromRebook = false
        isMoveFromSearchDetails = false
            }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    deinit {
    }
    func updateAddressObeserver() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func setupView() {
        setNoResultLabelFrame()
        setupTableView()
        setupMenuAddressButton(btn: menuHomeButton)
        setDefaultUIForLoadingIndicator()
        self.navTitleView.showListAddressButton.addTarget(self, action: #selector(handlerCustomerAddressMenu), for: .touchUpInside)
        if let buildingName: String = selectedAddress?.buildingName! {
            self.navTitleView.buildingNameLabel.text = cutString(buildingName)        }
        tableView.hideTableEmptyCell()
        self.hideBackbutton(false)
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.isTranslucent = false
         self.view.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
    
    }
    
    // MARK: - UI
    func setNoResultLabelFrame() {
//        noResultLabel.frame = CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), CGRectGetHeight(noResultLabel.frame))
        noResultLabel.frame = CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: self.tableView.frame.size.height - 44)
    }
    func setupTableView(){
        self.tableView.separatorStyle = .none
    }
    override func setDefaultUIForLoadingIndicator() {
        self.loadingIndicator.activityIndicatorViewStyle = .whiteLarge
        self.loadingIndicator.color = UIColor.black
        if let window = UIApplication.shared.keyWindow {
            self.loadingIndicator.center = window.center
            window.addSubview(self.loadingIndicator)
        }
    }
    // MARK: - API
    
    func sendFetchAvailableWorkerRequest() {
        print("Available params: ", availableWorkerParams)
        sendRequest(availableWorkerParams, request: availableWorkerAPI, requestType: .fetchAvailableWorker, isSetLoadingView: true, view: nil)
    }
    
    func rebookAMaidRequest() {
        print("Rebook params: ", rebookParams)
        sendRequest(rebookParams, request: rebookAPI, requestType: .rebookAMaid, isSetLoadingView: true, view: nil)
        
    }
    
    func sendRequest(_ parameters: [String: AnyObject]?,
                     request: RequestManager,
                     requestType: RequestType,
                     isSetLoadingView: Bool, view: UIView?) {
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
        let result = ResponseHandler.responseHandling(response)
        if result.messageCode != MessageCode.success {
            // Show alert
            handleResponseError(result.messageCode, title: LocalizedStrings.internalErrorTitle, message: result.messageInfo, requestType: requestType)
            if let error = result.messageCode {
                messageCode = error
            }
            if let _ = availableWorkers {
                availableWorkers = nil
                tableView.reloadData()
            }
            showNoResultLabel(true)
            return
        }
        setUserInteraction(true)
        if requestType == .fetchAvailableWorker || requestType == .rebookAMaid {
            handleFetchAvailableWorkersResponse(result, requestType: .fetchAvailableWorker, response: response)
        }
    }
    
	func handleFetchAvailableWorkersResponse(_ result: ResponseObject, requestType: RequestType, response: DataResponse<Any>) {
        setUserInteraction(true)
        availableWorkers = availableWorkerAPI.getWorkerList(result.body!)
		var isSuggested = 0
		if response.data != nil {
			let jsonData: Data = response.data!
			let jsonDict = try! JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as! NSDictionary
			if jsonDict.allKeys.count > 0 {
                let messageInfo = jsonDict.value(forKey: "messageInfo") as! NSDictionary
				isSuggested = messageInfo.value(forKey: "isSuggested") as! Int
			}
		}

		if isSuggested == 1 {
			var preferences = EasyTipView.Preferences()
			preferences.drawing.font = UIFont.systemFont(ofSize: 13)
			preferences.drawing.foregroundColor = UIColor.white
			preferences.drawing.backgroundColor = UIColor(red:0.27, green:0.68, blue:0.75, alpha:1.00)
			preferences.drawing.arrowPosition = EasyTipView.ArrowPosition.top
			EasyTipView.globalPreferences = preferences
			tipView = EasyTipView(text: "We couldn't find available options for the selected time, but here is what we recommend.", preferences: preferences)
			tipView?.show(animated: true, forView: self.navigationItem.titleView!, withinSuperview: self.navigationController?.view)
		}
		
        if availableWorkers == nil || availableWorkers?.count == 0 {
            showNoResultLabel(true)
        }
        else {
            showNoResultLabel(false)
        }

        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
    }
    func showNoResultLabel(_ flag: Bool) {
        if flag {
            tableView.addSubview(noResultLabel)
            return
        }
        
        noResultLabel.removeFromSuperview()
    }
	
	
    
    // MARK: - Handle UIAlertViewAction
    
    override func handleTryAgainTimeoutAction(_ requestType: RequestType) {
        if requestType == .fetchAvailableWorker {
            self.sendFetchAvailableWorkerRequest()
        }
    }
    override func handleAlertViewAction(_ requestType: RequestType?) {
        if requestType == .fetchAvailableWorker {
            setUserInteraction(true)
        }
    }
    override func handleTimeoutOKAction(_ requestType: RequestType) {
        if requestType == .fetchAvailableWorker {
            setUserInteraction(true)
        }
    }
    // MARK : - Home Menu
    @IBAction func handlerCustomerAddressMenu(_ sender: AnyObject) {
        self.showCustomerAddressMenu()
    }
    func showCustomerAddressMenu() {
        if addressList.count > 1 {
        let storyboard = self.storyboard
        guard let addressMenu = storyboard?.instantiateViewController(withIdentifier: StoryboardIDs.customerAddressMenu) as? AddressMenu else {
            return
        }
        addressMenu.searchResultsVC = self
        addressMenu.addressList = self.addressList
        addressMenu.navController = self.navigationController
        addressMenu.currentViewController = self
        addressMenu.view.backgroundColor = .clear
        addressMenu.modalPresentationStyle = .overCurrentContext
            self.present(addressMenu, animated: false, completion: nil)
        }

    }
    func fetchSearchResultsWithAreaId(_ areaId: String,address: Address?){
        if let buildingName: String = address?.buildingName! {
            self.navTitleView.buildingNameLabel.text = cutString(buildingName)
        }
        self.selectedAddress = address
        if isRebook != true {
            availableWorkerParams = ["service_id": getServiceIDFromService(self.workService?.name, list: self.serviceList) as AnyObject, "asap": asap! as AnyObject, "date_time": self.searchTime! as AnyObject, "area_id": areaId as AnyObject, "hours": self.hour! as AnyObject]
            sendFetchAvailableWorkerRequest()
            self.tableView.reloadData()
        } else {
            print("REBOOKING")
            booking =  Booking(bookingID: nil, workerName: nil, workerID: booking!.workerID, time: nil, service: workService, workingAreaRef: nil, hours: hour, price: nil, materialPrice: nil, payerCard: nil,avartar: nil,maid: nil, responseDic: nil)
            rebookParams = rebookAPI.getParams(booking!, addressID: address?.addressID)
            rebookAMaidRequest()
        }
    }
    
    // MARK: - Table view data source
     override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if availableWorkers?.count == 0 {
            return self.tableView.frame.size.height - 44
        }
        
        return super.tableView(self.tableView, heightForRowAt: indexPath)
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let availableWorkers = availableWorkers else {
            return 0
        }
        return availableWorkers.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "SearchResultsCell"
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? SearchResultsCell
            cell?.backgroundColor = UIColor.white
        if cell == nil {
            cell = SearchResultsCell(style: UITableViewCellStyle.default, reuseIdentifier: cellIdentifier)
        }
        if availableWorkers != nil {
            if let workService = workService, let hour = hour {
                cell!.showWorkerInfo(availableWorkers![indexPath.row], service: workService, hour: hour)
            }
        }
        // NOTE DEMO: Uncomment to roll back
//        cell!.setRightUtilityButtons(self.rightButtons() as [AnyObject], withButtonWidth: 80.0)
//        cell!.delegate = self
        return cell!
    }
    
    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        self.tabBarController?.tabBar.isHidden = true
        performSegue(withIdentifier: SegueIdentifiers.showScheduleDetail, sender: indexPath.row)
    }
    // MARK: - Utilities button
    func rightButtons() -> NSMutableArray {
        let leftUtilityButtons = NSMutableArray()
        leftUtilityButtons.sw_addUtilityButton(with: UIColor(red: 91.0 / 255.0, green: 194.0 / 255.0, blue: 209.0 / 255.0, alpha: 1.0), icon: UIImage(named: ImageResources.feedback))
        return leftUtilityButtons
    }
    // MARK: - Unwind segue
    @IBAction func backFromPayment(_ segue: UIStoryboardSegue) {}
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueIdentifiers.showScheduleDetail {
            guard let destination = segue.destination as? ScheduleAndDetail else {
                return
            }
            guard let selectedIndex = selectedIndex else {
                return
            }
            guard let availableWorkers = availableWorkers else {
                return
            }
            let worker = availableWorkers[selectedIndex]
            self.booking?.avartar = worker.avartar
            self.booking?.workerName = worker.firstName! + " " + worker.lastName!
            self.booking?.price = worker.price
            self.booking?.materialPrice = worker.materialPrice
            self.booking?.workerID = worker.workerID
            self.booking?.maid = worker
            
            if worker.availableTime != 0{
                self.booking?.time = Date(timeIntervalSince1970: worker.availableTime / 1000)
            }
            destination.booking = self.booking
            destination.tabbarDelegate = self
            destination.address = selectedAddress!
            destination.navController = self.navigationController
            destination.currentViewController = self
        }
        else if segue.identifier == SegueIdentifiers.showWorkerProfile {
            guard let destination = segue.destination as? MaidProfileTableViewController else {
                return
            }
            guard let selectedIndex = selectedIndex else {
                return
            }
            guard let availableWorkers = availableWorkers else {
                return
            }
            let worker = availableWorkers[selectedIndex]
            destination.maid = worker
        }
    }
}
extension SearchResultsViewController: SWTableViewCellDelegate {
    func swipeableTableViewCell(_ cell: SWTableViewCell!, didTriggerRightUtilityButtonWith index: Int) {
        switch (index) {
        case 0:
            cell.hideUtilityButtons(animated: true)
            let index = self.tableView.indexPath(for: cell)
            selectedIndex = index?.row
            self.performSegue(withIdentifier: SegueIdentifiers.showWorkerProfile, sender: self)
            break
        default:
            break
        }
    }
    func swipeableTableViewCellShouldHideUtilityButtons(onSwipe cell: SWTableViewCell) -> Bool {
        return true
    }
}
extension SearchResultsViewController: showTabbarDelegate,UITabBarDelegate {
    func showTabar(_ visable: Bool) {
        self.tabBarController?.tabBar.isHidden = visable
    }
}

