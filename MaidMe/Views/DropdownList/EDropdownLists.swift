//
//  EDropdownLists.swift
//  EDropdownLists
//
//  Created by Lucy Nguyen on 11/10/15.
//  Copyright © 2015 econ. All rights reserved.
//
//  This class is used for creating custom dropdown list in iOS.

import UIKit

@objc protocol EdropdownListsDelegate {
    func didSelectItem(_ selectedItem: String, index: Int)
    @objc optional func didSelectItemFromList(_ selectedItem: String)
    @objc optional func didTouchDownDropdownList()
}

class EDropdownLists: UIView {
    var dropdownTextField: UITextField!
    var listTable: UITableView!
    var arrowImage: UIImageView!
    var downArrow: String? {
        didSet {
            setArrow(downArrow)
        }
    }
    var upArrow: String?
    var superView: AnyObject?
    var valueList = [String]()
    var filteredValueList = [String]()
    weak var delegate: EdropdownListsDelegate?
    var isShown: Bool = false
    var selectedValue: String!
    
    var maxHeight: CGFloat = 200.0
    var cellSelectedColor = UIColor(red: 91.0 / 255.0, green: 194.0 / 255.0, blue: 209.0 / 255.0, alpha: 1)
    var textColor = UIColor.black
    
    var bgColor = UIColor(red: 91.0 / 255.0, green: 194.0 / 255.0, blue: 209.0 / 255.0, alpha: 1)
        {
        didSet {
            if (oldValue != bgColor) {
                dropdownTextField.backgroundColor = bgColor
            }
        }
    }

    var placeHolder: String = "Select" {
        didSet {
            dropdownTextField.placeholder = placeHolder
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTextField()
        initArrowImage()
        setupListTable()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupTextField()
        initArrowImage()
        setupListTable()
    }
    
    // MARK: - Create interface.
    
    func setupTextField() {
        dropdownTextField = UITextField(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
        dropdownTextField.backgroundColor = bgColor
        dropdownTextField.placeholder = placeHolder
        dropdownTextField.font = UIFont(name: CustomFont.quicksanBold, size: 16.0)
        dropdownTextField.delegate = self
        self.addSubview(dropdownTextField)
        
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 30.0, height: 30.0))
        leftView.backgroundColor = UIColor.clear
        dropdownTextField.leftViewMode = UITextFieldViewMode.always
        dropdownTextField.leftView = leftView
        dropdownTextField.clearButtonMode = .whileEditing
        
        dropdownTextField.addTarget(self, action: #selector(EDropdownLists.textFieldDidChange(_:)), for: UIControlEvents.editingChanged)
    }
    
    func initArrowImage() {
        arrowImage = UIImageView()
        arrowImage.frame = CGRect(x: self.frame.width - 3 * self.frame.height / 4, y: self.frame.height / 4, width: self.frame.height / 2, height: self.frame.height / 2)
        
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
        let yLocation = self.frame.minY + dropdownTextField.frame.height
        
        listTable = UITableView(frame: CGRect(x: self.frame.minX, y: yLocation, width: self.frame.width, height: 0))
        listTable.dataSource = self
        listTable.delegate = self
        listTable.isUserInteractionEnabled = true
        
        // Disable scrolling the tableview after it reach the top or bottom.
        listTable.bounces = false
        listTable.hideTableEmptyCell()
    }
    
    func updateListTableFrame(_ yLocation: CGFloat, width: CGFloat) {
        var frame = listTable.frame
        frame.origin.y = yLocation
        frame.size.width = width
        listTable.frame = frame
        dropdownTextField.frame.size.width = width
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
    
    func dropdownColor(_ backgroundColor: UIColor, textFieldBgColor: UIColor, selectedColor: UIColor, textColor: UIColor) {
        dropdownColor(backgroundColor, selectedColor: selectedColor, textColor: textColor)
        dropdownTextField.backgroundColor = textFieldBgColor
    }
    
    func dropdownColor(_ backgroundColor: UIColor, textFieldBgColor: UIColor, textFieldTextColor: UIColor, selectedColor: UIColor? = nil, textColor: UIColor? = nil) {
        dropdownColor(backgroundColor, selectedColor: selectedColor, textColor: textColor)
        dropdownTextField.textColor = textFieldTextColor
        dropdownTextField.backgroundColor = textFieldBgColor
    }
    
    func setTextFieldTextColorAndFont(_ color: UIColor, font: UIFont) {
        dropdownTextField.textColor = color
        dropdownTextField.font = font
    }
    
    func dropdownMaxHeight(_ height: CGFloat) {
        maxHeight = height
    }
    
    // MARK: - Search filter
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredValueList = valueList.filter { value in
            return value.lowercased().contains(searchText.lowercased())
        }
        
        listTable.reloadData()
        updateTableHeight()
    }
    
    @objc func textFieldDidChange(_ sender: AnyObject) {
        filterContentForSearchText(dropdownTextField.text!)
        delegate?.didSelectItem(dropdownTextField.text!, index: -1)
    }
    
    // MARK: - Action
    
    func showHideDropdownList(_ isHidden: Bool) {
        hideDropdownList(isHidden)
        self.isShown = !isHidden
    }
    
    func hideDropdownList(_ isHidden: Bool) {
        if (isHidden && !isShown) || (!isHidden && isShown) {
            return
        }
        
        if !isHidden {
            UIView.animate(withDuration: 0.2, animations: { () -> Void in
                if let superViewTarget = self.superView {
                    superViewTarget.addSubview(self.listTable)
                }
                else {
                    self.superview?.addSubview(self.listTable)
                }
                
                self.updateTableHeight()
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
                    self.setArrow(self.downArrow)
            })
        }
    }
    
    func updateTableHeight() {
        var height = self.tableviewHeight()
        
        if height > self.maxHeight {
            height = self.maxHeight
        }
        
        var frame = self.listTable.frame
        frame.size.height = CGFloat(height)
        
        self.listTable.frame = frame
    }
    
    func reloadList(_ list: [String]) {
        valueList = list
        listTable.reloadData()
    }
}

// MARK: - UITableViewDataSource
extension EDropdownLists: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isShown && dropdownTextField.text != "" {
            return filteredValueList.count
        }
        
