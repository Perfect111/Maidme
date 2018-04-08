//
//  ScheduleView.swift
//  MaidMe
//
//  Created by Viktor on 3/13/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit

class ScheduleView: UIView {

    @IBOutlet var view: UIView!
    @IBOutlet weak var workerNameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var hourLabel: UILabel!
    @IBOutlet weak var serviceLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var bookingCodeLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        Bundle.main.loadNibNamed(StoryboardIDs.scheduleView, owner: self, options: nil)
        
        self.view.frame = self.bounds
        self.addSubview(view)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        Bundle.main.loadNibNamed(StoryboardIDs.scheduleView, owner: self, options: nil)
        
        self.view.frame = self.bounds
        self.addSubview(view)
    }
    
    func setScheduleContent(_ booking: Booking) {
        workerNameLabel.text = "\(booking.maid?.firstName == nil ? "" : booking.maid!.firstName!) \(booking.maid?.lastName == nil ? "" : booking.maid!.lastName!)"
        
        let date = booking.time!.toLocalTime(DateFormater.twelvehoursFormat)
        timeLabel.text = DateTimeHelper.getStringFromDate(date, format: DateFormater.twelvehoursFormat)
        hourLabel.text = StringHelper.getHourString(booking.hours)
        serviceLabel.text = booking.service?.name
        
        let price = (booking.price == 0 ? 0 : booking.price)
        priceLabel.text = "AED \(price)"
        bookingCodeLabel.text = (booking.bookingCode == nil ? "" : booking.bookingCode!)
    }
}
