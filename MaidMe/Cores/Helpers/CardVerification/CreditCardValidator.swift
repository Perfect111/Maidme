//
//  CreditCardValidator.swift
//
//  Created by Vitaliy Kuzmenko on 02/06/15.
//  Copyright (c) 2015. All rights reserved.
//

import Foundation

open class CreditCardValidator {
    
    open lazy var types: [CreditCardValidationType] = {
        var types = [CreditCardValidationType]()
        for object in CreditCardValidator.types {
            //types.append(CreditCardValidationType(dict: object))
            types.append(object)
        }
        return types
        }()
    
    public init() { }
    
    /**
    Get card type from string
    
    - parameter string: card number string
    
    - returns: CreditCardValidationType structure
    */
    open func typeFromString(_ string: String) -> CreditCardValidationType? {
        for type in types {
            let predicate = NSPredicate(format: "SELF MATCHES %@", type.regex)
            let numbersString = self.onlyNumbersFromString(string)
            if predicate.evaluate(with: numbersString) {
                return type
            }
        }
        return nil
    }
    
    /**
    Validate card number
    
    - parameter string: card number string
    
    - returns: true or false
    */
    open func validateString(_ string: String) -> Bool {
        let numbers = self.onlyNumbersFromString(string)
        if numbers.characters.count < 9 {
            return false
        }
        
        var reversedString = ""
        let range = Range<String.Index>(uncheckedBounds: (lower: numbers.startIndex, upper: numbers.endIndex))
        
        
        numbers.enumerateSubstrings(in: range, options: [NSString.EnumerationOptions.reverse, NSString.EnumerationOptions.byComposedCharacterSequences]) { (substring, substringRange, enclosingRange, stop) -> () in
            reversedString += substring!
        }
        
        var oddSum = 0, evenSum = 0
        let reversedArray = reversedString.characters
        var i = 0
        
        for s in reversedArray {
            
            let digit = Int(String(s))!
            i+=1
            if i % 2 == 0 {
                evenSum += digit
            } else {
                oddSum += digit / 5 + (2 * digit) % 10
            }
        }
        return (oddSum + evenSum) % 10 == 0
    }
    
    /**
    Validate card number string for type
    
    - parameter string: card number string
    - parameter type:   CreditCardValidationType structure
    
    - returns: true or false
    */
    open func validateString(_ string: String, forType type: CreditCardValidationType) -> Bool {
        return typeFromString(string) == type
    }
    
    open func onlyNumbersFromString(_ string: String) -> String {
        let set = CharacterSet.decimalDigits.inverted
        let numbers = string.components(separatedBy: set)
        return numbers.joined(separator: "")
    }
    
    // MARK: - Loading data

    open static let types = [
        CreditCardValidationType(type: .amex, regex: "^3[47][0-9]{13}$"),
        CreditCardValidationType(type: .visa, regex: "^4[0-9]{12}((?:[0-9]{3})?){2}$"),
        CreditCardValidationType(type: .master, regex: "^5[1-5][0-9]{14}$"),
        CreditCardValidationType(type: .maestro, regex: "^(5018|5020|5038|5893|6304|6759|6761|6762|6763)[0-9]{8,15}$"),
        CreditCardValidationType(type: .diners, regex: "^3(?:0[0-5]|0[9]|[689][0-9])[0-9]{11}$"),
        CreditCardValidationType(type: .jcb, regex: "^(?:2131|1800|35\\d{3})\\d{11}$"),
        CreditCardValidationType(type: .discover, regex: "^(65[0-9]{14}|64[4-9][0-9]{13}|6011[0-9]{12}|(622(?:12[6-9]|1[3-9][0-9]|[2-8][0-9][0-9]|9[01][0-9]|92[0-5])[0-9]{10}))(?:[0-9]{3})?$"),
        CreditCardValidationType(type: .unionPay, regex: "^62[0-9]{14,17}$"),
    ]
}
