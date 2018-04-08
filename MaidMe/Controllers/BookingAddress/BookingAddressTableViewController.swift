//
//  BookingAddressTableViewController.swift
//  MaidMe
//
//  Created by Viktor on4/7/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit
import SWTableViewCell
import Alamofire
import SSKeychain
import RealmSwift

class BookingAddressTableViewController: BaseTableViewController {
    
    var addressList = [Address]()
    var currentAddress: Address?
    var customer: Customer!
    var selectedArea: WorkingArea?
    
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var userEmailLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    var isPopView : Bool?
    
    var removeAddressAPI = RemoveAddress()
    var messageCode: MessageCode?
    var isMoveFromViewPersonal: Bool?
    
    let fetchAllAddresses = FetchAllBookingAddressesService()
    var updateAddressService = UpdateBookingAddressService()
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
	
		
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setDefaultUIForLoadingIndicator()
        showCustomerInfo()
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
		
		fetchAllBookingAddressesRequest()
       // self.navigationItem.title = "LIST ADDRESS"
    }
    override func setDefaultUIForLoadingIndicator() {
        self.loadingIndicator.activityIndicatorViewStyle = .whiteLarge
        self.loadingIndicator.color = UIColor.black
        if let window = UIApplication.shared.keyWindow {
            self.loadingIndicator.center = window.center
            window.addSubview(self.loadingIndicator)
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isMoveFromViewPersonal = false
    }
    override func viewDidAppear(_ animated: Bool) {
        if isMoveFromViewPersonal != true {
            fetchAllBookingAddressesRequest()
            showCustomerInfo()
        }
    }
    
    @IBAction func backAction(_ sender: AnyObject?) {
        self.navigationController?.popViewController(animated: true)
    }
    func showCustomerInfo() {
        let email = SSKeychain.password(forService: KeychainIdentifier.appService, account: KeychainIdentifier.userName)
        let phoneNumber = SSKeychain.password(forService: KeychainIdentifier.appService, account: KeychainIdentifier.phoneNumber)
        let customerName = SSKeychain.password(forService: KeychainIdentifier.appService, account: KeychainIdentifier.customerName)
        userEmailLabel.text = email
        phoneNumberLabel.text = StringHelper.reformatPhoneNumber(phoneNumber == nil ? "" : phoneNumber!)
        userNameLabel.text = customerName
        
    }
    func fetchAllBookingAddressesRequest() {
        sendRequest(nil, request: fetchAllAddresses, requestType: .fetchAllBookingAddresses, isSetLoadingView: false,button: nil)
    }
    
    
    func rightButtons() -> NSMutableArray{
        let leftUtilityButtons = NSMutableArray()
        leftUtilityButtons.sw_addUtilityButton(with: UIColor(red:  91.0/255,green: 194.0/255,blue: 209.0/255.0,alpha: 1.0), icon: UIImage(named: "default_button"))
        leftUtilityButtons.sw_addUtilityButton(with: UIColor.lightGray, icon: UIImage(named: "deletee_button" ))
        return leftUtilityButtons
    }
    
    func removeAddressRequest(_ addressRemove: Address?){
        let params = removeAddressAPI.getRemoveAddressParams(addressRemove)
        sendRequest(params as [String : AnyObject], request: removeAddressAPI, requestType: .removeAddress, isSetLoadingView: true, button: nil)
    }
    
    func setDefaultAddress(_ addressSet: Address?){
        let params = updateAddressService.getParams(addressSet!,areaID: addressSet!.workingArea_ref,isDefault : true)
        sendRequest(params, request: updateAddressService, requestType: .updateBookingAddress, isSetLoadingView: true, button: nil)
    }
    
    func sendRequest(_ parameters: [String: AnyObject]?,
                     request: RequestManager,
                     requestType: RequestType,
                     isSetLoadingView: Bool, button: UIButton?) {
        // Check for internet connection
        if RequestHelper.isInternetConnectionFailed() && addressList.count == 0 {
            RequestHelper.showNoInternetConnectionAlert(self)
            return
        }

		self.startLoadingView()
        request.request(parameters: parameters) {
            [weak self] response in
            
            if let strongSelf = self {
                strongSelf.stopLoadingView()
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
       
        if requestType == .fetchAllBookingAddresses {
            handleFetchAllBookingAddressesResponse(result, requestType: .fetchAllBookingAddresses)
        }
        else if requestType == .updateBookingAddress {
            handleUpdateBookingAddressResponse(result, requestType: .updateBookingAddress)
        }
        else if requestType == .removeAddress {
            handlerRemoveAddress(result, requestType: .removeAddress)
        }
        
        
    }
    
    func handlerRemoveAddress(_ result: ResponseObject, requestType: RequestType){
        isReloadSuggestion = true
        isReloadAvailable = true
        isReloadSearchResult = true
        customerSelectedAddress = nil
    }
    
    func handleUpdateBookingAddressResponse(_ result: ResponseObject, requestType: RequestType) {
        isReloadSuggestion = true
        isReloadAvailable = true
        isReloadSearchResult = true
        customerSelectedAddress = nil
        fetchAllBookingAddressesRequest()
    }
 
    
    func handleFetchAllBookingAddressesResponse(_ result: ResponseObject, requestType: RequestType) {
        guard let list = result.body else {
            return
        }
		
		let fetchedAddresses = fetchAllAddresses.getAddressList(list)
		var newService = false
		if addressList.count != fetchedAddresses.count {
			newService = true
		}else{
			for eachAddress in addressList {
				let results = fetchedAddresses.filter { $0.addressID == eachAddress.addressID }
				if results.count == 0 {
					newService = true
					break
				}
			}
		}
		
		
//		sortAddressList()

		if fetchedAddresses != addressList {
			// Cache service list
			addressList = fetchedAddresses
			self.tableView.reloadData()
		}
		
    }
	
    // MARK: - Data
    
    func sortAddressList() {
        guard let currentAddress = currentAddress else {
            return
        }
        for address in addressList {
            if address.addressID == currentAddress.addressID {
                addressList.remove(at: addressList.index(of: address)!)
               break
            }
        }
        addressList.insert(currentAddress, at: 0)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addressList.count + 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // Set dynamic height base on the textview content size.
        return 60
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let count = addressList.count
        if count > 0 && indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "addressCellIdentifier", for: indexPath) as! AddressCell
            for address in addressList {
                if (address.isDefault == true) {
                    //  cell.setContent(addressList[indexPath.row])
                    cell.buildingLabel.text = "DEFAULT AREA"
                    cell.addressLabel.text = "\(address.buildingName), \(address.emirate), \(address.country)"
                }
            }
            return cell
        } else if count == indexPath.row {
            let cell = tableView.dequeueReusableCell(withIdentifier: "newAddressCellIdentifier", for: indexPath) as! NewAddressCell
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "addressCellIdentifier", for: indexPath) as! AddressCell
            cell.setContent(addressList[indexPath.row])
            cell.delegate = self
            cell.setRightUtilityButtons(rightButtons() as [AnyObject], withButtonWidth: 70)
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let count = addressList.count
        let storyboard = self.storyboard
        guard let CustomerAddressVC = storyboard!.instantiateViewController(withIdentifier: "CustomerAddressVC") as? CustomersAddressController else {
            return
        }
        if indexPath.row == 0 {
            CustomerAddressVC.paymentAddress = self.addressList[indexPath.row]
            CustomerAddressVC.isDefault = true
            CustomerAddressVC.isEdited = true
            
        } else {
            CustomerAddressVC.isDefault = false
            if count > 0 && indexPath.row > 0 && indexPath.row < count {
                CustomerAddressVC.paymentAddress = self.addressList[indexPath.row]
                CustomerAddressVC.isEdited = true
            }
        }
        self.navigationController?.pushViewController(CustomerAddressVC,animated: true)
        
    }
    
    // MARK: - IBAction
    
    @IBAction func backToAddressList(_ segue: UIStoryboardSegue) {
        
    }
    
    @IBAction func addNewAddressAction(_ sender: AnyObject) {
        
        let storyboard = self.storyboard
        guard let CustomerAddressVC = storyboard!.instantiateViewController(withIdentifier: StoryboardIDs.customeAddressVC) as? CustomersAddressController else {
            return
        }
        self.navigationController?.pushViewController(CustomerAddressVC,animated: true)
    }
    @IBAction func editPersonalDetailAction(_ sender: AnyObject?) {
        let storyboard = self.storyboard
        guard let personalVC = storyboard?.instantiateViewController(withIdentifier: StoryboardIDs.personalDetails) else {
            return
        }
        self.navigationController?.pushViewController(personalVC, animated: true)
        
    }
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get selected cell
        guard let button = sender as? UIButton else {
            return
        }
        
        let buttonPosition = button.convert(CGPoint.zero, to: self.tableView)
        
        guard let indexPath =  self.tableView.indexPathForRow(at: buttonPosition) else {
            return
        }
        
        if segue.identifier == SegueIdentifiers.showDetailBookingAddress {
            guard let destination = segue.destination as? CustomersAddressController else {
                return
            }
            if indexPath.row == addressList.count {
                destination.paymentAddress = nil
                destination.isEdited = false
            }
            else if indexPath.row == 0 {
                destination.paymentAddress = addressList[indexPath.row]
                destination.isEdited = true
            }
        }
        else if segue.identifier == SegueIdentifiers.backFromAddressList {
            guard let destination = segue.destination as? ScheduleAndDetail else {
                return
            }
            
            destination.address = addressList[indexPath.row]
        }
    }
}
extension BookingAddressTableViewController: SWTableViewCellDelegate{
    func swipeableTableViewCell(_ cell: SWTableViewCell!, didTriggerRightUtilityButtonWith index: Int) {
        switch (index){
        case 0:
            cell.hideUtilityButtons(animated: true)
            let index = self.tableView.indexPath(for: cell)
            self.setDefaultAddress(addressList[(index?.row)!])
            
            self.tableView.reloadData()
            
        case 1:
            let index = self.tableView.indexPath(for: cell)
            // Create the alert controller
            let alertController = UIAlertController(title: LocalizedStrings.cofirmDelete, message: addressList[(index?.row)!].buildingName, preferredStyle: .alert)
            
            // Create the actions
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                UIAlertAction in
                self.removeAddressRequest(self.addressList[(index?.row)!])
                if self.addressList[(index?.row)!].isDefault != true{
                    self.addressList.remove(at: (index?.row)!)
                }
                self.tableView.reloadData()
                
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) {
                UIAlertAction in
                // NSLog("Cancel Pressed")
            }
            // Add the actions
            alertController.addAction(okAction)
            alertController.addAction(cancelAction)
            // Present the controller
            self.present(alertController, animated: true, completion: nil)
        default:
            break
        }
        
    }
    func swipeableTableViewCellShouldHideUtilityButtons(onSwipe cell: SWTableViewCell!) -> Bool {
        return true
    }
}

