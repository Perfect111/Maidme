//
//  CustomersAddressController.swift

//  UserAdressTableController.swift
//  MaidMe
//
//  Created by Viktor on 12/15/16.
//  Created by Viktor on 12/9/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import Foundation
import RealmSwift

import UIKit
import GooglePlaces
import GoogleMaps
import SSKeychain
import Alamofire
import SwiftyJSON
import GooglePlacesSearchController

class CustomersAddressController: BaseTableViewController {
    
    @IBOutlet weak var buildingNameTextFiled: UITextField!
    @IBOutlet weak var areaAndEmiratesTetxField: UITextField!
    @IBOutlet weak var apartmentNoTextField: UITextField!
    @IBOutlet weak var landmarkTextField: UITextField!
    @IBOutlet weak var doneButton: UIButton!
    
    let textFontSize: CGFloat = 16.0
    var paymentAddress: Address?
    var isEdited = false
    var addNewAddressService = AddNewBookingAddressService()
    var updateAddressService = UpdateBookingAddressService()
    var messageCode: MessageCode?
    var googleApi = FetchGoogleAPI()
    var area : String?
    var emirates : String?
    var isDefault = false
    var long: Float?
    var lat: Float?
    var areaID : String?
    
    
    let workingAreaAPI = FetchWorkingAreaService()
    var areaList: [WorkingArea]?
    var filteredAreas = [WorkingArea]()
    var selectedArea: WorkingArea?
    var isMovedFromLogin = false
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        self.tableView.hideTableEmptyCell()
        StringHelper.setPlaceHolderFont([buildingNameTextFiled, apartmentNoTextField, areaAndEmiratesTetxField, landmarkTextField], font: CustomFont.quicksanRegular, fontsize: textFontSize)
        if let _ = paymentAddress {
            setAddressData()
        }
        else {
            paymentAddress = Address()
            setDefaultAddress()
        }
       
