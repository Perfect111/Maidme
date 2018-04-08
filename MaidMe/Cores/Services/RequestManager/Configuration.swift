//
//  Configuration.swift
//  MaidMe
//
//  Created by Viktor on2/15/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit

struct Configuration {
    static var serverUrl = "http://localhost:8080"
    static let serverDevUrl = "http://dev-backoffice.maidme.io"
    static let serverProductionUrl = "https://m-api.maidme.ae"
    
    static let maidImagesPath = "http://static.maidme.io/images/maids/"
    
    static let registerUrl = "/api/customers/register"
    static let loginUrl = "/api/customers/login"
    static let workingAreaListUrl = "/api/workingareas"
    static let serviceTypesUrl = "/api/servicetypes"
    static let availableWorkerUrl = "/api/maids/search"
    static let createCustomerCardUrl = "/api/payment/cards/add"
    static let lockABookingUrl = "/api/bookings/lock"
    static let fetchAllCardUrl = "/api/payment/cards"
    static let suggetedWorker = "/api/maids/suggested"
    
    // Booking
    static let createABookingUrl = "/api/bookings/new"
    static let addNewBookingAddressUrl = "/api/customers/addresses/new"
    static let updateBookingAddressUrl = "/api/customers/addresses/update"
    static let fetchAllBookingAddressesUrl = "/api/customers/addresses"
    static let fetchAllUpcomingBookingUrl = "/api/bookings/upcoming"
    static let cancelABookingUrl = "/api/bookings/cancel"
    static let clearALockedBookingUrl = "/api/bookings/clear"
    static let getBookingDoneNotRatingUrl = "/api/bookings/done/not_rating"
    static let bookingHistoryUrl = "/api/bookings/history"
    static let giveARatingACommentURL = "/api/bookings/ratings/new"
    
    // Personal Details
    static let getCustomerDetailsUrl = "/api/customers/get"
    static let updateCustomerDetailsUrl = "/api/customers/update/details"
    static let updateCustomerPasswordUrl = "/api/customers/update/password"
    static let getRatingsAndCommentsUrl = "/api/bookings/ratings/new"
    
    //Card
    static let removeCardUrl = "/api/payment/cards/remove"
    static let setDefaultCardUrl = "/api/payment/cards/default"
    
    //StartSDK
    
    static var startSDKUrl = "https://api.start.payfort.com/tokens/"
    static let startSDKDevUrl = "https://api.start.payfort.com/tokens/"
    static let startSDKProductionUrl = "https://api.start.payfort.com/tokens/"
    
    
    // Payfort
    static var payfortUrl = "https://sbpaymentservices.payfort.com/FortAPI/paymentApi"
    static let payfortDevUrl = "https://sbpaymentservices.payfort.com/FortAPI/paymentApi"
    static let payfortProductionUrl = "https://paymentservices.payfort.com/FortAPI/paymentApi"
    
    static var requestPhrase = "ahjsi98274kja9848"
    static var accessCode = "rfTeUAgeQRLqmzqjzddQ"
    static var merchantID = "pHlShUqV"
    
    static let payfortDevPhrase = "ahjsi98274kja9848"
    static let payfortDevAccessCode = "rfTeUAgeQRLqmzqjzddQ"
    static let payfortDevMerchantID = "pHlShUqV"
    
    static let payfortProductPhrase = "ahjsi98274kja9848"
    static let payfortProductAccessCode = "rfTeUAgeQRLqmzqjzddQ"
    static let payfortProductMerchantID = "pHlShUqV"
    
    static let authCommand = "AUTHORIZATION"
    static let purchaseCommand = "PURCHASE"
    static let sdkTokenCommand = "SDK_TOKEN"
    static let payfortCurreny = "AED"
    static let payfortLanguage = "en"
    
    // Terms and Conditions
    static let termsAndConditionsUrl = "/api/termandconditon/get"
    
    // Forgot password
    static let forgotPasswordUrl = "/api/customers/forgot/password"
    
    // Re-booking
    static let availableServicesOfMaidUrl = "/api/servicetypes/get/bymaid"
    static let rebookingGetTimeOptionsUrl = "/api/bookings/rebook/getAvailableServices"
    
    // Get min time of a booking
    static let minPeriodWorkingHourUrl = "/api/companies/get/minbookinghours"
    
    // Address
    static let removeAddressUrl = "/api/customers/addresses/delete"
    
    
}
