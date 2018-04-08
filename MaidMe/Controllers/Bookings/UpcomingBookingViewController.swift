//
//  upcomingBookingViewController.swift
//  MaidMe
//
//  Created by Viktor on 12/14/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit
import SWTableViewCell
import Alamofire
import SwiftyJSON
import RealmSwift

class UpcomingBookingViewController: BaseTableViewController {
    //  var refreshItemControl: UIRefreshControl!
    
    var isShowBookingDetail = false
    var selectedIndex: IndexPath!
    var listCount = 10
    var isCanceled: Bool = true
    var selectedCell: UpcomingCell?
    var messageCode: MessageCode?
    var upCommingBooking = [Booking]()
    var bookingHistory = [Booking]()
    
    let fetchUpcomingBookings = FetchAllUpcomingBookingsService()
    let cancelBooking = CancelABookingService()
    let bookingHistoryAPI = FetchBookingHistoryService()
    
    var countTime: Int = 0
    var maxLoadedItems = 10
    var totalBookingHistory = 0
    var totalupComingBookingHistory = 0
    var refreshItemControl: UIRefreshControl!
    var selectedBooking: Int?
    var selectedService: String?
    var serviceList = [WorkingService]()
    var isPopView: Bool?
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRefreshControl()
        refreshItemControl.addTarget(self, action: #selector(UpcomingBookingViewController.Refresh), for: UIControlEvents.valueChanged)
		
		let realm = try! Realm()
		let cachedBookings = realm.objects(Booking.self).filter("time >= %@", Date())
		if cachedBookings.count != 0 {
			upCommingBooking = Array(cachedBookings)
			totalupComingBookingHistory = upCommingBooking.count
			print(cachedBookings)
			self.tableView.reloadData()
		}
		fetchUpcomingBookingsRequest()
		
        self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        self.tableView.separatorStyle = .none
        isPopView = false
        
    }
    @objc func Refresh(){
        fetchUpcomingBookingsRequest()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.hideBackbutton(true)
        tableView.hideTableEmptyCell()
        self.view.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.navigationBar.isHidden = false
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isPopView = true
        
    }
    override func viewDidAppear(_ animated: Bool) {
        if isPopView == true {
            fetchUpcomingBookingsRequest()
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
    
    func refreshResult() {
        // Remove all current search results
        //bookingHistory.removeAll()
        countTime = 0
        selectedIndex = nil
        isShowBookingDetail = false
    }
    override func setDefaultUIForLoadingIndicator() {
        self.loadingIndicator.activityIndicatorViewStyle = .whiteLarge
        self.loadingIndicator.color = UIColor.black
        if let window = UIApplication.shared.keyWindow {
            self.loadingIndicator.center = window.center
            window.addSubview(self.loadingIndicator)
        }
    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 && upCommingBooking.count == 0 {
            return 1
        }
        else {
            if isShowBookingDetail {
                if totalupComingBookingHistory > upCommingBooking.count {
                    return upCommingBooking.count + 1  // 1 for load more and 1 for detail cell
                }
                return upCommingBooking.count
            }
            
            if totalupComingBookingHistory > upCommingBooking.count {
                return upCommingBooking.count  // 1 for load more and 1 for detail cell
            }
            return upCommingBooking.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if upCommingBooking.count == 0 {
            let noUpcomingCell = "noUpcommingBookingCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: noUpcomingCell, for: indexPath)
            self.tableView.removeSeparatorLine([cell])
            return cell
        }
        else{
            let upcomingCell = "UpcomingCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: upcomingCell, for: indexPath) as! UpcomingCell
            cell.showDetails(upCommingBooking[indexPath.row])
            self.tableView.removeSeparatorLine([cell])
            return cell
        }
     //load more
        let row = indexPath.row
        if (row == upCommingBooking.count && !isShowBookingDetail) || (row == upCommingBooking.count + 1 && isShowBookingDetail) {
            let cell = loadMoreCell()
            return cell
        }
    }
    
    func loadMoreCell() -> UITableViewCell {
        var cell: UITableViewCell?
        let loadMoreId = "LoadMoreCell"
        cell = tableView.dequeueReusableCell(withIdentifier: loadMoreId)
        
        if (cell == nil) {
            cell = UITableViewCell(style: .default, reuseIdentifier: loadMoreId)
        }
        // Remove the last separator line.
        cell?.removeSeparatorLine()
        if (upCommingBooking.count == 0) || upCommingBooking.count == totalupComingBookingHistory {
            cell!.isHidden = true
        }
        else {
            countTime += 1
            // getbookingHistoryRequest()
            
            for subView in (cell?.contentView.subviews)! {
                if subView.isKind(of: UIActivityIndicatorView.self) {
                    (subView as! UIActivityIndicatorView).startAnimating()
                }
            }
        }
        
        return cell!
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if upCommingBooking.count > 0 {
            return 260
        }
        return tableView.frame.size.height - 40
    }
    // MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            return
        }
        guard let _ = tableView.cellForRow(at: indexPath) as? UpcomingCell else {
            return
        }
    }
    
    
    
    //MARK: - IBAction
    @IBAction func call(_ sender: AnyObject) {
        
        guard let callButton = sender as? UIButton else {
            return
        }
        
        let buttonPosition = callButton.convert(CGPoint.zero, to: self.tableView)
        
        guard let indexPath =  self.tableView.indexPathForRow(at: buttonPosition) else {
            return
        }
        selectedBooking = indexPath.row
        selectedIndex = indexPath
        let booking = upCommingBooking[selectedIndex.row]
        showCallAlert(booking.maid?.phone)
    }
    func showCallAlert(_ phoneNumber: String?) {
        guard let phoneNumber = phoneNumber else {
            let alert = UIAlertController(title: nil, message: LocalizedStrings.noPhoneNumberMessage, preferredStyle: .alert)
            let action = UIAlertAction(title: LocalizedStrings.okButton, style: UIAlertActionStyle.default, handler: nil)
            
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        self.callNumber(phoneNumber)
    }
    
    fileprivate func callNumber(_ phoneNumber:String) {
        let number = StringHelper.addPlusSign(phoneNumber)
        
        if let phoneCallURL:URL = URL(string: "telprompt://\(number)") {
            let application:UIApplication = UIApplication.shared
            if (application.canOpenURL(phoneCallURL)) {
                application.openURL(phoneCallURL)
            }
        }
    }
    
    // MARK: - API
    
    func fetchUpcomingBookingsRequest() {
        
        let params = fetchUpcomingBookings.getParams()
        print("up coming Booking params: ", params)
        sendRequest(params, request: fetchUpcomingBookings, requestType: .fetchAllUpcomingBookings, isSetLoadingView: false, view: nil)
        
    }
    func cancelABookingRequest() {
        let params = cancelBooking.getParams(upCommingBooking[selectedIndex.row].bookingID!)
        print("Cancel booking params: ", params)
        setDefaultUIForLoadingIndicator()
        sendRequest(params, request: cancelBooking, requestType: .cancelBooking, isSetLoadingView: false, view: (selectedCell?.contentView == nil ? nil : selectedCell!.contentView))
    }
    func sendRequest(_ parameters: [String: AnyObject]?,
                     request: RequestManager,
                     requestType: RequestType,
                     isSetLoadingView: Bool, view: UIView?) {
        
        
        // Check for internet connection
        if RequestHelper.isInternetConnectionFailed() {
            RequestHelper.showNoInternetConnectionAlert(self)
            stopRefreshing()
            return
        }
        
        // Set loading view center
        if isSetLoadingView && view != nil {
            self.setRequestLoadingViewCenter1(view!)
        }
		
		if upCommingBooking.count == 0 {
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
        // End refresh control
        stopRefreshing()
        if result.messageCode != MessageCode.success {
            // Show alert
            handleResponseError(result.messageCode, title: LocalizedStrings.internalErrorTitle, message: result.messageInfo, requestType: requestType)
            
            if let error = result.messageCode {
                messageCode = error
            }
            return
        }
        setUserInteraction(true)
        if requestType == .fetchAllUpcomingBookings {
            handleFetchUpcomingBookingsResponse(result, requestType: .fetchAllUpcomingBookings)
        }
        if requestType == .cancelBooking {
            handleCancelBookingsResponse(result, requestType: .cancelBooking)
        }

    }
    
    func handleFetchUpcomingBookingsResponse(_ result: ResponseObject, requestType: RequestType) {
        //setUserInteraction(true)
        guard let list = result.body else {
            return
        }
        let bookingList = fetchUpcomingBookings.getBookingList(list)
		totalupComingBookingHistory = bookingList.count
		
		//        for booking in result.bookings {
		//            bookingHistory.append(booking)
		//        }
		
		var newBooking = false
		if upCommingBooking.count != bookingList.count {
			newBooking = true
		}else{
			for eachBooking in bookingList {
				let results = bookingList.filter { $0.bookingID == eachBooking.bookingID }
				if results.count == 0 {
					newBooking = true
					break
				}
			}
		}
		
		if newBooking {
			// Cache service list
			upCommingBooking = bookingList
			let realm = try! Realm()
			try! realm.write {
				realm.add(bookingList, update: true)
			}
			self.tableView.reloadData()
		}
		
		if upCommingBooking.count == 0 {
			// If no upcoming bookings, switch to past bookings
			(self.parent as! CustomTabbarViewController).segmented.selectedSegmentIndex = 1
			(self.parent as! CustomTabbarViewController).selectedSegment()
		}
    }
    
    func handleCancelBookingsResponse(_ result: ResponseObject, requestType: RequestType) {
        let refundAmount = result.body == nil ? 0 : result.body!["charge"]["refunded_amount"].float
        let message = LocalizedStrings.cancelSuccessMessage + LocalizedStrings.currency + " \(refundAmount == nil ? 0 : refundAmount!) " 
                showAlertView(LocalizedStrings.cancelSuccessTitle, message: message, requestType: nil)
        // Cancel on the UI
        cancelBooking(selectedCell)
    
    }
    
        
    //MARK: - IBAction
    @IBAction func cancel(_ sender: AnyObject) {
        getSelectedCell(sender)
        guard let cancelButton = sender as? UIButton else {
            return
        }
        
        let buttonPosition = cancelButton.convert(CGPoint.zero, to: self.tableView)
        
        guard let indexPath =  self.tableView.indexPathForRow(at: buttonPosition) else {
            return
        }
        selectedBooking = indexPath.row
        selectedIndex = indexPath
        self.performSegue(withIdentifier: SegueIdentifiers.showCancelBooking, sender: self)
        
    }
    //MARK: - Unwind segue
    func getSelectedCell(_ sender: AnyObject) {
        guard let cancelButton = sender as? UIButton else {
            return
        }
        
        let buttonPosition = cancelButton.convert(CGPoint.zero, to: self.tableView)
        
        guard let indexPath =  self.tableView.indexPathForRow(at: buttonPosition) else {
            return
        }
        
        guard let upcomingCell = self.tableView.cellForRow(at: indexPath) as? UpcomingCell else {
            return
        }
        selectedCell = upcomingCell
    }
    func cancelBooking(_ upcomingCell: UpcomingCell?) {
        let currentCell = selectedIndex.row
        upCommingBooking.remove(at: currentCell)
        self.tableView.reloadData()
         NotificationCenter.default.post(name: Notification.Name(rawValue: "updateBookinghistory"), object: nil)
        // Hide this session if there is no more upcomming booking
        if upCommingBooking.count <= 0 {
            tableView.beginUpdates()
            tableView.reloadData()
            tableView.endUpdates()
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueIdentifiers.showCancelBooking {
            
            guard let destination = segue.destination as? CancelBookingViewController else {
                return
            }
            guard let selectedIndex = selectedIndex else {
                return
            }
            destination.delegate = self
            destination.upcomingVC = self
            destination.booking = upCommingBooking[selectedIndex.row]
        }
        
    }
}
extension UpcomingBookingViewController: CancelBookingViewControllerDelegate {
    func didDismissCancelBooking(_ isCanceled: Bool) {
        // Cancel bookings
        if isCanceled {
            cancelABookingRequest()
        }
    }
}

