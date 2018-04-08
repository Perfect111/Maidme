//
//  SelectExprixeDateView.swift
//  MaidMe
//
//  Created by Viktor on 1/6/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import UIKit

protocol SelectExpiryDateDelegate{
    func showExpiryDate(_ expiryDate: Date)
}

class SelectExprixeDateView: BaseViewController {
    
    @IBOutlet weak var datePicker: MAKMonthPicker!
    @IBOutlet weak var bottomView: UIView!
    var expiryDate: Date?
    var delegate: SelectExpiryDateDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        datePicker.yearRange = NSRange(location: Date().getCurrentYear(), length: 100)
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handlerDismiss)))
        datePicker.monthPickerDelegate = self
    
    }
    
    func setupDatePicker() {
        
        datePicker.format = [MAKMonthPickerFormat.month, MAKMonthPickerFormat.year]
        datePicker.monthFormat = "%n"
        datePicker.date = Date(timeIntervalSinceNow: -ktTimeInMonth)
        datePicker.yearRange = NSMakeRange(2000, 10000)
    }
    
    func datePickerChanged(_ date: Date, dateFormat: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        expiryDate = date
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
    
    @IBAction func selectExpiryDateAction(_ sender: AnyObject?){
        
        if expiryDate != nil {
            delegate?.showExpiryDate(expiryDate!)
        } else {
            expiryDate = Date()
            delegate?.showExpiryDate(expiryDate!)
        }
        handlerDismiss()
    }
    
    
    
}

extension SelectExprixeDateView: MAKMonthPickerDelegate {
    
    func monthPickerDidChangeDate(_ picker: MAKMonthPicker) {
        if picker.restorationIdentifier == "expirydatePicker" {
            datePickerChanged(picker.date, dateFormat: DateFormater.monthYearFormat)
        }
    }
}

