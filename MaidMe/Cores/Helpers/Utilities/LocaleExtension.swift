//
//  LocaleExtension.swift
//  MaidMe
//
//  Created by Viktor on3/29/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit

extension Locale {
    static func locales(_ country : String) -> String {
        let localesName : String = ""
        for localeCode in Locale.isoRegionCodes {
            let countryName = (Locale.current as NSLocale).displayName(forKey: NSLocale.Key.countryCode, value: localeCode)!
            if country.lowercased() == countryName.lowercased() {
                return localeCode
            }
        }
        return localesName
    }
}
