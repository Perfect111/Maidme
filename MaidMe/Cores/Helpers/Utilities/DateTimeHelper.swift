//
//  DateTimeHelper.swift
//  MaidMe
//
//  Created by Viktor on2/24/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit

class DateTimeHelper: NSObject {
    
    class func getDateFromString(_ dateString: String?, format: String) -> Date? {
        guard let _ = dateString else {
            return nil
        }
        
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = format
        
        return dateFormater.date(from: dateString!)
    }
    
    class func getStringFromDate(_ date: Date, format: String) -> String {
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = format
        
        return dateFormater.string(from: date)
    }
    
    class func getExpiryDateString(_ month: Int, year: Int) -> String {
        let date = DateTimeHelper.getDateFromString("\(month) / \(year)", format: DateFormater.monthYearFormat)
        return date!.getStringFromDate(DateFormater.monthYearFormat)!
    }
    
    /**
     Get time between input value and current time
     
     - parameter time:
     
     - returns:
     */
    class func getTimeDistance(_ time: Int64) -> Int64 {
        // Get current time
        let currentTime = Int64(Date().timeIntervalSince1970)
        let distance = currentTime - time / 1000
        
        return distance
    }
    
    /**
     Convert time to NSDateComponents for easy getting it in year, month, day...
     
     - parameter time:
     
     - returns:
     */
    class func convertTime(_ time: Int64) -> DateComponents {
        // The time interval
        let theTimeInterval: TimeInterval = TimeInterval(time)
        
        // Get the system calendar
        let sysCalendar = Calendar.current
        
        // Create the NSDates
        let date1 = Date()
        let date2 = Date(timeInterval: theTimeInterval, since: date1)
        
        // Get conversion to months, days, hours, minutes
        let unitFlags: NSCalendar.Unit = [.year, .month, .day, .hour, .minute, .second]
        let conversionInfo: DateComponents = (sysCalendar as NSCalendar).components(unitFlags, from: date1, to: date2, options: NSCalendar.Options.matchStrictly)
        
        return conversionInfo
    }
    
    /**
     Get the time in string
     
     - parameter conversionInfo:
     
     - returns:
     */
    class func getDisplayTime(_ conversionInfo: DateComponents) -> String {
        if conversionInfo.year != 0 {
            return "\(conversionInfo.year) \(getPluralForm(conversionInfo.year!, string: "year")) ago"
        }
        else if conversionInfo.month != 0 {
            return "\(conversionInfo.month) \(getPluralForm(conversionInfo.month!, string: "month")) ago"
        }
        else if conversionInfo.day != 0 {
            return "\(conversionInfo.day) \(getPluralForm(conversionInfo.day!, string: "day")) ago"
        }
        else if conversionInfo.hour != 0 {
            return "\(conversionInfo.hour) \(getPluralForm(conversionInfo.hour!, string: "hour")) ago"
        }
        else if conversionInfo.minute != 0 {
            return "\(conversionInfo.minute) \(getPluralForm(conversionInfo.minute!, string: "min")) ago"
        }
        else if conversionInfo.second != 0 {
            return "\(conversionInfo.second) \(getPluralForm(conversionInfo.second!, string: "sec")) ago"
        }
        
        return ""
    }
    
    class func getPluralForm(_ value: Int, string: String) -> String {
        if value > 1 {
            return string + "s"
        }
        return string
    }
    
    class func getCreatedTimeDistance(_ time: Int64?) -> String {
        guard let createdTime = time else {
            return ""
        }
        
        let distance = getTimeDistance(createdTime)
        let conversion = convertTime(distance)
        return getDisplayTime(conversion)
    }
}

extension Date {
    func isLessThanCurrentTime() -> Bool {
        let currentTime = Date()
        let calendar = Calendar.current
        var comp = (calendar as NSCalendar).components([.year, .month, .day, .hour, .minute], from: currentTime)
        comp.hour!+=1
        let time = calendar.date(from: comp)
        
        guard let comparedTime = time else {
            return false
        }
        
        if self.compare(comparedTime) == ComparisonResult.orderedAscending {
            return true
        }
        
        return false
    }
    
    func isLessThanCurrentMonth() -> Bool {
        let currentTime = Date()
        let calendar = Calendar.current
        let currentComp = (calendar as NSCalendar).components([.year, .month], from: currentTime)
        let comparedComp = (calendar as NSCalendar).components([.year, .month], from: self)
        
        if comparedComp.year! > currentComp.year! {
            return false
        }
            
        else if comparedComp.year! == currentComp.year! && comparedComp.month! >= currentComp.month! {
            return false
        }
        
        return true
    }
    
