//
//  AvailabelServicesViewController.swift
//  MaidMe
//
//  Created by Viktor on 12/23/16.
//  Copyright © 2016 Mac. All rights reserved.
//
import UIKit
import Alamofire
import SSKeychain
import SVProgressHUD
import RealmSwift

var isReloadAvailable: Bool?

class AvailabelServicesViewController: BaseTableViewController,UIGestureRecognizerDelegate {
    
    var serviceList = [WorkingService]()
    var messageCode: MessageCode?
    var addressList = [Address]()
    var customer: Customer!
    var selectedAddress: Address?
    var isMovedFromLogin = false
    var bookingList = [Booking]()
    var ratingList = [Rating]()
    var timesShowRatingAndComment = 0
    var indexItemBookingList = 0
    var isSubmitted: Bool = false
    var isObsever : Bool?
    
    let fetchServiceTypeAPI = FetchServiceTypeService()
    let fetchAllAddresses = FetchAllBookingAddressesService()
	let fetchBookingDoneNotRatingAPI = FetchBookingDoneNotRatingService()
    var isPopView : Bool?
    
    
    @IBOutlet weak var addressMenuButton: UIButton!
    
    var areaID :String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideBackbutton(true)
        self.tableView.separatorStyle = .none
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        if customerSelectedAddress == nil{
         isPopView = false
        }
		
        sendFetchServiceTypesRequest()

		if let cachedAddressName: String = UserDefaults.standard.string(forKey: "cachedAddressName"){
			self.navTitleView.buildingNameLabel.text = cachedAddressName
            self.navTitleView.showListAddressButton.setTitle(cachedAddressName, for: .normal)
		}
		
        setupMenuAddressButton(btn: addressMenuButton)
        fetchAllBookingAddressesRequest()
		fetchBookingDoneNotRatingRequest()
        self.navTitleView.showListAddressButton.addTarget(self, action: #selector(showAddressMenu), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        hideBackbutton(true)
//        setDefaultUIForLoadingIndicator()
        self.view.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
        self.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = false
        
    }
	
