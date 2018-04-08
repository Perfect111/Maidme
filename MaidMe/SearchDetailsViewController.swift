//
//  SearchDetailsViewController.swift
//  MaidMe
//
//  Created by Viktor on 12/23/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit
import SSKeychain
import Alamofire

protocol showTabbarDelegate {
    func showTabar(_ visable: Bool)
}


class SearchDetailsViewController: BaseTableViewController  {
    
    @IBOutlet weak var checkPossibleImage: UIImageView!
    @IBOutlet weak var checkAddMaterialImage: UIImageView!
    @IBOutlet weak var serviceImage: UIImageView!
    @IBOutlet weak var hourView: SelectValueView!
    @IBOutlet weak var selectedDateLabel: UILabel!
    @IBOutlet weak var serviceLabel: UILabel!
    @IBOutlet weak var hoursLabel: UILabel!
    @IBOutlet weak var descriptionServiceLabel:UILabel!
    @IBOutlet weak var selectDateButton: UIButton!
    @IBOutlet weak var buttonSearchTopLayoutConstrant: NSLayoutConstraint!
    @IBOutlet weak var selectedDateIconImage: UIImageView!
   
    
    var tabbarDelegate : showTabbarDelegate?
    var asSoonAsPossible = true
 
    var addressList = [Address]()
    var selectedAddress: Address?
    var messageCode: MessageCode?
    var serviceList = [WorkingService]()
    var areaID: String?
    var searchTime: Double?
    var navController: UINavigationController?
    var currentViewController: AnyObject!
    var selectedDate: Date?
    var selectedService : WorkingService?
    
