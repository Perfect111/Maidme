//
//  MaidProfileTableViewController.swift
//  MaidMe
//
//  Created by Viktor on2/26/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit
import Alamofire

class MaidProfileTableViewController: BaseTableViewController {
    
    var maid: Worker!
    var getRatingsAndCommentsAPI = GetAllRatingsAndCommentsService()
    var totalReviews = 0
    var bookingList = [Booking]()
    var nextTime: Double = 0
    var maxLoadedItems = 5
    var headerRows = 2
    var isFirstLoading = true
    
    var refreshItemControl: UIRefreshControl!
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Enable go back to previous screen
        self.hideBackbutton(false)
        setupRefreshControl()
        
        // Get ratings and comments of this maid
        nextTime = Date().timeIntervalSince1970 * 1000
        getRatingsAndCommentsRequest(nextTime)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.hideTableEmptyCell()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        bookingList.removeAll()
        nextTime = 0
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if totalReviews > bookingList.count {//maxLoadedItems {
            return headerRows + bookingList.count + 1 // 1 is for load more cell
        }
        
        return headerRows + bookingList.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 96.0
        }
        if indexPath.row == 1 {
            return 74.0
        }
        if indexPath.row == headerRows + bookingList.count {
            return 44.0
        }
        
        let string = bookingList[indexPath.row - headerRows].comment
        let newHeight = StringHelper.getTextHeight(string == nil ? "" : string!, width: self.tableView.frame.width - 15 * 4, fontSize: 16.0) // 15 is the text and frame padding
        
        return 190.0 + newHeight - 54 // 54 is the design height for textview
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let nameIdentifier = "profileNameCell"
        let reviewIdentifier = "profileReviewCell"
        let commentIdentifier = "profileReviewDetailCell"
        
        // Show load more
        let row = indexPath.row
        
        if (row == headerRows + bookingList.count - 1) && bookingList.count > 0 {
            if let time = bookingList[indexPath.row - headerRows].timeOfRating {
                nextTime = time.timeIntervalSince1970 * 1000 + Double(NSTimeZone.local.secondsFromGMT() * 1000)
            }
        }
        
        if (row == headerRows + bookingList.count) {
            let cell = loadMoreCell()
            return cell
        }
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: nameIdentifier, for: indexPath) as! ProfileNameCell
            self.tableView.removeSeparatorLineInset([cell])
            cell.showMaidDetails(maid)
            return cell
        }
        
        if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: reviewIdentifier, for: indexPath) as! ProfileReviewCell
            self.tableView.removeSeparatorLineInset([cell])
            cell.showTotalReview(totalReviews)
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: commentIdentifier, for: indexPath) as! ProfileReviewDetailCell
        self.tableView.removeSeparatorLine([cell])
        cell.showDetail(bookingList[indexPath.row - headerRows])
        return cell
    }

    func loadMoreCell() -> UITableViewCell {
        var cell: UITableViewCell?
        let loadMoreId = "LoadMoreCell"
        cell = tableView.dequeueReusableCell(withIdentifier: loadMoreId)
        
        if (cell == nil) {
            cell = UITableViewCell(style: .default, reuseIdentifier: loadMoreId)
        }
        
        // Remove the last separator line.
        cell!.separatorInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, cell!.bounds.size.width)
        
        if (bookingList.count == 0) || bookingList.count == totalReviews {
            cell!.isHidden = true
        }
        else {
            isFirstLoading = false
            getRatingsAndCommentsRequest(nextTime)
            
            for subView in (cell?.contentView.subviews)! {
                if subView.isKind(of: UIActivityIndicatorView.self) {
                    (subView as! UIActivityIndicatorView).startAnimating()
                }
            }
        }
        
        return cell!
    }

    // MARK: API

    func getRatingsAndCommentsRequest(_ fromDate: Double) {
        let params = getRatingsAndCommentsAPI.getParams(maid.workerID, fromDate: fromDate, limit: maxLoadedItems)
        print("Rating comment params: ", params)
        sendRequest(params, request: getRatingsAndCommentsAPI, requestType: .getRatingsAndComments, isSetLoadingView: true, view: nil)
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
        
        // End refresh control
        stopRefreshing()
        
        if result.messageCode != MessageCode.success {
            // Show alert
            handleResponseError(result.messageCode, title: LocalizedStrings.internalErrorTitle, message: result.messageInfo, requestType: requestType)
            return
        }
        
        if requestType == .getRatingsAndComments {
            handleFetchUpcomingBookingsResponse(result, requestType: .getRatingsAndComments)
        }
    }
    
    func handleFetchUpcomingBookingsResponse(_ result: ResponseObject, requestType: RequestType) {
        setUserInteraction(true)
        
        guard let list = result.body else {
            return
        }
        
        let result = getRatingsAndCommentsAPI.getBookingList(list)
        
        if isFirstLoading {
            totalReviews = result.total
        }
        
        for booking in result.bookings {
            bookingList.append(booking)
        }
        
        self.tableView.reloadData()
    }
    
    // MARK: - Handle UIAlertViewAction
    
    override func handleTryAgainTimeoutAction(_ requestType: RequestType) {
        if requestType == .getRatingsAndComments {
            self.getRatingsAndCommentsRequest(nextTime)
        }
    }

    // MARK: - Scroll view Delegate
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if refreshItemControl.isRefreshing {
            refreshResult()
            isFirstLoading = true
            getRatingsAndCommentsRequest(Date().timeIntervalSince1970 * 1000)
        }
    }

}