        return valueList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "Cell"
        var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        
        if (cell == nil) {
            cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: cellIdentifier)
        }
        
        // Set selected background color.
        let colorView = UIView()
        colorView.backgroundColor = cellSelectedColor
        cell.selectedBackgroundView = colorView
        cell.textLabel?.font = UIFont(name: CustomFont.quicksanRegular, size: 16.0)
        cell.backgroundColor = UIColor.clear
        cell.textLabel?.textColor = textColor
        
        var area = ""
        
        if isShown && dropdownTextField.text != "" {
            area = filteredValueList[indexPath.row]
        }
        else {
            area = valueList[indexPath.row]
        }
        
        cell.textLabel?.text = area

        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        if tableView.respondsToSelector("setSeparatorInset:") {
//            tableView.separatorInset = UIEdgeInsetsZero
//        }
//        
//        if tableView.respondsToSelector("setLayoutMargins:") {
//            tableView.layoutMargins = UIEdgeInsetsZero
//        }
//        
//        if cell.respondsToSelector("setLayoutMargins:") {
//            cell.layoutMargins = UIEdgeInsetsZero
//        }
        tableView.removeSeparatorLineInset([cell])
    }
    
    func tableviewHeight() -> CGFloat {
        listTable.layoutIfNeeded()
        return listTable.contentSize.height
    }
}

// MARK: - UITableViewDelegate
extension EDropdownLists: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Get selected value.
        let selectedCell = tableView.cellForRow(at: indexPath)
        selectedValue = selectedCell?.textLabel?.text
        dropdownTextField.text = selectedValue
        
        // Hide the dropdown table and pass the selected value.
        filterContentForSearchText(selectedValue)
        showHideDropdownList(true)
        delegate?.didSelectItem((selectedCell?.textLabel?.text)!, index: indexPath.row)
        delegate?.didSelectItemFromList?((selectedCell?.textLabel?.text)!)
    }
}

// MARK: - UITextFieldDelegate
extension EDropdownLists: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        // Show the table list
        if textField == dropdownTextField {
            showHideDropdownList(false)
        }
        
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        // Hide the table list
        if textField == dropdownTextField {
            showHideDropdownList(true)
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
