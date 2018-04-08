//
//  CustomerAddressMenu.swift
//  MaidMe
//
//  Created by Viktor on 12/15/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SSKeychain

var customerSelectedAddress: Address?



class AddressMenu: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var navController: UINavigationController?
    var currentViewController: AnyObject!
    var searchResultsVC : SearchResultsViewController?
    var availabelServiceVC: AvailabelServicesViewController?
    var suggestedWorkerVC : SuggestionTableViewController?
    var addressList = [Address]()
    var selectedAddress: Address?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(AddressMenu.tapGesture))
        tapGesture.cancelsTouchesInView = false // avoid tap gesture on the tableview
        self.view.addGestureRecognizer(tapGesture)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        let transition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromTop
        self.view.layer.add(transition, forKey:kCATransition)
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: - UI
    func setupTableView() {
        self.tableView.backgroundColor = UIColor(white: 0, alpha: 0.2)
        self.tableView.separatorColor = UIColor.white
        self.tableView.hideTableEmptyCell()
    }
    @objc func tapGesture() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func searchWithAreaId(_ indexPath: IndexPath) {
        let address = addressList[indexPath.row]
        if address.workingArea_ref != nil {
            self.searchResultsVC?.fetchSearchResultsWithAreaId(address.workingArea_ref!, address: address)
        }
    }
    
    func selectAddressToSearch(_ indexPath: IndexPath){
        let address = addressList[indexPath.row]
        if address.workingArea_ref != nil {
            self.availabelServiceVC?.getAreaIdToSearch(address)
        }
    }
}


// MARK: - UITableViewDataSource

extension AddressMenu: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if addressList.count != 0 {
            return addressList.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! AddressMenuCell
        if addressList.count != 0 {
            let address = addressList[indexPath.row]
            cell.addressTitle.text = address.buildingName
        }
        return cell
    }
}

// MARK: - UITableViewDelegate

extension AddressMenu: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Dismiss the menu
        tapGesture()
        customerSelectedAddress = addressList[indexPath.row]
        
        if searchResultsVC != nil {
            self.searchWithAreaId(indexPath)
        }
        if availabelServiceVC != nil {
            self.selectAddressToSearch(indexPath)
        }
        if suggestedWorkerVC != nil {
            self.suggestedWorkerVC?.selectAddressFromAddressMenu(addressList[indexPath.row])
        }

    }
}


