//
//  EDropdownList.swift
//  EDropdownList
//
//  Created by Lucy Nguyen on 11/10/15.
//  Copyright © 2015 econ. All rights reserved.
//
//  This class is used for creating custom dropdown list in iOS.

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


@objc protocol EdropdownListDelegate {
    func didSelectItem(_ selectedItem: String, index: Int)
    @objc optional func didTouchDownDropdownList()
}

class EDropdownList: UIView {
    var dropdownButton: UIButton!
    var listTable: UITableView!
    var separatorLine: UIView!
    var arrowImage: UIImageView!
    var downArrow: String? {
        didSet {
            setArrow(downArrow)
        }
    }
    var upArrow: String?
    var superView: AnyObject?
    var valueList: [String]!
    var delegate: EdropdownListDelegate!
    var isShown: Bool = false
    var selectedValue: String!
    var arrowWidth: CGFloat = 16.0
    var arrowHeight: CGFloat = 8.0
    
    var maxHeight: CGFloat = 200.0
    var cellSelectedColor = UIColor.clear
    var textColor = UIColor.black
    
    var bgColor = UIColor.white {
        didSet {
            if (oldValue != bgColor) {
                dropdownButton.backgroundColor = UIColor.black
            }
        }
    }
    
    var buttonTextAlignment = UIControlContentHorizontalAlignment.center {
        didSet {
            if (oldValue != buttonTextAlignment) {
                dropdownButton.contentHorizontalAlignment = buttonTextAlignment
            }
        }
    }
    
    var placeHolder: String = "Select" {
        didSet {
            dropdownButton.setTitle(cutString(placeHolder), for: UIControlState())
        }
    }
    
    var buttonLeftInset: CGFloat = 0.0 {
        didSet {
            dropdownButton.titleEdgeInsets = UIEdgeInsetsMake(0.0, buttonLeftInset, 0.0, 0.0)
        }
    }
    
    var defaultValue: String = "" {
        didSet {
            dropdownButton.setTitle(defaultValue, for: UIControlState())
//            let selectedCellIndexPath = NSIndexPath(forItem: 0, inSection: 0)
//            self.tableView(listTable, didSelectRowAtIndexPath: selectedCellIndexPath)
        }
    }
    
