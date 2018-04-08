//
//  Constants.swift
//  MaidMe
//
//  Created by Viktor on2/16/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit

struct ValidationExpression {
    static let email = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
    static let onlyCharacters = "^[a-zA-Z]*$"
}

struct CustomFont {
    static let quicksanRegular = "Quicksand-Regular"
    static let quicksanBold = "Quicksand-Bold"
}

struct APIKeys {
    static let customerID = "customer_id"
    static let tokenID = "token_id"
    static let statusToList = "status_to_list"
}

struct Parameters {
    static let contentType = "Content-Type"
    static let jsonContentType = "application/json; charset=utf-8"
    static let accessToken = "x-access-token"
    static let customerID = "customer-id"
    static let authorization = "Authorization"
    static let basic = "Basic "
    static let appVersion = "x-app-version"
}

struct KeychainIdentifier {
    static let appService = "ae.maidme.client"
    static let customerID = "customerIDIdentifier"
    static let tokenID = "tokenIDIdentifier"
    static let payfortkey = "payfortKeyIdentifier"
    static let emirate = "emirateIdentifier"
    static let area = "areaIdentifier"
    static let areaID = "areaIDIdentifier"
    static let userName = "userNameIdentifier"
    static let password = "passwordIdentifier"
    static let customerName = "customerNameIdentifier"
    static let workingAreaSelected = "workingAreaSelectedIdentifier"
    static let workingEmirateSelected = "workingEmirateSelectedIdentifier"
    static let fourDigitDefaultCard = "forDigitDefaultCardIdentifier"
    static let phoneNumber = "phoneNumberIdentifier"
}

struct Constants {
    static let imageKey = "image"
    static let titleKey = "title"
}

struct NotificationKeyName {
    static let logout = "logOutUserNotification"
}

struct DateFormater {
    static let dateOnlyFormat = "MMM dd, yyyy"
    static let timeFormat = "h:mm a"
    static let twelvehoursFormat = "dd.MM.yyyy - h:mm a"
    static let twentyFourhoursFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    static let monthYearFormat = "MM / yy"
}
struct GooglePlacesSearchAddress {
    static let key  = "AIzaSyC45WmfFO5MJBhc95DDBsInyYeXzz-lFQI"
    static let baseUrl = "https://maps.googleapis.com/maps/api/geocode/json?"
    static let getAddressForLatLngJsonResultskey = "results"
    static let getAddressForLatLngAddressKey = "address_components"
    static let typeNameAddress = "long_name"
    
}

struct PaymentKey {
    static var payfort = "dGVzdF9vcGVuX2tfODkwYjUzYjhlZWY1NDIxZDg0ODc=" // base64 format
    static let payfortDev = "dGVzdF9vcGVuX2tfODkwYjUzYjhlZWY1NDIxZDg0ODc="
    static let payfortProduction = "bGl2ZV9vcGVuX2tfNjczMmMwMjFmYTcyYWE5NTk5Yzk="
    
    static var payfortApiKey = "live_open_k_6732c021fa72aa9599c9"
    static let payfortApiKeyDev = "test_open_k_890b53b8eef5421d8487"
    static let payfortApiKeyLive = "live_open_k_6732c021fa72aa9599c9"

}