    let fetchBookingDoneNotRatingAPI = FetchBookingDoneNotRatingService()
    let getMinPeriodWorkingHourAPI = GetMinPeriodWorkingHourService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getMinPeriodWorkingHourRequest()
        updateLabel()
		if selectedService?.avatar != nil {
			print(selectedService?.avatar)
			loadImageFromURL(selectedService!.avatar!, imageLoad: serviceImage)
		}
		
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        let transition = CATransition()
        transition.duration = 0.4
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromTop
        self.view.layer.add(transition, forKey:kCATransition)
        buttonSearchTopLayoutConstrant.constant = self.view.frame.height/8.2
        selectDateButton.isEnabled = true
        selectedDateLabel.alpha = 1
        selectedDateIconImage.alpha = 1
    }
 
    func updateLabel(){
        if let service:String = selectedService?.name,let descriptionService = selectedService?.serviceDescription {
            serviceLabel.text = service
            descriptionServiceLabel.text = descriptionService
        }
        
    }
    //MARK: -Action
    @IBAction func dismissHandler() {
        tabbarDelegate?.showTabar(false)
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func onPossible(_ sender: AnyObject) {
        asSoonAsPossible = !asSoonAsPossible
        checkPossibleImage.image = asSoonAsPossible ? UIImage(named: ImageResources.checkedBox) : UIImage(named: ImageResources.uncheckBox)
        if !asSoonAsPossible {
            selectedDateLabel.alpha = 1
            selectedDateIconImage.alpha = 1
            let nextRoundedTime = Date().getNextOneRoundedHourTime()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM dd yyyy, HH:mma"
            self.selectedDate = nextRoundedTime
            self.selectedDateLabel.text = dateFormatter.string(from: selectedDate!)
        } else {
            selectedDateLabel.text = "Choose a date"
            selectedDateLabel.alpha = 0.4
            selectedDateIconImage.alpha = 0.4
        }
        self.tableView.reloadData()
    }
    
    @IBAction func searchHandler(_ sender: AnyObject) {
        if !asSoonAsPossible {
            if selectedDate!.isLessThanCurrentTime() {
                showAlertView(LocalizedStrings.invalidDateTitle, message: LocalizedStrings.invalidDateMessage, requestType: nil)
                return
            }
        }
        tabbarDelegate?.showTabar(false)
        self.dismiss(animated: true, completion: nil)
        showSearch()
    }
  
    func getMinPeriodWorkingHourRequest() {
        sendRequest(nil, request: getMinPeriodWorkingHourAPI, requestType: .getMinPeriodWorkingHour, isSetLoadingView: false, view: nil)
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
        if isSetLoadingView && view != nil {
            self.setRequestLoadingViewCenter1(view!)
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
      
        if requestType == .getMinPeriodWorkingHour {
            handleGetMinPeriodWorkingHour(result, requestType: .getMinPeriodWorkingHour)
        }
    }
  
    func handleGetMinPeriodWorkingHour(_ result: ResponseObject, requestType: RequestType) {
        guard let body = result.body else {
            return
        }
        let mins = (body["min_period_working_hour"].int == nil ? 0 : body["min_period_working_hour"].int!)
        let minHour = ceil(Double(mins) / Double(60))
        
        // Update the min value of hour view.
        let hour:Int = Int(minHour)
        if hour > 1 {
            hoursLabel.text = "Min: \(hour) Hours"
        } else {
            hoursLabel.text = "Min: \(hour) Hour"
        }
        hourView.minValue = Int(minHour)
    }
    
    override func handleTryAgainTimeoutAction(_ requestType: RequestType) {
        if requestType == .getMinPeriodWorkingHour {
            getMinPeriodWorkingHourRequest()
        }
    }
    func getParam() -> [String: AnyObject] {
        if asSoonAsPossible {
            // Get next rounded one hour
            searchTime = Date().timeIntervalSince1970 * 1000 + 5 * 60 * 1000
        }
        else {
            searchTime = Double(selectedDate!.timeIntervalSince1970 * 1000)
        }
        //MARK: TO DO
        return ["service_id": getServiceIDFromService(selectedService!.name, list: serviceList) as AnyObject,
                "date_time": searchTime! as AnyObject, //Double(datePicker.date.timeIntervalSince1970 * 1000),
            "area_id": (selectedAddress?.workingArea_ref == nil ? "" : selectedAddress?.workingArea_ref)! as AnyObject,
            "hours": hourView.currentValue as AnyObject,
            "asap": asSoonAsPossible as AnyObject]
    }
	
	var picker : DateTimePicker!
	@IBAction func chooseDateTapped(_ sender: AnyObject) {
		
		
		var defaultDate = Date()
		let calendar = Calendar.current
		let comp = (calendar as NSCalendar).components([.hour], from: defaultDate)
		let hour = comp.hour
		if hour! >= 18 {
			// If it's later than 18:00
			defaultDate = (calendar as NSCalendar).date(byAdding: .day,value: 1,to: defaultDate,options: [])!
			defaultDate = defaultDate.setTo8AM()
		}
		
		picker = DateTimePicker.show(defaultDate, minimumDate: defaultDate, maximumDate: Date().addingTimeInterval(60 * 60 * 24 * 7))
		picker.daysBackgroundColor = UIColor(red:0.31, green:0.73, blue:0.80, alpha:1.00)
		picker.highlightColor = UIColor(red:0.31, green:0.73, blue:0.80, alpha:1.00)
		picker.completionHandler = { selecteddate in
			let dateFormatter = DateFormatter()
			dateFormatter.dateFormat =  "MMM dd yyyy, HH:mma"
			self.selectedDate = selecteddate as Date
			self.selectedDateLabel.text = dateFormatter.string(from: selecteddate as Date)
			
			self.asSoonAsPossible = false
			self.selectDateButton.isEnabled = true
			self.checkPossibleImage.image = UIImage(named: ImageResources.uncheckBox)
			self.selectedDateLabel.alpha = 1
			self.selectedDateIconImage.alpha = 1
			self.tableView.reloadData()
		}
		
		
	}
	
	func dismissCalendar() {
		picker.dismissView()
	}
	
    //tableView
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 3 {
            if self.view.frame.height > 500{
                        return (self.view.frame.height - 435)
            } else {
                return 70
            }
        }
        else {
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueIdentifiers.showSelecDateStart {
            guard let destination = segue.destination as? TestVC else {
                return
            }
            destination.delegate = self
        }
    }
    func showSearch(){
        let storyboard = self.storyboard
        
        guard let searchResult = storyboard?.instantiateViewController(withIdentifier: StoryboardIDs.searchResults) as? SearchResultsViewController else {
            return
        }
        searchResult.availableWorkerParams = getParam()
        searchResult.workService = self.selectedService
        searchResult.hour = self.hourView.currentValue
        searchResult.serviceList = self.serviceList
        searchResult.isMoveFromSearchDetails = true
        searchResult.asap = asSoonAsPossible
        searchResult.searchTime = self.searchTime
        searchResult.selectedAddress = selectedAddress
        searchResult.addressList = self.addressList
        
        searchResult.booking =  Booking(bookingID: nil, workerName: nil, workerID: nil, time: nil, service: WorkingService.getService(selectedService?.name, list: serviceList), workingAreaRef: nil, hours: hourView.currentValue, price: nil, materialPrice: nil, payerCard: nil, avartar: nil,maid: nil, responseDic: nil)
        guard let _ = currentViewController as? SearchResultsViewController else {
            navController?.pushViewController(searchResult, animated: true)
            return
        }
    }
}
extension SearchDetailsViewController: SelectDateDelegate {
    func selectedDate(_ dateSelected: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat =  "MMM dd yyyy, HH:mma"
        self.selectedDate = dateSelected
        self.selectedDateLabel.text = dateFormatter.string(from: selectedDate!)
		
		asSoonAsPossible = false
		selectDateButton.isEnabled = true
		checkPossibleImage.image = UIImage(named: ImageResources.uncheckBox)
		selectedDateLabel.alpha = 1
		selectedDateIconImage.alpha = 1
		self.tableView.reloadData()
    }
}