    var fontSize: CGFloat = 16.0 {
        didSet {
            dropdownButton.titleLabel?.font = UIFont(name: CustomFont.quicksanRegular, size: fontSize)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addTapGestureForView()
        initArrowImage()
        setupButton()
        setupListTable()
        setupSeparatorLine()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        addTapGestureForView()
        initArrowImage()
        setupButton()
        setupListTable()
        setupSeparatorLine()
    }
    
    // MARK: - Create interface.
    
    func addTapGestureForView() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(EDropdownList.showHideDropdownList(_:)))
        self.addGestureRecognizer(tapGesture)
    }
    
    func setupButton() {
        dropdownButton = UIButton(type: UIButtonType.custom)
        dropdownButton.backgroundColor = bgColor
        dropdownButton.contentHorizontalAlignment = buttonTextAlignment
        dropdownButton.frame = CGRect(x: 0, y: 0, width: self.arrowImage.frame.minX, height: self.frame.height)
        dropdownButton.setTitle(cutString(placeHolder), for: UIControlState())
        dropdownButton.addTarget(self, action: #selector(EDropdownList.showHideDropdownList(_:)), for: UIControlEvents.touchUpInside)
        dropdownButton.titleEdgeInsets = UIEdgeInsetsMake(0.0, buttonLeftInset, 0.0, 0.0)
        dropdownButton.titleLabel?.font = UIFont(name: CustomFont.quicksanRegular, size: 16.0)
        self.addSubview(self.dropdownButton)
    }
    
    func initArrowImage() {
        arrowImage = UIImageView()
        arrowImage.frame = CGRect(x: self.frame.width - arrowWidth * 2, y: (self.frame.height - arrowHeight) / 2, width: arrowWidth, height: arrowHeight)
        
        // Add the arrow image at the end of the button.
        self.addSubview(arrowImage)
        
        setArrow(downArrow)
    }
    
    func setArrow(_ image: String?) {
        guard let arrow = image else {
            return
        }
        
        arrowImage.image = UIImage(named: arrow)
    }
    
    func setupListTable() {
        let yLocation = self.frame.minY + dropdownButton.frame.height
        
        listTable = UITableView(frame: CGRect(x: self.frame.minX, y: yLocation, width: self.frame.width, height: 0))
        listTable.dataSource = self
        listTable.delegate = self
        listTable.isUserInteractionEnabled = true
       
        // Disable scrolling the tableview after it reach the top or bottom.
        listTable.bounces = false
    }
    
    func setupSeparatorLine() {
        separatorLine = UIView(frame: CGRect(x: self.frame.minX, y: listTable.frame.minY, width: self.frame.width, height: 0.5))
        separatorLine.backgroundColor = UIColor(red: 91.0 / 255.0, green: 194.0 / 255.0, blue: 209.0 / 255.0, alpha: 1)
    }
    
    func updateListTableFrame(_ yLocation: CGFloat, width: CGFloat) {
        var frame = listTable.frame
        frame.origin.y = yLocation
        frame.size.width = width
        listTable.frame = frame
        
        separatorLine.frame.origin.y = yLocation
        separatorLine.frame.size.width = width
        arrowImage.frame.origin.x = width - arrowWidth * 2
        dropdownButton.frame.size.width = self.arrowImage.frame.minX
    }
    
    // MARK: - User setting
    
    func dropdownColor(_ backgroundColor: UIColor?, selectedColor: UIColor?, textColor: UIColor?) {
        if let bgColor = backgroundColor {
            listTable.backgroundColor = bgColor
        }
        
        if let selectedColor = selectedColor {
            cellSelectedColor = selectedColor
        }
        
        if let textColor = textColor {
            self.textColor = textColor
        }
    }
    
    func dropdownColor(_ backgroundColor: UIColor, buttonColor: UIColor, selectedColor: UIColor, textColor: UIColor) {
        dropdownColor(backgroundColor, selectedColor: selectedColor, textColor: textColor)
        dropdownButton.backgroundColor = buttonColor
    }
    
    func dropdownColor(_ backgroundColor: UIColor, buttonBgColor: UIColor, buttonTextColor: UIColor, selectedColor: UIColor? = nil, textColor: UIColor? = nil) {
        dropdownColor(backgroundColor, selectedColor: selectedColor, textColor: textColor)
        dropdownButton.setTitleColor(buttonTextColor, for: UIControlState())
        dropdownButton.backgroundColor = buttonBgColor
    }
    
    func setButtonTextColorAndFont(_ color: UIColor, font: UIFont) {
        dropdownButton.setTitleColor(color, for: UIControlState())
        dropdownButton.titleLabel?.font = font
    }
    
    func dropdownMaxHeight(_ height: CGFloat) {
        maxHeight = height
    }
    func cutString(_ string: String) -> String{
        if string.characters.count > 15 {
            let subString = string[string.characters.index(string.startIndex, offsetBy: 0)...string.characters.index(string.startIndex, offsetBy: 15)]
            return subString + ".."
        } else {
            return string
        }
    }
    func disableSelecting(_ flag: Bool) {
        self.placeHolder = (flag ? "Not available" : "Select")
        self.isUserInteractionEnabled = !flag
        self.alpha = (flag ? 0.5 : 1.0)
    }
    
    // MARK: - Action
    
    @objc  func showHideDropdownList(_ sender: AnyObject) {
        if selectedValue != nil {
            dropdownButton.setTitle(cutString(selectedValue), for: UIControlState())
        }
        
        hideDropdownList(isShown)
        delegate?.didTouchDownDropdownList?()
    }
    
    func hideDropdownList(_ isHidden: Bool) {
        if (isHidden && !isShown) || (!isHidden && isShown) {
            return
        }
        
        if !isHidden {
            UIView.animate(withDuration: 0.2, animations: { () -> Void in
                if let superViewTarget = self.superView {
                    superViewTarget.addSubview(self.listTable)
                    superViewTarget.addSubview(self.separatorLine)
                }
                else {
                    self.superview?.addSubview(self.listTable)
                    self.superview?.addSubview(self.separatorLine)
                }
                
                var height = self.tableviewHeight()
                
                if height > self.maxHeight {
                    height = self.maxHeight
                }
                
                var frame = self.listTable.frame
                frame.size.height = CGFloat(height)
                
                self.listTable.frame = frame
                }, completion: { (animated) -> Void in
                    self.setArrow(self.upArrow)
            })
        }
        else {
            UIView.animate(withDuration: 0.2, animations: { () -> Void in
                let height = 0
                var frame = self.listTable.frame
                frame.size.height = CGFloat(height)
                
                self.listTable.frame = frame
                }, completion: { (animated) -> Void in
                    self.listTable.removeFromSuperview()
                    self.separatorLine.removeFromSuperview()
                    self.setArrow(self.downArrow)
            })
        }
        
        isShown = !isShown
    }
    
    func reloadList(_ list: [String]) {
        valueList = list
        listTable.reloadData()
    }
}

// MARK: - UITableViewDataSource
extension EDropdownList: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = valueList?.count
        
        if count > 0 {
            return count!
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "Cell"
        var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        
        if (cell == nil) {
            cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: cellIdentifier)
        }
        
        // Set selected background color.
        let colorView = UIView()
        colorView.backgroundColor = UIColor.white
        cell.selectedBackgroundView = colorView
        let lineView = UIView()
        lineView.frame = CGRect(x: 0, y: 0, width: cell.frame.size.width, height: 0.5)
        lineView.backgroundColor = UIColor(red: 91.0 / 255.0, green: 194.0 / 255.0, blue: 209.0 / 255.0, alpha: 1)
        cell.addSubview(lineView)
        cell.textLabel?.font = UIFont(name: CustomFont.quicksanRegular,size: fontSize)
        cell.backgroundColor = UIColor.clear
        cell.textLabel?.textColor = textColor
        cell.textLabel?.text = valueList?[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if tableView.responds(to: #selector(setter: UITableViewCell.separatorInset)) {
            tableView.separatorInset = UIEdgeInsets.zero
        }
        
        if tableView.responds(to: #selector(setter: UIView.layoutMargins)) {
            tableView.layoutMargins = UIEdgeInsets.zero
        }
        
        if cell.responds(to: #selector(setter: UIView.layoutMargins)) {
            cell.layoutMargins = UIEdgeInsets.zero
        }
    }
    
    func tableviewHeight() -> CGFloat {
        listTable.layoutIfNeeded()
        return listTable.contentSize.height
    }
}

// MARK: - UITableViewDelegate
extension EDropdownList: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Get selected value.
        let selectedCell = tableView.cellForRow(at: indexPath)
        selectedValue = selectedCell?.textLabel?.text
        
        // Hide the dropdown table and pass the selected value.
        showHideDropdownList(dropdownButton)
        delegate?.didSelectItem((selectedCell?.textLabel?.text)!, index: indexPath.row)
    }
}