        fetchDefaultAreaRequest()
        self.navigationItem.title = "ENTER ADDRESS"
        self.navigationController?.navigationBar.backgroundColor = UIColor.white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       self.navigationController?.navigationBar.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func setupView() {
        buildingNameTextFiled.delegate = self
        areaAndEmiratesTetxField.delegate = self
        self.tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0)
        addTapGestureDismissKeyboard(self.view)
        self.tableView.separatorStyle = .none
    }
    // MARK: - Segue Data
    func setAddressData() {
        if paymentAddress != nil {
            self.area = paymentAddress?.area
            self.emirates = paymentAddress?.emirate
			
			let realm = try! Realm()
			try! realm.write {
				let cachedAddresses = realm.objects(Address.self)
				for eachAddress in cachedAddresses {
					if eachAddress.isDefault{
						self.isDefault = false
						break
					}
				}
			}
            self.lat = paymentAddress?.latitude
            self.long = paymentAddress?.longitude
        }
        areaID = paymentAddress?.workingArea_ref
        buildingNameTextFiled.text = paymentAddress!.buildingName
        apartmentNoTextField.text = paymentAddress!.apartmentNo
        if let emirate = paymentAddress!.emirate {
            if emirate != "" {
                areaAndEmiratesTetxField.text = paymentAddress!.emirate + " - " + (paymentAddress?.area)!
            }
        }
        landmarkTextField.text = paymentAddress!.additionalDetails
       
    }
    
    func setDefaultAddress() {
        let emirate = SSKeychain.password(forService: KeychainIdentifier.appService, account: KeychainIdentifier.emirate)
        let area = SSKeychain.password(forService: KeychainIdentifier.appService, account: KeychainIdentifier.area)
        
        if emirate == nil && area == nil{
            areaAndEmiratesTetxField.text = ""
            isEdited = false
        }
        else{
            areaAndEmiratesTetxField.text = emirate! + " - " + area!
            isEdited = true
        }
    }
    
    // MARK: - IBActions
    @IBAction func onTextFieldEditingChangedAction(_ sender: AnyObject) {
        
    }
    
    @IBAction func cancelButton(_ sender: AnyObject) {
        
    }
    
    
    @IBAction func onDoneAction(_ sender: AnyObject) {
        if areaAndEmiratesTetxField.text == "" || buildingNameTextFiled.text == "" || apartmentNoTextField.text == ""{
            showAlertView(LocalizedStrings.updateSuccessTitle, message: LocalizedStrings.asteriskRequiredField, requestType: nil)
            return
        } else {
        
        dismissKeyboard()
         if selectedArea != nil {
                areaID = selectedArea?.areaID
                self.area = selectedArea?.area
                self.emirates = selectedArea?.emirate
            }
            paymentAddress?.realm?.beginWrite()
        paymentAddress!.buildingName = buildingNameTextFiled.text
        paymentAddress!.apartmentNo = apartmentNoTextField.text
        paymentAddress!.area = self.area
        paymentAddress!.emirate = self.emirates
        paymentAddress!.city = self.emirates
        paymentAddress!.additionalDetails = landmarkTextField.text
        paymentAddress!.country = "UAE"
        paymentAddress!.isDefault = isDefault
        paymentAddress?.longitude = long ?? 0.0
        paymentAddress?.latitude = lat ?? 0.0
            
            do {
                try paymentAddress?.realm?.commitWrite()
            }catch {
                print("error while modifiying address object")
            }
            
            if isEdited {
                updateBookingAddressRequest()
            } else {
                addNewBookingAddressRequest()}
        }
    }
    
    // MARK: - UI
    
    fileprivate func checkFullFillRequiredFields() {
        let isFullFilled = Validation.isFullFillRequiredFields([buildingNameTextFiled, areaAndEmiratesTetxField,apartmentNoTextField])
        ValidationUI.changeRequiredFieldsUI(isFullFilled, button: doneButton)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueIdentifiers.saveUserAddress {
            guard segue.destination is ScheduleAndDetail else {
                return
            }
        }
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
    
    // MARK: - API
    
    func addNewBookingAddressRequest() {
        let parameters = addNewAddressService.getParams(paymentAddress!, areaID: selectedArea!.areaID, isDefault: isDefault)
        sendRequest(parameters, request: addNewAddressService, requestType: .addNewBookingAddress, isSetLoadingView: true)
    }
    
    func updateBookingAddressRequest() {
        let parameters = updateAddressService.getParams(paymentAddress!,areaID: areaID,isDefault: isDefault)
        sendRequest(parameters, request: updateAddressService, requestType: .updateBookingAddress, isSetLoadingView: true)
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
        let result = ResponseHandler.responseHandling(response)
        
//        if result.messageCode != MessageCode.Success {
//            // Show alert
//            handleResponseError(result.messageCode, title: LocalizedStrings.internalErrorTitle, message: result.messageInfo, requestType: requestType)
//            
//            if let error = result.messageCode {
//                messageCode = error
//            }
//            return
//        }
        if requestType == .addNewBookingAddress {
            handleAddNewBookingResponse(result, requestType: .addNewBookingAddress)
        }
        else if requestType == .updateBookingAddress {
            handleUpdateBookingAddressResponse(result, requestType: .updateBookingAddress)
        }
        else if requestType == .fetchWorkingArea {
            handleFetchWorkingAreaResponse(result, requestType: .fetchWorkingArea)
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
        isReloadSuggestion = true
        isReloadAvailable = true
        isReloadSearchResult = true
        customerSelectedAddress = nil
       self.navigationController?.popViewController(animated: true)
    }
    func handleUpdateBookingAddressResponse(_ result: ResponseObject, requestType: RequestType) {
        isReloadSuggestion = true
        isReloadAvailable = true
        isReloadSearchResult = true
        customerSelectedAddress = nil
         self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Handle UIAlertViewAction
    
    override func handleTryAgainTimeoutAction(_ requestType: RequestType) {
        if requestType == .addNewBookingAddress {
            self.addNewBookingAddressRequest()
        }
        else if requestType == .updateBookingAddress {
            self.updateBookingAddressRequest()
        }
        else if requestType == .fetchWorkingArea {
            self.fetchDefaultAreaRequest()
        }
    }
    
    //MARK: Tabelview Delegate
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
        }
        override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
            let headerView = view as? UITableViewHeaderFooterView
            switch section {
            case 0:
                headerView?.textLabel?.text = LocalizedStrings.customersBuildingTitle
            case 1:
                headerView?.textLabel?.text = LocalizedStrings.customersAppartmentTitle
            case 2:
                headerView?.textLabel?.text = LocalizedStrings.customersAreaTitle
            case 3:
                headerView?.textLabel?.text = LocalizedStrings.customersLandmarkTitle
            default:
                break
            }
        }
}

