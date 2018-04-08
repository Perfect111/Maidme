//
//  Validation.swift
//  MaidMe
//
//  Created by Viktor on2/16/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit
import PhoneNumberKit

class Validation: NSObject {
    class func isEmpty(_ text: String?) -> Bool {
        guard let string = text else {
            return true
        }
        
        if string == "" {
            return true
        }
        
        return false
    }
    
    /**
     Check input fields are empty or not
     
     - parameter requiredFields: an array of required fields
     
     - returns:
     */
    class func isFullFillRequiredFields(_ requiredFields: [UITextField]) -> Bool {
        for field in requiredFields {
            if Validation.isEmpty(field.text) {
                return false
            }
        }
        
        return true
    }
    
    class func isFullFillRequiredTexts(_ requiredFields: [String?]) -> Bool {
        for text in requiredFields {
            if Validation.isEmpty(text) {
                return false
            }
        }
        
        return true
    }
    
    class func isValidLength(_ text: String, minLength: Int, maxLength: Int?) -> Bool {
        if let max = maxLength {
            if text.characters.count >= minLength && text.characters.count <= max {
                return true
            }
            
            return false
        }
        else if text.characters.count >= minLength {
            return true
        }
        
        return false
    }
    
    class func isValidRegex(_ string: String, expression: String) -> Bool {
        do {
            let regex = try NSRegularExpression(pattern: expression, options: NSRegularExpression.Options.caseInsensitive)
            let numberOfMatches = regex.numberOfMatches(in: string, options: NSRegularExpression.MatchingOptions.anchored, range: NSMakeRange(0, string.characters.count))
            
            if numberOfMatches == 0 {
                return false
            }
            else {
                return true
            }
        }
        catch _ {
            return false
        }
    }
    
    /**
     Check two string are matched
     
     - parameter stringOne:
     - parameter stringTwo:
     
     - returns:
     */
    class func matchedStrings(_ stringOne: String, stringTwo: String) -> Bool {
        if stringOne == stringTwo {
            return true
        }
        
        return false
    }
    
    class func isValidPhoneNumber(_ number: String) -> Bool {
        do {
            let _ = try PhoneNumberKit().parse(number)
            return true
        }
        catch {
            return false
        }
    }
    
    class func isInTheList(_ string: String, list: [WorkingArea]) -> Bool {
        let lowerString = string.lowercased()
        
        for item in list {
            let area = item.emirate! + " - " + item.area!
            if lowerString == area.lowercased() {
                return true
            }
        }
        
        return false
    }
}

class ValidationUI: NSObject {
    class func changeRequiredFieldsUI(_ isValid:Bool, button: UIButton) {
        if isValid {
            button.isEnabled = true
            button.alpha = 1.0
        }
        else {
            button.isEnabled = false
            button.alpha = 0.5
        }
    }
}
