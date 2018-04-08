//
//  StringHelper.swift
//  Edgar
//
//  Created by Viktor on12/25/15.
//  Copyright © 2015 SmartDev. All rights reserved.
//

import UIKit
import CryptoSwift
import PhoneNumberKit

class StringHelper: NSObject {

    /**
     Get the real size of string
     
     - parameter string: input string
     
     - returns: width and height of the string
     */
    class func stringSize(_ string: String) -> (swidth: CGFloat, sheight: CGFloat) {
        let button = UIButton(type: UIButtonType.custom)
        button.setTitle(string, for: UIControlState())
        button.sizeToFit()
        
        return (button.frame.width, button.frame.height)
    }
    
    /**
     Trim all white spaces exist in the string
     
     - parameter text:
     
     - returns: no white space string
     */
    class func trimWhiteSpace(_ text: String) -> String {
        let words = text.components(separatedBy: CharacterSet.whitespacesAndNewlines)
        let nospacestring = words.joined(separator: "")
        
        return nospacestring
    }
    
    /**
     Lucy: Trim all white space at the begining and the end the text
     
     - parameter text:
     
     - returns:
     */
    class func trimBeginningWhiteSpace(_ text: String) -> String {
        let trimedString = text.trimmingCharacters(in: CharacterSet.whitespaces)
        return trimedString
    }
    
    
    // MARK: - Phone number
    
    /**
    Trim the first 0 number appears in the phone number
    
    - parameter phoneNumber:
    
    - returns:
    */
    class func trimExtraZeroNumber(_ phoneNumber: String) -> String {
        if phoneNumber.hasPrefix("0") {
            return phoneNumber.substring(from: phoneNumber.characters.index(phoneNumber.startIndex, offsetBy: 1))
        }
        return phoneNumber
    }
    
    /**
     Create phone number from country dialing code and number
     
     - parameter code:   country dialing code
     - parameter number: phonenumber
     
     - returns: 
     */
    class func createPhoneNumber(_ code: String, number: String) -> String {
        var phoneNumber = trimWhiteSpace(number)
        phoneNumber = trimExtraZeroNumber(phoneNumber)
        return code + phoneNumber
    }
    
    class func reformatPhoneNumber(_ number: String) -> String {
        do {
            let phoneKit = PhoneNumberKit()
            let phoneNumber = try phoneKit.parse(number)
            return phoneKit.format(phoneNumber, toType: .international)
        }
        catch {
            return number
        }
    }
    
    class func getPhoneNumber(_ number: String) -> String {
        do {
            let phoneKit = PhoneNumberKit()
            let phoneNumber = try phoneKit.parse(number)
            return phoneKit.format(phoneNumber, toType: .e164)
        }
        catch {
            return number
        }
    }
    
    class func getHourString(_ hour: Int) -> String {
        if hour <= 1 {
            return "\(hour) " + LocalizedStrings.hour
        }
        
        return "\(hour) " + LocalizedStrings.hours
    }
    
    // MARK: - SHA
    
    class func encryptString(_ string: String) -> String {
        if let data: Data = string.data(using: String.Encoding.utf8) {
            let hash = data.sha256()
            
            return hash.base64EncodedString(options: NSData.Base64EncodingOptions.lineLength64Characters) 
                
            
        }
        
        return string.sha256()
    }
    
    class func encryptStringsha256(_ string: String) -> String {
        let hashString: String = string.sha256()
        
        if let data: Data = hashString.data(using: String.Encoding.utf8) {
            var base64: String = data.base64EncodedString(options: NSData.Base64EncodingOptions.lineLength64Characters)
            base64 = base64.replacingOccurrences(of: "\r\n", with: "")
            
            return base64
        }
        
        return ""
    }
    
    class func setPlaceHolderFont(_ fields: [UITextField], font: String, fontsize: CGFloat) {
        let font = UIFont(name: font, size: fontsize)!
        let attributes = [
            NSAttributedStringKey.foregroundColor: UIColor.lightGray,
            NSAttributedStringKey.font : font]
        
        for field in fields {
            field.attributedPlaceholder = NSAttributedString(string: field.placeholder!,
                attributes:attributes)
        }
    }
    
    class func getAddress(_ strings: [String?]) -> String {
        var address = ""
        
        for string in strings {
            guard var string = string else {
                continue
            }
            
            string = trimBeginningWhiteSpace(string)
            
            if string == "" {
                continue
            }
            
            if address == "" {
                address = string
                continue
            }
            
            address = address + ", " + string
        }
        
        return address
    }
    
    class func getTextViewHeight(_ textView: UITextView) -> CGFloat {
        let fixedWidth = textView.frame.size.width
        textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        var newFrame = textView.frame
        
        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        
        return newFrame.height
    }
    
    class func resizeTextView(_ textView: UITextView) {
        let fixedWidth = textView.frame.size.width
        textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        var newFrame = textView.frame
        
        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        textView.frame = newFrame;
    }
    
    class func getTextHeight(_ text: String, width: CGFloat, fontSize: CGFloat) -> CGFloat {
        let textView = UITextView(frame: CGRect(x: 0, y: 0, width: width, height: 49))
        
        textView.text = text
        textView.font = UIFont(name: CustomFont.quicksanRegular, size: fontSize)
        
        let fixedWidth = textView.frame.size.width
        textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        var newFrame = textView.frame
        
        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        
        return newFrame.height
    }
    
    class func addPlusSign(_ phoneNumber: String) -> String {
        var string = trimWhiteSpace(phoneNumber)
        
        if !string.hasPrefix("+") {
            string = "+" + string
        }
        
        return string
    }
 }

extension String {
    
    subscript (i: Int) -> Character {
        return self[self.characters.index(self.startIndex, offsetBy: i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    subscript (r: Range<Int>) -> String {
        let start = self.index(startIndex, offsetBy: r.lowerBound)
        let end = self.index(start, offsetBy: r.upperBound - r.lowerBound)
        return String(self[(start ..< end)])
    }
}
