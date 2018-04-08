//
//  CardHelper.swift
//  MaidMe
//
//  Created by Viktor on3/2/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit

class CardHelper: NSObject {
    class func getCardLogo(_ cardNumber: String, isSmall: Bool) -> UIImage? {
        let validator = CreditCardValidator()
        
        if !validator.validateString(cardNumber) {
            return nil
        }
        
        if let cardValidator = validator.typeFromString(cardNumber) {
            switch(cardValidator.type) {
            case .visa:
                return UIImage(named: "visacard_small")
                
            case .master:
                return UIImage(named: "mastercard_small")
                
            case .amex:
                return UIImage(named: "card_amex_small")
                
            case .diners:
                return UIImage(named: "card_diner_small")
                
            case .discover:
                return UIImage(named: "card_discover_small")
                
            case .jcb:
                return UIImage(named: "card_jcb_small")
                
            default:
                break
            }
        }
        
        return nil
    }
    
    class func isValidCVV(_ cvv: String, cardNumber: String) -> Bool {
        var regrex: String = "^[0-9]{3}$"
        
        let validator = CreditCardValidator()
        
        if let cardValidator = validator.typeFromString(cardNumber) {
            if cardValidator.type == .amex {
                regrex = "^[0-9]{4}$"
            }
        }
        
        return Validation.isValidRegex(cvv, expression: regrex)
    }
    
    class func isValidCardExpiryDate(_ expiryDate: Date) -> Bool {
        return !expiryDate.isLessThanCurrentMonth()
    }
    
    class func isValidExpiryDate(_ expiryMonth: Int, expiryYear: Int) -> Bool {
        let currentMonth = Date().getMonth()
        let currentYear = Date().getYear()
        
        if expiryYear > currentYear {
            return true
        }
            
        else if currentYear == expiryYear && expiryMonth >= currentMonth {
            return true
        }
        
        return false
    }
    
    class func showLastFourDigit(_ last4: String) -> String {
        var encodedNumber = ""
        
        for i in 0 ..< 12 {
            encodedNumber = encodedNumber + "*"
            
            if (i + 1) % 4 == 0 && i > 0 && i != 15 {
                encodedNumber += " "
            }
        }
        
        encodedNumber += last4
        
        return encodedNumber
    }
    
    class func hideCardNumber(_ number: String, numberOfHide: Int) -> String {
        let count = number.characters.count
        var encodedNumber = ""
        
        if count - numberOfHide <= 0 {
            return number
        }
        
        for i in 0 ..< count {
            if i < count - numberOfHide {
                encodedNumber = encodedNumber + "*"
            }
            else {
                let index = number.characters.index(number.startIndex, offsetBy: i)
                encodedNumber = encodedNumber + "\(number[index])"
            }
            if (i + 1) % 4 == 0 && i > 0 && i != count - 1 {
                encodedNumber += " "
            }
        }
        
        return encodedNumber
    }
    
    class func reformatCardNumber(_ cardNumber: String?) -> String? {
        guard let number = cardNumber else {
            return cardNumber
        }
        
        let count = number.characters.count
        var encodedNumber = ""
        
        for i in 0 ..< count {
            let index = number.characters.index(number.startIndex, offsetBy: i)
            encodedNumber = encodedNumber + "\(number[index])"
            
            if (i + 1) % 4 == 0 && i > 0 && i != count - 1 {
                encodedNumber += " "
            }
        }
        
        return encodedNumber
    }
    
    class func isValidData(_ newCard: Card) -> (isValid: Bool, title: String, message: String) {
        // Card owner name only allows characters.
      
        
        if !newCard.number!.isValidCreditCardNumber() {
            return (false, LocalizedStrings.invalidCardTitle, LocalizedStrings.invalidCardNumberMessage)
        }
        
        if !CardHelper.isValidExpiryDate(newCard.expiryMonth, expiryYear: newCard.expiryYear) { //isValidCardExpiryDate(newCard!.expiryDate) {
            return (false, LocalizedStrings.invalidCardTitle, LocalizedStrings.invalidCardExpiryDateMessage)
        }
        
        if !CardHelper.isValidCVV(newCard.cvv!, cardNumber: newCard.number!) {
            return (false, LocalizedStrings.invalidCardTitle, LocalizedStrings.invalidCardCVVMessage)
        }
        
        return (true, "", "")
    }
}