    override func viewDidAppear(_ animated: Bool) {
        if customerSelectedAddress != nil && customerSelectedAddress?.addressID != selectedAddress?.addressID  {
            selectedAddress = customerSelectedAddress
            if let buildingName = selectedAddress?.buildingName {
                self.navTitleView.buildingNameLabel.text = cutString(buildingName)
            }
        }
        if isReloadAvailable == true {
            updateServiceList()
        }
//        }
//     NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(updateServiceList), name: "updateAvailabelAddress", object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isPopView = true
        isObsever = false
        isReloadAvailable = false
        
    }
    override func setDefaultUIForLoadingIndicator() {
        self.loadingIndicator.activityIndicatorViewStyle = .whiteLarge
        self.loadingIndicator.color = UIColor.black
        if let window = UIApplication.shared.keyWindow {
            self.loadingIndicator.center = window.center
            window.addSubview(self.loadingIndicator)
        }
    }
    func updateServiceList(){
        print("update service list")
        isObsever = true
        isPopView = false
        fetchAllBookingAddressesRequest()
//         NSNotificationCenter.defaultCenter().removeObserver(self, name: "updateAvailabelAddress", object: nil)
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
	
	
	func fetchBookingDoneNotRatingRequest() {
//		sendRequest(nil, request: fetchBookingDoneNotRatingAPI, requestType: .FetchBookingDoneNotRating, isSetLoadingView: false, button: nil)
		sendRequest(nil, request: fetchBookingDoneNotRatingAPI, requestType: .fetchBookingDoneNotRating, isSetLoadingView: false, view: nil)
	}
	func handleFetchBookingDoneNotRatingResponse(_ result: ResponseObject, requestType: RequestType) {
		guard let body = result.body else {
			return
		}
		
		let result = fetchBookingDoneNotRatingAPI.getBookingList(body)
		ratingList = result
		timesShowRatingAndComment = ratingList.count
		if ratingList.count > 0 {
			self.performSegue(withIdentifier: SegueIdentifiers.giveCommentAndRating, sender: self)
		}
		else {
			return
		}
	}

	func prepareToRatingAndComment() {
		if timesShowRatingAndComment > 0 {
			self.performSegue(withIdentifier: SegueIdentifiers.giveCommentAndRating, sender: self)
		}
		else {
			return
		}
	}
	
    func sendFetchServiceTypesRequest() {
        // Check for internet connection
        if RequestHelper.isInternetConnectionFailed() {
            RequestHelper.showNoInternetConnectionAlert(self)
            setUserInteraction(false)
            return
        }
		
		if serviceList.count == 0 {
			startLoadingView()
		}
		
        fetchServiceTypeAPI.request(parameters: nil) {
            [weak self] (response) in
            
            DispatchQueue.main.async(execute: {
                if let strongSelf = self {
                    strongSelf.handleFetchServiceTypesResponse(response)
                    strongSelf.handleAPIResponse()
                }
            })
        }
    }
    
    func handleFetchServiceTypesResponse(_ response: DataResponse<Any>) {
        let result = ResponseHandler.responseHandling(response)
        if result.messageCode != MessageCode.success || result.body == nil {
            // Show alert
            handleResponseError(result.messageCode, title: LocalizedStrings.connectionFailedTitle, message: result.messageInfo, requestType: .fetchServiceTypes)
            
            if let error = result.messageCode {
                messageCode = error
            }
            return
        }
        setUserInteraction(true)
        var list = [String]()
        var listArea = [WorkingService]()
        
        for (_, dic) in result.body! {
            let item = WorkingService(serviceDic: dic)
            if item.serviceID == nil && item.name != nil {
                continue
            }
            listArea.append(item)
            list.append("\(item.name!)")
        }
		
		if serviceList != listArea {
			// Cache service list
			serviceList = listArea
			self.tableView.reloadData()
		}
		
    }
    // mark: test
    func fetchAllBookingAddressesRequest() {
        sendRequest(nil, request: fetchAllAddresses, requestType: .fetchAllBookingAddresses, isSetLoadingView: true, view: nil)
    }
    func handleFetchAllBookingAddressesResponse(_ result: ResponseObject, requestType: RequestType) {
        //print("Booking addresses: ", result.body)
        guard let list = result.body else {
            return
        }
        addressList = fetchAllAddresses.getAddressList(list)
        if isPopView == false {
        if addressList.count == 1{
            self.navTitleView.dropDownImage.image = UIImage(named: "")
        } else {
            self.navTitleView.dropDownImage.image = UIImage(named: "dropIcon")
        }
        for address in addressList {
            if (address.isDefault == true) {
                if let buildingName: String = cutString(address.buildingName) {
                    self.navTitleView.buildingNameLabel.text = buildingName
					UserDefaults.standard.setValue(buildingName, forKey: "cachedAddressName")
                }
                
                selectedAddress = address
            }
        }
        }
    }
    func sendRequest(_ parameters: [String: AnyObject]?,
                     request: RequestManager,
                     requestType: RequestType,
                     isSetLoadingView: Bool, view: UIView?) {
        // Check for internet connection
        if RequestHelper.isInternetConnectionFailed() {
            RequestHelper.showNoInternetConnectionAlert(self)
			
			if let cachedAddressName: String = UserDefaults.standard.string(forKey: "cachedAddressName"){
				self.navTitleView.buildingNameLabel.text = cachedAddressName
			}
            return
        }
		
		if UserDefaults.standard.string(forKey: "cachedAddressName") == nil{
			// Set loading view center
			self.startLoadingView()
		}
		
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
        }
        setUserInteraction(true)
        if requestType == .fetchAllBookingAddresses {
            handleFetchAllBookingAddressesResponse(result, requestType: .fetchAllBookingAddresses)
		}else if requestType == .fetchBookingDoneNotRating {
			handleFetchBookingDoneNotRatingResponse(result, requestType: .fetchBookingDoneNotRating)
		}
    }
    // MARK: - Fetch default address
	
