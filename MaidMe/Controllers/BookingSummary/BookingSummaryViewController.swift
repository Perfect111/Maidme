//
//  BookingSummaryViewController.swift
//  MaidMe
//
//  Created by Viktor on3/16/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit

protocol PushToOderBookingDelegate {
    func pushToOrderBooking(_ flag: Bool)
}
class BookingSummaryViewController: BaseTableViewController {
    
    
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var payerLabel: UILabel!
    @IBOutlet weak var cardEndingNumberLabel: UILabel!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var serviceLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var workingHoursLabel: UILabel!
    @IBOutlet weak var bookingCodeLabel: UILabel!
    @IBOutlet weak var ratingView: RatingStars!
    @IBOutlet weak var workerImage: UIImageView!
    @IBOutlet weak var workerNameLabel: UILabel!
//    var navController: UINavigationController?
//    var currentViewcontroller: AnyObject?
    
    var bookingInfo: Booking!
    var pushOderDelegate: PushToOderBookingDelegate?
   
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Disable go back to previous screen
        self.hideBackbutton(true)
        // Show booking info
        workerImage.layer.cornerRadius = self.workerImage.frame.height/2
        workerImage.layer.masksToBounds = true
        showBookingInfo(bookingInfo)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: -Action
    @IBAction func showBooking(_ sender: AnyObject){
        self.dismiss(animated: true) {
            self.pushOderDelegate?.pushToOrderBooking(true)
            NotificationCenter.default.post(name: Notification.Name(rawValue: "showUpComming"), object: self)
        }
    }
    
    
//    func showBookingList() {
//        let storyboard = self.storyboard
//        guard let bookingVC = storyboard?.instantiateViewControllerWithIdentifier(StoryboardIDs.customTab) as? CustomTabbarViewController else {
//            return
//        }
//        
//        guard let _ = currentViewcontroller as? CustomTabbarViewController else {
//            self.navController?.pushViewController(bookingVC, animated: true)
//            return
//        }
//        
//    }
    
    // MARK: - UI
    func showBookingInfo(_ bookingInfo: Booking) {
        let price = (bookingInfo.price == 0 ? 0 : bookingInfo.price) + (bookingInfo.materialPrice == 0 ? 0 : bookingInfo.materialPrice)
        amountLabel.text = LocalizedStrings.currency + " " + String.localizedStringWithFormat("%.2f", price)
        cardEndingNumberLabel.text = (bookingInfo.responseDic?.card_number)!
        workerNameLabel.text = bookingInfo.workerName
        startTimeLabel.text = DateTimeHelper.getStringFromDate(bookingInfo.time!, format: "MMM dd yyyy, HH:mma")
        serviceLabel.text = bookingInfo.service?.name
        workingHoursLabel.text = StringHelper.getHourString(bookingInfo.hours)
        bookingCodeLabel.text = (bookingInfo.bookingCode == nil ? "" : "Ref. \(bookingInfo.bookingCode!)")
        ratingView.setRatingLevel((bookingInfo.maid?.rateAverage)!)
        addressLabel.text = cutString((bookingInfo.address?.buildingName)!)
        if let workerImageString = bookingInfo.avartar {
            if workerImageString != "" {
                loadMaidImageFromURL(workerImageString, imageLoad: self.workerImage)
            } else {
                self.workerImage.image = UIImage(named: "noun")
                
            }
        } else {
        }
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 3 {
            if self.view.frame.size.height > 550 {
                return (self.view.frame.size.height - 290)
            } else {
                return 260
            }
        }
        return super.tableView(tableView, heightForRowAt: indexPath)
    }
    
}