extension CustomersAddressController: GMSAutocompleteViewControllerDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == buildingNameTextFiled {
//            let autocompleteController = GMSAutocompleteViewController()
//            autocompleteController.delegate = self
//            let fitler = GMSAutocompleteFilter()
//            fitler.type = .Establishment
//            fitler.country = "AE" //United Arab Emirates
//            autocompleteController.autocompleteFilter = fitler
//            presentViewController(autocompleteController, animated: true, completion: nil)
			
			
			
			let controller = GooglePlacesSearchController(
				apiKey: "AIzaSyDIFkg6k7vryfWXNza1r6bJC-xp1O7lgWA",
				placeType: PlaceType.all
			)
			controller.didSelectGooglePlace { (place) -> Void in
				print(place.description)
				
				self.areaAndEmiratesTetxField.text = ""
				self.buildingNameTextFiled.text = place.name
				let latitude = String(place.coordinate.latitude)
				let longtitude = String(place.coordinate.longitude)
				self.long = Float(longtitude)
				self.lat = Float(latitude)
				self.googleApi.getAddressWithLngLat(latitude, longtitude: longtitude) {
					self.filterContentForText(self.googleApi.emirates, areaText: self.googleApi.area)
				}
				controller.dismiss(animated: true, completion: nil)
			}

            controller.searchBar.setValue("Done", forKey: "_cancelButtonText")
            guard let _textField = controller.searchBar.value(forKey: "_searchField") as? UITextField else {
                return
            }
            
            _textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)

            self.present(controller, animated: true, completion: nil)
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        buildingNameTextFiled.text = textField.text
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        self.areaAndEmiratesTetxField.text = ""
        self.buildingNameTextFiled.text = place.name
        let latitude = String(place.coordinate.latitude)
        let longtitude = String(place.coordinate.longitude)
        long = Float(longtitude)
        lat = Float(latitude)
        self.googleApi.getAddressWithLngLat(latitude, longtitude: longtitude) {
            
            self.filterContentForText(self.googleApi.emirates, areaText: self.googleApi.area)
        }
        self.dismiss(animated: true, completion: nil)
    }
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
    }
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        self.dismiss(animated: true, completion: nil)
    }
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}
extension CustomersAddressController {
    func fetchDefaultAreaRequest() {
        sendRequest(nil, request: workingAreaAPI, requestType: .fetchWorkingArea, isSetLoadingView: false, button: nil)
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
    func handleFetchWorkingAreaResponse(_ result: ResponseObject, requestType: RequestType) {
        setUserInteraction(true)
        var list = [String]()
        var listArea = [WorkingArea]()
        
        guard let body = result.body else { return }
        for (_, dic) in body {
            let item = WorkingArea(areaDic: dic)
            if item.areaID == nil && item.emirate != nil && item.area != nil {
                continue
            }
            listArea.append(item)
            list.append("\(item.emirate!) - \(item.area!)")
        }
        areaList = listArea
    }
    func filterContentForText(_ emiratesText:String,areaText: String) {
            guard let areaList = areaList else {
            return
        }
        filteredAreas = areaList.filter { emirates in
            return emirates.emirate!.lowercased().contains(emiratesText.lowercased())
        }
        if filteredAreas.count == 0 {
            self.areaAndEmiratesTetxField.text = ""
        } else {
            let emi = filteredAreas[0].emirate!
            var areaString = areaText
            for _ in 0..<areaString.characters.count {
            filteredAreas = areaList.filter({ (area) -> Bool in
                return (area.area?.lowercased().contains((areaString.lowercased())))!
            })
            if filteredAreas.count == 0 {
                self.area = ""
                areaString = String(areaString.characters.dropLast())
                if areaString.characters.count < 4 {
                return
                }
            } else {
                self.area = filteredAreas[0].area!
                self.emirates = emi
            }
         }
            for i in 0..<areaList.count {
                if areaList[i].area == self.area && areaList[i].emirate == self.emirates {
                    self.areaAndEmiratesTetxField.text = areaList[i].emirate! + " - " + areaList[i].area!
                    self.selectedArea = areaList[i]
                    return
                } else {
                self.areaAndEmiratesTetxField.text = ""
                }
            }
        }
    }
    
}

extension CustomersAddressController: WorkingAreaTableViewControllerDelegate {
    func didSelectArea(_ selectedArea: WorkingArea?) {
        if selectedArea?.area != nil && selectedArea?.emirate != nil {
          self.area = selectedArea?.area
            self.emirates = selectedArea?.emirate
            self.areaAndEmiratesTetxField.text = (selectedArea?.emirate)! + " - " + (selectedArea?.area)!
            self.selectedArea = selectedArea
        }
    }
}

