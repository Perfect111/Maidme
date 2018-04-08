//
//  WorkingAreaTableViewController.swift
//  MaidMe
//
//  Created by Viktor on4/26/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

protocol WorkingAreaTableViewControllerDelegate {
    func didSelectArea(_ selectedArea: WorkingArea?)
}

class WorkingAreaTableViewController: BaseTableViewController {
    
    let workingAreaAPI = FetchWorkingAreaService()
    var messageCode: MessageCode?
    var areaList: [WorkingArea]?
    var filteredAreas = [WorkingArea]()
    var selectedArea: WorkingArea?
    var selectedAreaIndex: Int?
    var searchController: UISearchController!
    var delegate: WorkingAreaTableViewControllerDelegate?
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchDefaultAreaRequest()
        setUpSearchController()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        dismissKeyboard()
    }
    
    deinit {
        self.searchController.view.removeFromSuperview()
    }
    
    // MARK: UI
    func setUpSearchController() {
        self.searchController = ({
            let controller = UISearchController(searchResultsController: nil)
            
            controller.hidesNavigationBarDuringPresentation = false
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            definesPresentationContext = true
            controller.searchBar.searchBarStyle = UISearchBarStyle.prominent
            // 6
            
            controller.searchBar.scopeButtonTitles = []
            controller.searchBar.sizeToFit() // Needed for iOS 8
            tableView.tableHeaderView = controller.searchBar
            //self.navigationItem.titleView = controller.searchBar
            
            return controller
        })()
    }
    
    // MARK: - IBActions
    
    @IBAction func onCancelAction(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - API
    
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
        
        if requestType == .fetchWorkingArea {
            handleFetchWorkingAreaResponse(result, requestType: .fetchWorkingArea)
        }
    }
    
    func handleFetchWorkingAreaResponse(_ result: ResponseObject, requestType: RequestType) {
        setUserInteraction(true)
        
        var list = [String]()
        var listArea = [WorkingArea]()
        
        for (_, dic) in result.body! {
            let item = WorkingArea(areaDic: dic)
            if item.areaID == nil && item.emirate != nil && item.area != nil {
                continue
            }
            
            listArea.append(item)
            list.append("\(item.emirate!) - \(item.area!)")
        }
        
        areaList = listArea
        self.tableView.reloadData()
    }
    
    // MARK: - Handle UIAlertViewAction
    
    override func handleTryAgainTimeoutAction(_ requestType: RequestType) {
        if requestType == .fetchWorkingArea {
            self.fetchDefaultAreaRequest()
        }
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        guard let areaList = areaList else {
            return
        }
        filteredAreas = areaList.filter { area in
            return area.area!.lowercased().contains(searchText.lowercased())
        }
        
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let areaList = areaList else {
            return 0
        }
        
        guard let _ = searchController else {
            return areaList.count
        }
        
        if searchController.isActive && searchController.searchBar.text != "" {
            return filteredAreas.count
        }
        else {
            return areaList.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "workingAreaCell", for: indexPath) as! WorkingAreaCell

        guard let areaList = areaList else {
            return cell
        }
        
        var area: WorkingArea
        
        if searchController != nil {
            if searchController.isActive && searchController.searchBar.text != "" {
                area = filteredAreas[indexPath.row]
            }
            else {
                area = areaList[indexPath.row]
            }
        }
        else {
            area = areaList[indexPath.row]
        }
        
        cell.areaName.text = area.emirate! + " - " + area.area!

        if indexPath.row == selectedAreaIndex {
            cell.accessoryType = .checkmark
        }
        else {
            cell.accessoryType = .none
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let index = selectedAreaIndex {
            let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0))
            cell?.accessoryType = .none
        }
        
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .checkmark
        
        if searchController.isActive && searchController.searchBar.text != "" {
            selectedAreaIndex = indexPath.row
            selectedArea = filteredAreas[selectedAreaIndex!]
        }
        else {
            selectedAreaIndex = indexPath.row
            selectedArea = areaList![selectedAreaIndex!]
        }
        
        DispatchQueue.main.async { () -> Void in
            self.dismiss(animated: true, completion: nil)
            self.dismiss(animated: true, completion: nil)
        }
        
        delegate?.didSelectArea(selectedArea)
    }
}

// MARK: - UISearchResultsUpdating

extension WorkingAreaTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