          //MARK: -Action
    @IBAction func showAddressMenu(){
        self.showCustomerAddressMenu()
        
    }
    func showCustomerAddressMenu() {
        if addressList.count > 1 {
        let storyboard = self.storyboard
        guard let addressMenu = storyboard?.instantiateViewController(withIdentifier: StoryboardIDs.customerAddressMenu) as? AddressMenu else {
            return
        }
        addressMenu.availabelServiceVC = self
        addressMenu.addressList = self.addressList
        addressMenu.navController = self.navigationController
        addressMenu.currentViewController = self
        addressMenu.view.backgroundColor = .clear
        addressMenu.modalPresentationStyle = .overCurrentContext
            self.present(addressMenu, animated: false, completion: nil)
        }
    }
    func getAreaIdToSearch(_ address: Address) {
        self.selectedAddress = address
        if let buildingName: String = selectedAddress!.buildingName
        {
            self.navTitleView.buildingNameLabel.text = cutString(buildingName)
        }
    }
    
    //MARK: -Show Search Details
    func showSearchDetailsVC(_ indexPath: IndexPath) {
        let storyboard = self.storyboard
        guard let searchDetails = storyboard?.instantiateViewController(withIdentifier: StoryboardIDs.searchDetailsVC) as? SearchDetailsViewController else {
            return
        }
        
        searchDetails.tabbarDelegate = self
        searchDetails.navController = self.navigationController
        searchDetails.currentViewController = self
        searchDetails.selectedService = serviceList[indexPath.row]
        searchDetails.serviceList = self.serviceList
        searchDetails.addressList = self.addressList
        if selectedAddress != nil{
            searchDetails.selectedAddress = self.selectedAddress
		}else {
			let realm = try! Realm()
			let cachedAddresses = realm.objects(Address.self)
			if cachedAddresses.count > 0 {
				searchDetails.selectedAddress = cachedAddresses[0];
			}

		}
        searchDetails.view.backgroundColor = .clear
        searchDetails.modalPresentationStyle = .overCurrentContext
        self.present(searchDetails, animated: false, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
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
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return serviceList.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let availabelCellid = "Cell"
        var cell = tableView.dequeueReusableCell(withIdentifier: availabelCellid, for: indexPath) as? AvailabelServiceCell
        if cell == nil {
            cell = AvailabelServiceCell(style: UITableViewCellStyle.default, reuseIdentifier: availabelCellid)
        }
        let service = serviceList[indexPath.row]
        
        if serviceList.count != 0 {
			if service.name != nil{
                cell?.serviceName.text = service.name!.uppercased()
            }
			if service.avatar != nil {
				cell?.loadImageFromURLwithCache(service.avatar!, imageLoad: (cell?.imageName)!)
			}
			
			if service.serviceDescription != nil {
				cell?.detailService.text = service.serviceDescription
			}
			
        }
        return cell!
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        self.tabBarController?.tabBar.isHidden = true
        
        showSearchDetailsVC(indexPath)
    }
}
extension AvailabelServicesViewController: GiveRatingTableViewControllerDelegate {
    func didDismissRatingAndCommentBooking(_ isSubmitted: Bool) {
        if isSubmitted {
            timesShowRatingAndComment = timesShowRatingAndComment - 1
            indexItemBookingList = indexItemBookingList + 1
            prepareToRatingAndComment()
        }
        else {
        }
    }
}
extension AvailabelServicesViewController: showTabbarDelegate,UITabBarDelegate {
    func showTabar(_ visable: Bool) {
        self.tabBarController?.tabBar.isHidden = visable
    }
}
