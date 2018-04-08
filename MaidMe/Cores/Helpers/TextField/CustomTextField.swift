//
//  CustomTextField.swift
//  Edgar
//
//  Created by Viktor on1/6/16.
//  Copyright © 2016 smartlink. All rights reserved.
//

import UIKit

protocol CustomTextFieldDelegate {
    func onDeleteBackward(_ textField: CustomTextField)
}

class CustomTextField: UITextField {

    var customDelegate: CustomTextFieldDelegate?

    override func deleteBackward() {
        super.deleteBackward()
        customDelegate?.onDeleteBackward(self)
    }
    
    /**
     Disable paste action on the textfield
     
     - parameter action:
     - parameter sender:
     
     - returns: 
     */
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        super.canPerformAction(action, withSender: sender)

        return false
    }
}
