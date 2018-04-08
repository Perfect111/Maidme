//
//  TestVC.swift
//  MaidMe
//
//  Created by Viktor on 12/24/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit

protocol SelectDateDelegate {
    func selectedDate(_ dateSelected: Date)
}

class TestVC: UIViewController {
    
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    var dateSelected: Date?
    var delegate: SelectDateDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handlerDismiss)))
//        setUpDateTimePicker()
        // Do any additional setup after loading the view.
		
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        self.view.backgroundColor = UIColor(white: 0, alpha: 0.4)
        self.view.alpha = 0
        self.bottomView.frame = CGRect(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: 250)
        UIView.animate(withDuration: 0.3, animations: {
            self.view.alpha = 1
            self.bottomView.frame = CGRect(x: 0, y: self.view.frame.height - 250, width: self.view.frame.width, height: 250)
        }) 
    }
    @objc func handlerDismiss() {
        UIView.animate(withDuration: 0.3, animations: {
            self.bottomView.frame = CGRect(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: 250)
            self.view.alpha = 0
            self.dismiss(animated: true, completion: nil)
        }) 
        
    }
    func setUpDateTimePicker() {
        let nextRoundedTime = Date().getNextOneRoundedHourTime()
        datePicker.minimumDate = nextRoundedTime
        datePicker.maximumDate = nextRoundedTime.getNext7Days()
        // Set default day
        datePicker.setDate(nextRoundedTime, animated: false)
        datePickerChanged(nextRoundedTime, dateFormat: DateFormater.twelvehoursFormat)
    }
    func datePickerChanged(_ date: Date, dateFormat: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        self.dateSelected = date
//        let beforeDate = date.dateByAddingTimeInterval(2 * 60 * 60)
    }
    
    @IBAction func dismiss() {
    }
    
    @IBAction func datePickerAction(_ sender: AnyObject) {
        if sender.restorationIdentifier == "datePicker" {
            datePickerChanged(datePicker.date, dateFormat: DateFormater.twelvehoursFormat)
        }
    }
    @IBAction func selectDateAction(_ sender: AnyObject) {
        delegate?.selectedDate(dateSelected!)
        handlerDismiss()
    }
    
}

