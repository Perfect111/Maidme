//
//  DateTimePicker.swift
//  DateTimePicker
//
//  Created by Huong Do on 9/16/16.
//  Copyright © 2016 ichigo. All rights reserved.
//

import UIKit


@objc open class DateTimePicker: UIView {
    
    let contentHeight: CGFloat = 270
    
    // public vars
    open var backgroundViewColor: UIColor = UIColor.clear {
        didSet {
            backgroundColor = backgroundViewColor
        }
    }
    
    open var highlightColor = UIColor(red: 0/255.0, green: 199.0/255.0, blue: 194.0/255.0, alpha: 1) {
        didSet {
            todayButton.setTitleColor(highlightColor, for: UIControlState())
            colonLabel.textColor = highlightColor
        }
    }
    
    open var darkColor = UIColor(red: 0, green: 22.0/255.0, blue: 39.0/255.0, alpha: 1)
    
    open var daysBackgroundColor = UIColor(red: 239.0/255.0, green: 243.0/255.0, blue: 244.0/255.0, alpha: 1)
    
    var didLayoutAtOnce = false
    
    var isModifyScrollY = true
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        // For the first time view will be layouted manually before show
        // For next times we need relayout it because of screen rotation etc.
        if !didLayoutAtOnce {
            didLayoutAtOnce = true
        } else {
            self.configureView()
        }
    }
    
    open var selectedDate = Date() {
        didSet {
            resetDateTitle()
        }
    }
    
    open var timeInterval = 1 {
        didSet {
            resetDateTitle()
        }
    }
    
    open var dateFormat = "HH:mm dd/MM/YYYY" {
        didSet {
            resetDateTitle()
        }
    }
    
    open var todayButtonTitle = "Today" {
        didSet {
            todayButton.setTitle(todayButtonTitle, for: UIControlState())
            let size = todayButton.sizeThatFits(CGSize(width: 0, height: 44.0)).width + 10.0
            todayButton.frame = CGRect(x: contentView.frame.width - size, y: 0, width: size, height: 44)
        }
    }
    open var doneButtonTitle = "DONE" {
        didSet {
            doneButton.setTitle(doneButtonTitle, for: UIControlState())
        }
    }
    open var completionHandler: ((Date)->Void)?
    
    // private vars
    internal var hourTableView: UITableView!
    internal var minuteTableView: UITableView!
    internal var dayCollectionView: UICollectionView!
    
    fileprivate var contentView: UIView!
    fileprivate var dateTitleLabel: UILabel!
    fileprivate var todayButton: UIButton!
    fileprivate var doneButton: UIButton!
    fileprivate var colonLabel: UILabel!
    
    fileprivate var minimumDate: Date!
    fileprivate var maximumDate: Date!
	
    internal var calendar: Calendar = Calendar.current
    internal var dates: [Date]! = []
    internal var components: DateComponents!
    
	internal var shadow : UIView!
    
    @objc class func show(_ selected: Date? = nil, minimumDate: Date? = nil, maximumDate: Date? = nil) -> DateTimePicker {
		
		var defaultDate = Date()
		let calendar = Calendar.current
		let comp = (calendar as NSCalendar).components([.hour], from: defaultDate)
		let hour = comp.hour
		if hour! >= 18 {
			// If it's later than 18:00
			defaultDate = (calendar as NSCalendar).date(byAdding: .day,value: 1,to: defaultDate,options: [])!
			defaultDate = defaultDate.setTo8AM()
		}
		
        let dateTimePicker = DateTimePicker()
        dateTimePicker.selectedDate = selected ?? defaultDate
        dateTimePicker.minimumDate = minimumDate ?? Date(timeIntervalSinceNow: -3600 * 24 * 365 * 20)
        dateTimePicker.maximumDate = maximumDate ?? Date(timeIntervalSinceNow: 3600 * 24 * 365 * 20)
        assert(dateTimePicker.minimumDate.compare(dateTimePicker.maximumDate) == .orderedAscending, "Minimum date should be earlier than maximum date")
//        assert(dateTimePicker.minimumDate.compare(dateTimePicker.selectedDate) != .OrderedDescending || dateTimePicker.minimumDate.compare(dateTimePicker.selectedDate) == .OrderedSame, "Selected date should be later or equal to minimum date")
        assert(dateTimePicker.selectedDate.compare(dateTimePicker.maximumDate) != .orderedDescending, "Selected date should be earlier or equal to maximum date")
        
        dateTimePicker.configureView()
        UIApplication.shared.keyWindow?.addSubview(dateTimePicker)
        
        return dateTimePicker
    }
	
	
    @objc func dismissCalendar() {
		self.dismissView()
	}
    
    fileprivate func configureView() {
        if self.contentView != nil {
            self.contentView.removeFromSuperview()
        }
        let screenSize = UIScreen.main.bounds.size
		
		shadow = UIView(frame: UIScreen.main.bounds)
		shadow.backgroundColor = UIColor.black
		shadow.alpha = 0.0
		shadow.isUserInteractionEnabled = true
		self.addSubview(shadow)
		let tap = UITapGestureRecognizer(target: self, action: #selector(dismissCalendar))
		tap.numberOfTapsRequired = 1
		shadow.addGestureRecognizer(tap)
		UIView.animate(withDuration: 0.3, animations: {
			self.shadow.alpha = 0.5
		}) 
		
		
        self.frame = CGRect(x: 0,
                            y: 0,
                            width: screenSize.width,
                            height: screenSize.height)
        
        // content view
        contentView = UIView(frame: CGRect(x: 0,
                                           y: frame.height,
                                           width: frame.width,
                                           height: contentHeight))
        contentView.layer.shadowColor = UIColor(white: 0, alpha: 0.3).cgColor
        contentView.layer.shadowOffset = CGSize(width: 0, height: -2.0)
        contentView.layer.shadowRadius = 1.5
        contentView.layer.shadowOpacity = 0.5
        contentView.backgroundColor = UIColor.white
        contentView.isHidden = true
        addSubview(contentView)
        
        // title view
        let titleView = UIView(frame: CGRect(origin: CGPoint.zero,
                                             size: CGSize(width: contentView.frame.width, height: 44)))
        titleView.backgroundColor = UIColor.white
        contentView.addSubview(titleView)
        
        dateTitleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 0))
        dateTitleLabel.font = UIFont.systemFont(ofSize: 17)
        dateTitleLabel.textColor = darkColor
        dateTitleLabel.textAlignment = .center
		
		// Hide the title label
		dateTitleLabel.isHidden = true
		
        resetDateTitle()
        titleView.addSubview(dateTitleLabel)
        
        todayButton = UIButton(type: .system)
        todayButton.setTitle(todayButtonTitle, for: UIControlState())
        todayButton.setTitleColor(highlightColor, for: UIControlState())
        todayButton.addTarget(self, action: #selector(DateTimePicker.setToday), for: .touchUpInside)
        todayButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        todayButton.isHidden = self.minimumDate.compare(Date()) == .orderedDescending || self.maximumDate.compare(Date()) == .orderedAscending
        let size = todayButton.sizeThatFits(CGSize(width: 0, height: 44.0)).width + 10.0
        todayButton.frame = CGRect(x: contentView.frame.width - size, y: 0, width: size, height: 44)
		
		// Hide the today button
		todayButton.isHidden = true
        titleView.addSubview(todayButton)
        
        // day collection view
        let layout = StepCollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        layout.itemSize = CGSize(width: 75, height: 80)
        
        dayCollectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: contentView.frame.width, height: 100), collectionViewLayout: layout)
        dayCollectionView.backgroundColor = daysBackgroundColor
        dayCollectionView.showsHorizontalScrollIndicator = false
        dayCollectionView.register(DateCollectionViewCell.self, forCellWithReuseIdentifier: "dateCell")
        dayCollectionView.dataSource = self
        dayCollectionView.delegate = self
        
        let inset = (dayCollectionView.frame.width - 75) / 2
        dayCollectionView.contentInset = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
        contentView.addSubview(dayCollectionView)
        
        // top & bottom borders on day collection view
        let borderTopView = UIView(frame: CGRect(x: 0, y: 0, width: titleView.frame.width, height: 1))
        borderTopView.backgroundColor = darkColor.withAlphaComponent(0.2)
        contentView.addSubview(borderTopView)
        
        let borderBottomView = UIView(frame: CGRect(x: 0, y: dayCollectionView.frame.origin.y + dayCollectionView.frame.height, width: titleView.frame.width, height: 1))
        borderBottomView.backgroundColor = darkColor.withAlphaComponent(0.2)
        contentView.addSubview(borderBottomView)
        
        // done button
        doneButton = UIButton(type: .system)
        doneButton.frame = CGRect(x: 10, y: contentView.frame.height - 10 - 44, width: contentView.frame.width - 20, height: 44)
        doneButton.setTitle(doneButtonTitle, for: UIControlState())
        doneButton.setTitleColor(UIColor.white, for: UIControlState())
        doneButton.backgroundColor = darkColor.withAlphaComponent(0.5)
        doneButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        doneButton.layer.cornerRadius = 3
        doneButton.layer.masksToBounds = true
        doneButton.addTarget(self, action: #selector(DateTimePicker.dismissView), for: .touchUpInside)
        contentView.addSubview(doneButton)
        
        // hour table view
        hourTableView = UITableView(frame: CGRect(x: contentView.frame.width / 2 - 60,
                                                  y: borderBottomView.frame.origin.y + 2,
                                                  width: 60,
                                                  height: doneButton.frame.origin.y - borderBottomView.frame.origin.y - 10))
        hourTableView.rowHeight = 36
        hourTableView.contentInset = UIEdgeInsetsMake(hourTableView.frame.height / 2, 0, hourTableView.frame.height / 2, 0)
        hourTableView.showsVerticalScrollIndicator = false
        hourTableView.separatorStyle = .none
        hourTableView.delegate = self
        hourTableView.dataSource = self
        if #available(iOS 11.0, *) {
            hourTableView.contentInsetAdjustmentBehavior = .never
        }
        contentView.addSubview(hourTableView)
        
        // minute table view
        minuteTableView = UITableView(frame: CGRect(x: contentView.frame.width / 2,
                                                    y: borderBottomView.frame.origin.y + 2,
                                                    width: 60,
                                                    height: doneButton.frame.origin.y - borderBottomView.frame.origin.y - 10))
        minuteTableView.rowHeight = 36
        minuteTableView.contentInset = UIEdgeInsetsMake(minuteTableView.frame.height / 2, 0, minuteTableView.frame.height / 2, 0)
        minuteTableView.showsVerticalScrollIndicator = false
        minuteTableView.separatorStyle = .none
        minuteTableView.delegate = self
        minuteTableView.dataSource = self
        if #available(iOS 11.0, *) {
            minuteTableView.contentInsetAdjustmentBehavior = .never
        }
        contentView.addSubview(minuteTableView)
        
        // colon
        colonLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 10, height: 36))
        colonLabel.center = CGPoint(x: contentView.frame.width / 2,
                                    y: (doneButton.frame.origin.y - borderBottomView.frame.origin.y - 10) / 2 + borderBottomView.frame.origin.y)
        colonLabel.text = ":"
        colonLabel.font = UIFont.boldSystemFont( ofSize: 18)
        colonLabel.textColor = highlightColor
        colonLabel.textAlignment = .center
        contentView.addSubview(colonLabel)
        
        // time separators
        let separatorTopView = UIView(frame: CGRect(x: 0, y: 0, width: 90, height: 1))
        separatorTopView.backgroundColor = darkColor.withAlphaComponent(0.2)
        separatorTopView.center = CGPoint(x: contentView.frame.width / 2, y: borderBottomView.frame.origin.y + 36)
        contentView.addSubview(separatorTopView)
        
        let separatorBottomView = UIView(frame: CGRect(x: 0, y: 0, width: 90, height: 1))
        separatorBottomView.backgroundColor = darkColor.withAlphaComponent(0.2)
        separatorBottomView.center = CGPoint(x: contentView.frame.width / 2, y: separatorTopView.frame.origin.y + 36)
        contentView.addSubview(separatorBottomView)
        
        // fill date
        fillDates(minimumDate, toDate: maximumDate)
        updateCollectionView(to: selectedDate)
		
		components = (calendar as NSCalendar).components([.year, .month, .day, .hour, .minute], from: selectedDate)
		var hour = components.hour
		if hour! < 7 || hour! > 18 {
			hour = 7
			components.hour = hour
			selectedDate = calendar.date(from: components)!
		}
		
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/YYYY"
        for i in 0..<dates.count {
            let date = dates[i]
            if formatter.string(from: date) == formatter.string(from: selectedDate) {
                dayCollectionView.selectItem(at: IndexPath(row: i, section: 0), animated: true, scrollPosition: .centeredHorizontally)
                break
            }
        }
		
		
        contentView.isHidden = false
        
        resetTime()
        
        // animate to show contentView
        UIView.animate( withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.4, options: .curveEaseIn, animations: {
            self.contentView.frame = CGRect(x: 0,
                                            y: self.frame.height - self.contentHeight,
                                            width: self.frame.width,
                                            height: self.contentHeight)
        }, completion: nil)
    }
    
    @objc func setToday() {
        selectedDate = Date()
        resetTime()
    }
    
    func resetTime() {
        components = (calendar as NSCalendar).components([.day, .month, .year, .hour, .minute], from: selectedDate)
		
		
		var hour = components.hour
		if hour! < 7 || hour! > 18 {
			hour = 7
			components.hour = hour
		}
		
		let componentsNow = (calendar as NSCalendar).components(.hour, from: Date())
		let hours = [7,8,9,10,11,12,13,14,15,16,17,18]
		var delta = 100000
		var idx=0
		for i in 0...hours.count-1 {
			if abs(hours[i]-componentsNow.hour!) <= delta {
				delta = abs(hours[i]-componentsNow.hour!)
				idx = i
			}
		}
        if idx+1 < hours.count {
            idx = idx+1
        }else{
            idx = hours[hours.count-1]
        }
        
        
       
            if hour! > 0 {
                var extraDelay = 0.0
                if #available(iOS 11, *){
                    extraDelay = 0.1
                }
                let delay = DispatchTime.now() + extraDelay
                DispatchQueue.main.asyncAfter(deadline: delay, execute: { 
                    self.hourTableView.selectRow(at: IndexPath(row: idx, section: 0), animated: false, scrollPosition: .middle)
                    self.setModifyScrollY()
                    self.tableView(self.hourTableView, didSelectRowAt: IndexPath(row: idx, section: 0))
                })
            }
        
    
        
		let minute = components.minute
        if minute! >= 0 {
//            let expectedRow = minute == 0 ? 120 : minute + 60 // workaround for issue when minute = 0
            minuteTableView.selectRow( at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: .middle)
            self.tableView(minuteTableView, didSelectRowAt: IndexPath(row: 0, section: 0))
        }
		
		
		updateCollectionView(to: selectedDate)
		
    }
    
    fileprivate func resetDateTitle() {
        guard dateTitleLabel != nil else {
            return
        }
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        dateTitleLabel.text = formatter.string(from: selectedDate)
        dateTitleLabel.sizeToFit()
        dateTitleLabel.center = CGPoint(x: contentView.frame.width / 2, y: 22)
    }
    
    func fillDates(_ fromDate: Date, toDate: Date) {
        
        var dates: [Date] = []
        var days = DateComponents()
        
        var dayCount = 0
        repeat {
            days.day = dayCount
            dayCount += 1
            guard let date = (calendar as NSCalendar).date(byAdding: days, to: fromDate, options: .matchFirst) else {
                break;
            }
            if date.compare(toDate) == .orderedDescending {
                break
            }
            dates.append(date)
        } while (true)
        
        self.dates = dates
        dayCollectionView.reloadData()
        
        if let index = self.dates.index(of: selectedDate) {
            dayCollectionView.selectItem(at: IndexPath(row: index, section: 0), animated: true, scrollPosition: .centeredHorizontally)
        }
    }
    
    func updateCollectionView(to currentDate: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/YYYY"
        for i in 0..<dates.count {
            let date = dates[i]
            if formatter.string(from: date) == formatter.string(from: currentDate) {
                let indexPath = IndexPath(row: i, section: 0)
                dayCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
				
				let delayTime = DispatchTime.now() + Double(Int64(0.3 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
				DispatchQueue.main.asyncAfter(deadline: delayTime, execute: {
					self.dayCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
				})

                
                break
            }
        }
	}
	
    @objc func dismissView() {
		
		if self.selectedDate.compare(Date()) == .orderedAscending {
			let alert = UIAlertView()
			alert.title = "Ooops!"
			alert.message = "You cannot select a date in the past!"
			alert.addButton(withTitle: "OK")
			alert.show()
			self.resetTime()
			return
		}
		
		UIView.animate(withDuration: 0.3, animations: {
			self.shadow.alpha = 0.0
		}) 
		self.completionHandler?(self.selectedDate)
        UIView.animate(withDuration: 0.3, animations: {
            // animate to show contentView
            self.contentView.frame = CGRect(x: 0,
                                            y: self.frame.height,
                                            width: self.frame.width,
                                            height: self.contentHeight)
        }, completion: { (completed) in
            self.removeFromSuperview()
        }) 
    }
}

extension DateTimePicker: UITableViewDataSource, UITableViewDelegate {
	
	public func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == hourTableView {
            // need triple of origin storage to scroll infinitely
            return 12 * 3
        }
        // need triple of origin storage to scroll infinitely
        return 2 * 3
    }
	
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "timeCell") ?? UITableViewCell(style: .default, reuseIdentifier: "timeCell")
        
        cell.selectedBackgroundView = UIView()
        cell.textLabel?.textAlignment = tableView == hourTableView ? .right : .left
        cell.textLabel?.font = UIFont.boldSystemFont( ofSize: 18)
        cell.textLabel?.textColor = darkColor.withAlphaComponent(0.4)
        cell.textLabel?.highlightedTextColor = highlightColor
        // add module operation to set value same
		
		
		if tableView == hourTableView {
			let hours = [7,8,9,10,11,12,13,14,15,16,17,18]
			cell.textLabel?.text = String(format: "%02i", hours[indexPath.row % hours.count]  )
		}else{
			let minutes = [0, 30]
			cell.textLabel?.text = String(format: "%02i", minutes[indexPath.row % minutes.count]  )
		}
		
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.selectRow(at: indexPath, animated: true, scrollPosition: .middle)
        
        if tableView == hourTableView {
			let hours = [7,8,9,10,11,12,13,14,15,16,17,18]
            components.hour = hours[indexPath.row % hours.count]
        } else if tableView == minuteTableView {
			let minutes = [0, 30]
            components.minute = minutes[indexPath.row % minutes.count]
        }
        
		if let selected = calendar.date(from: components){
            selectedDate = selected
        }
    }
    
    // for infinite scrolling, use modulo operation.
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView != dayCollectionView else {
            return
        }
        let totalHeight = scrollView.contentSize.height
        let visibleHeight = totalHeight / 3.0
        if scrollView.contentOffset.y < visibleHeight || scrollView.contentOffset.y > visibleHeight + visibleHeight {
            let positionValueLoss = scrollView.contentOffset.y - CGFloat(Int(scrollView.contentOffset.y))
            let heightValueLoss = visibleHeight - CGFloat(Int(visibleHeight))
            let modifiedPotisionY = CGFloat(Int( scrollView.contentOffset.y ) % Int( visibleHeight ) + Int( visibleHeight )) - positionValueLoss - heightValueLoss
            if isModifyScrollY{
            scrollView.contentOffset.y = modifiedPotisionY
            }
            print("-------Scrolling ")
        }
    }
    
    private func setModifyScrollY(){
        if #available(iOS 11, *){
            isModifyScrollY = false
            let delay = DispatchTime.now() + 0.3
            DispatchQueue.main.asyncAfter(deadline: delay) {
                self.isModifyScrollY = true
            }
        }
    }
}