    func getDayOfWeek() -> String {
        let calendar = Calendar.current
        let oneDayFromNow = (calendar as NSCalendar).date(byAdding: .day, value: 1, to: Date(), options: [])
        
        let compDate = (calendar as NSCalendar).components([.year, .month, .day, .hour, .minute], from: self)
        let compToday = (calendar as NSCalendar).components([.year, .month, .day, .hour, .minute], from: Date())
        let compTomorrow = (calendar as NSCalendar).components([.year, .month, .day, .hour, .minute], from: oneDayFromNow!)
        if compDate.year == compToday.year && compDate.month == compToday.month && compDate.day == compToday.day {
            return LocalizedStrings.availableTime
        } else if compDate.year == compTomorrow.year && compDate.month == compTomorrow.month && compDate.day == compTomorrow.day {
            return LocalizedStrings.availableTomorrow
        } else {
            let dateFormater = DateFormatter()
            dateFormater.dateFormat = "EEEE"
            return dateFormater.string(from: self)
        }
        
    }
    func getDayMonthAndHour() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, HH:mma"
        dateFormatter.amSymbol = "am"
        dateFormatter.pmSymbol = "pm"
        return dateFormatter.string(from: self)
    }
    
    func getCurrentYear() -> Int {
        let calendar = Calendar.current
        let comp = (calendar as NSCalendar).components([.year, .month, .day], from: Date())
        
        return comp.year!
    }
    
    func getYear() -> Int {
        let calendar = Calendar.current
        let comp = (calendar as NSCalendar).components([.year, .month, .day], from: self)
        
        return comp.year!
    }
    
    func getMonth() -> Int {
        let calendar = Calendar.current
        let comp = (calendar as NSCalendar).components([.year, .month, .day], from: self)
        
        return comp.month!
    }
    
    func GMTTimeStamp() -> Double {
        let timeZoneOffset: TimeInterval = TimeInterval(NSTimeZone.local.secondsFromGMT())
        let gmtTimeInterval = self.timeIntervalSinceReferenceDate - timeZoneOffset
        let gmtDate = Date(timeIntervalSinceReferenceDate: gmtTimeInterval)
        
        return gmtDate.timeIntervalSince1970
    }
    
    func getStringFromDate(_ format: String) -> String? {
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = format
        
        return dateFormater.string(from: self)
    }
    
    func roundDownSecond() -> Date {
        let calendar = Calendar.current
        var comp = (calendar as NSCalendar).components([.year, .month, .day, .hour, .minute, .second], from: self)
        comp.second = 0
        
        return calendar.date(from: comp)!
    }
    
    func getNext30Days() -> Date {
        let date = self.roundDownSecond()
        
        let time30Days = Double(30 * 24 * 60 * 60)
        let timeInterval = date.timeIntervalSince1970
        
        return Date(timeIntervalSince1970: timeInterval + time30Days)
    }
    
    func getNext7Days() -> Date {
        let date = self.roundDownSecond()
        
        let time30Days = Double(7 * 24 * 60 * 60)
        let timeInterval = date.timeIntervalSince1970
        
        return Date(timeIntervalSince1970: timeInterval + time30Days)
    }
    
    func getNextRoundedTime() -> Date {
        let date = self.roundDownSecond()
        let calendar = Calendar.current
        let comp = (calendar as NSCalendar).components([.year, .month, .day, .hour, .minute], from: date)
        
        if comp.minute! > 0 && comp.minute! < 30 {
            return Date(timeIntervalSince1970: date.timeIntervalSince1970 + Double((30 - comp.minute!) * 60))
        }
        if comp.minute! > 30 && comp.minute! < 60 {
            return Date(timeIntervalSince1970: date.timeIntervalSince1970 + Double((60 - comp.minute!) * 60))
        }
        
        return self
    }
    
    func getNextOneRoundedHourTime() -> Date {
        let roundedTime = self.getNextRoundedTime()
        let nextOneRounedTime = roundedTime.timeIntervalSince1970 + 60 * 60
        
        return Date(timeIntervalSince1970: nextOneRounedTime)
    }
    
    func getHourOfToday() -> String {
        let calendar = Calendar.current
        let compDate = (calendar as NSCalendar).components([.year, .month, .day, .hour, .minute], from: self)
        let compToday = (calendar as NSCalendar).components([.year, .month, .day, .hour, .minute], from: Date())
        
        if compDate.year == compToday.year && compDate.month == compToday.month && compDate.day == compToday.day {
            return LocalizedStrings.availableTime + self.getHourAndMin()
        }
        
        return DateTimeHelper.getStringFromDate(self, format: DateFormater.twelvehoursFormat)
    }
    
    func getHourAndMin() -> String {
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = DateFormater.timeFormat
        
        return dateFormater.string(from: self)
    }
    
    func toLocalTime(_ format: String) -> Date {
        let dateString = DateTimeHelper.getStringFromDate(self, format: format)
        
        let df = DateFormatter()
        df.dateFormat = format
        
        //Create the date assuming the given string is in GMT
        df.timeZone = TimeZone(secondsFromGMT: 0)
        let date = df.date(from: dateString)
        
        return date!
    }
}
