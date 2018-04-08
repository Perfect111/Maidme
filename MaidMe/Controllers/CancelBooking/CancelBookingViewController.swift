//
//  CancelBookingViewController.swift
//  MaidMe
//
//  Created by Viktor on 3/16/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit

protocol CancelBookingViewControllerDelegate {
    func didDismissCancelBooking(_ isCanceled: Bool)
}

class CancelBookingViewController: UIViewController {

    @IBOutlet weak var cancelWithRefundView: UIView!
    @IBOutlet var cancelWithoutRefundView: UIView!
    @IBOutlet weak var refundLabel: UITextView!
    
    var delegate: CancelBookingViewControllerDelegate?
    var isCanceled: Bool = false
    var booking: Booking!
    var cancelType: CancelType!
    var upcomingVC  : UpcomingBookingViewController?
    // MARK: - Life cycle
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print(booking.companySetting)
        showSuitableCancelUI(booking.time! as Date, cancelTime: 120, isPressedButton: false)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.dismiss(animated: true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UI
    
    func showSuitableCancelUI(_ bookingTime: Date, cancelTime: Int, isPressedButton: Bool) {
        // If current < cancel time: show cancel without charge UI
        // If current in range (cancel time, booking time): show cancel with refund UI
        // If current time > booking time: show cancel without refund UI
        let localBookingTime = bookingTime.toLocalTime(DateFormater.twelvehoursFormat)
        let bookingTimeInterval = localBookingTime.timeIntervalSince1970
        let minTime = bookingTimeInterval - Double(cancelTime * 60)
        let allowedCancelTime = Date(timeIntervalSince1970: minTime)
        let currentTime = Date()
        
        if currentTime.compare(allowedCancelTime) == ComparisonResult.orderedAscending {
            if isPressedButton && cancelType == .refundAll {
                // Dismiss view controller
                self.dismiss(animated: true, completion: nil)
                return
            }
            
            cancelType = .refundAll
            cancelUI(false)
        }
        else {
            if currentTime.compare(localBookingTime) == ComparisonResult.orderedAscending {
                if isPressedButton && cancelType == .chargeFee {
                    // Dismiss view controller
                    self.dismiss(animated: true, completion: nil)
                    return
                }
                
                if isPressedButton && cancelType == .refundAll {
                    updateCancelUI(true)
                }
                else {
                    cancelUI(true)
                }
                
                cancelType = .chargeFee
            }
            else {
                if isPressedButton && cancelType == .noRefund {
                    // Dismiss view controller
                    self.dismiss(animated: true, completion: nil)
                    return
                }
                
                cancelType = .noRefund
                showCancelWithouRefundView()
            }
        }
        
        

    }
    
    func cancelUI(_ isRefund: Bool) {
        showCancelWithRefundView()
        
        if isRefund {
            let fee = (booking.companySetting?.refundFee == 0 ? 0.0 : booking.companySetting!.refundFee)
            let feeFloor = floor(fee)
            
            if fee - feeFloor == 0 {
                refundLabel.text = "*\(Int(fee))\(LocalizedStrings.refundFeeMessage)"
            }
            else {
                refundLabel.text = "*\(String.localizedStringWithFormat("%.2f", fee))\(LocalizedStrings.refundFeeMessage)"
            }
        }
        else {
            refundLabel.text = LocalizedStrings.noRefundFeeMessage
        }
    }
    
    func updateCancelUI(_ isRefund: Bool) {
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.refundLabel.frame.origin.x = -self.cancelWithRefundView.frame.width
            }, completion: { Void in
                self.refundLabel.frame.origin.x = self.cancelWithRefundView.frame.width
                self.cancelUI(isRefund)
                
                UIView.animate(withDuration: 0.2, animations: {
                    self.refundLabel.frame.origin.x = (self.cancelWithRefundView.frame.width - self.refundLabel.frame.width) / 2
                }) 
        }) 
    }
    
    func showCancelWithouRefundView() {
        let width = self.view.frame.width * 0.9
        let height = cancelWithoutRefundView.frame.height
        cancelWithRefundView.isHidden = true
        cancelWithoutRefundView.frame = CGRect(x: (self.view.frame.width - width) / 2, y: (self.view.frame.height - height) / 2, width: width, height: height)
        self.view.addSubview(cancelWithoutRefundView)
    }
    
    func showCancelWithRefundView() {
        cancelWithoutRefundView.removeFromSuperview()
        cancelWithRefundView.isHidden = false
    }
    
    // MARK: - IBActions
    
    @IBAction func onAgreeCancelAction(_ sender: AnyObject) {
        isCanceled = true
        delegate?.didDismissCancelBooking(isCanceled)
        showSuitableCancelUI(booking.time! as Date, cancelTime: 120, isPressedButton: true)
       
            }
    
    @IBAction func onDisagreeCancelAction(_ sender: AnyObject) {
        isCanceled = false
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "" {
            guard let destination = segue.destination as? UpcomingBookingViewController else {
                return
            }
            
            destination.isCanceled = true
        }
    }
}

enum CancelType {
    case refundAll
    case chargeFee
    case noRefund
}