extension DateTimePicker: UICollectionViewDataSource, UICollectionViewDelegate {
    public func numberOfSections(in _: UICollectionView) -> Int {
        return 1
    }
	
	public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dates.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "dateCell", for: indexPath) as! DateCollectionViewCell
        
        let date = dates[indexPath.item]
        cell.populateItem(date, highlightColor: highlightColor, darkColor: darkColor)
        
        return cell
    }
	
	public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
	
        //workaround to center to every cell including ones near margins
        if let cell = collectionView.cellForItem(at: indexPath) {
            let offset = CGPoint(x: cell.center.x - collectionView.frame.width / 2, y: 0)
            collectionView.setContentOffset(offset, animated: true)
        }
        
        // update selected dates
        let date = dates[indexPath.item]
        let dayComponent = (calendar as NSCalendar).components([.day, .month, .year], from: date)
        components.day = dayComponent.day
        components.month = dayComponent.month
        components.year = dayComponent.year
        if let selected = calendar.date(from: components){
            selectedDate = selected
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        alignScrollView(scrollView)
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            alignScrollView(scrollView)
        }
    }
    
    func alignScrollView(_ scrollView: UIScrollView) {
        if let collectionView = scrollView as? UICollectionView {
            let centerPoint = CGPoint(x: collectionView.center.x + collectionView.contentOffset.x, y: 50);
			if let indexPath = collectionView.indexPathForItem(at: centerPoint){
                // automatically select this item and center it to the screen
                // set animated = false to avoid unwanted effects
                collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .top)
                if let cell = collectionView.cellForItem(at: indexPath) {
                    let offset = CGPoint(x: cell.center.x - collectionView.frame.width / 2, y: 0)
                    collectionView.setContentOffset(offset, animated: false)
                }
                
                // update selected date
                let date = dates[indexPath.item]
                let dayComponent = (calendar as NSCalendar).components([.day, .month, .year], from: date)
                components.day = dayComponent.day
                components.month = dayComponent.month
                components.year = dayComponent.year
                if let selected = calendar.date(from: components){
                    selectedDate = selected
                }
            }
        } else if let tableView = scrollView as? UITableView {
            let relativeOffset = CGPoint(x: 0, y: tableView.contentOffset.y + tableView.contentInset.top )
           
            // change row from var to let.
            let row = round(relativeOffset.y / tableView.rowHeight)
            var indexPath = IndexPath(row: Int(row), section: 0)
            
            if indexPath.row < tableView.numberOfRows(inSection: 0){
           
            }else{
                 indexPath = IndexPath(row: Int(row-1), section: 0)
            }
            
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .middle)
            setModifyScrollY()
            
            // add 24 to hour and 60 to minute, because datasource now has buffer at top and bottom.
            if tableView == hourTableView {
				let hours = [7,8,9,10,11,12,13,14,15,16,17,18]
                components.hour = hours[Int(row) % hours.count]
            } else if tableView == minuteTableView {
				let minutes = [0, 30]
                components.minute = minutes[Int(row) % minutes.count]
            }
            
            if let selected = calendar.date(from: components){
                selectedDate = selected
            }
          
        }
    }
}

extension Date {
	
	func setTo8AM() -> Date {
		let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
		var components = (calendar as NSCalendar).components(([.day, .month, .year, .hour]), from: self)
		components.hour = 10
		return calendar.date(from: components)!
	}
	
}
