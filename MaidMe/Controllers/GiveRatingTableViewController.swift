//
//  GiveRatingTableViewController.swift
//  MaidMe
//
//  Created by Vo Minh Long on 1/4/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SSKeychain

protocol GiveRatingTableViewControllerDelegate {
    func didDismissRatingAndCommentBooking(_ isSubmitted: Bool)
}

class GiveRatingTableViewController: BaseTableViewController{
    
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var cardEndingNumberLabel: UILabel!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var serviceLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var workingHoursLabel: UILabel!
    @IBOutlet weak var bookingCodeLabel: UILabel!
    @IBOutlet weak var ratingView: RatingStars!
    @IBOutlet weak var workerImage: UIImageView!
    @IBOutlet weak var workerNameLabel: UILabel!
    var navController: UINavigationController?
    var currentViewcontroller: AnyObject?
    
    @IBOutlet weak var ImproveLabel: UILabel!
    @IBOutlet weak var commentTextView: UITextView!
    var bookingInfo: Booking!
    @IBOutlet weak var ratingView2: RatingStars!
    
    @IBOutlet weak var ratingButton: UIButton!
    
    var updateBookingDoneWithoutRatingAPI = GiveARatingCommentService()
    var delegate: GiveRatingTableViewControllerDelegate?
    var isSubmitted: Bool = false
    var listBookingDoneWithoutRating = [Booking]()
    var listBookingDoneWithoutRating2 = [Rating]()
    var count = 0
    var timesShow = 0
    var indexItemShow = 0
    //var booking: Booking!
    var rating = 0
    var textWorked = ""
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        self.hideBackbutton(true)
        commentTextView.text = "(Optional)\nLeave us your comment..."
        commentTextView.textColor = UIColor.lightGray
        commentTextView.layer.borderWidth = 0.5
        commentTextView.layer.borderColor = UIColor.gray.cgColor
        ratingButton.layer.cornerRadius = 5
        // commentTextView.delegate = self
        workerImage.layer.cornerRadius = self.workerImage.frame.height/2
        workerImage.layer.borderWidth = 1
        workerImage.layer.masksToBounds = true
        showBookingInfo()
        let tap = UITapGestureRecognizer(target: self, action: #selector(GiveRatingTableViewController.tap(_:)))
        view.addGestureRecognizer(tap)
    }
    @objc func tap(_ gesture: UITapGestureRecognizer){
        commentTextView.resignFirstResponder()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        delegate?.didDismissRatingAndCommentBooking(isSubmitted)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: self.view.window)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: self.view.window)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: -UI
    func showBookingInfo() {
        
        let i = indexItemShow
        let price = (listBookingDoneWithoutRating2[i].price == nil ? 0 : listBookingDoneWithoutRating2[i].price!)
        amountLabel.text = LocalizedStrings.currency + " " + String.localizedStringWithFormat("%.2f", price)
        
        // card ending
        cardEndingNumberLabel.text = (listBookingDoneWithoutRating2[i].last4)!
        
        // improve label
        ImproveLabel.text = "Help us improve the quality of service by rating " + (listBookingDoneWithoutRating2[i].firstName)!
        
        //worker name
        workerNameLabel.text = (listBookingDoneWithoutRating2[i].firstName)!+" "+(listBookingDoneWithoutRating2[i].lastName)!
        
        //star time
        let time = listBookingDoneWithoutRating2[i].timeofService!.toLocalTime(DateFormater.twelvehoursFormat)
        startTimeLabel.text = DateTimeHelper.getStringFromDate(time, format: "MMM dd yyyy, HH:mma")
        
        // service name
        serviceLabel.text = listBookingDoneWithoutRating2[i].serviceType
        
        //working hour
        textWorked = String (listBookingDoneWithoutRating2[i].hour!) + " H"
        workingHoursLabel.text = textWorked
        
        //booking code
        bookingCodeLabel.text = "Ref. \(listBookingDoneWithoutRating2[i].bookingCode == nil ?"" : listBookingDoneWithoutRating2[i].bookingCode!)"
        
        //rating star (view)
        ratingView.setRatingLevel((listBookingDoneWithoutRating2[i].rate)!)
        
        //rating
        ratingView2.setRatingLevel(4)
        ratingView2.setStarIcon(ImageResources.starRating, starAHalf: ImageResources.starAHalf, star: ImageResources.star)
        ratingView2.defineLevelRating()
        ratingView2.addGesture()
        
        //address
        addressLabel.text = (listBookingDoneWithoutRating2[i].building == nil ? "": listBookingDoneWithoutRating2[i].building)
        
        //image
        if listBookingDoneWithoutRating2[i].avatar! == " "{
            workerImage.image = UIImage(named: "noun")
        }
        else{
            let avartarURL: String = "\(listBookingDoneWithoutRating2[i].avatar!)"
            
            loadMaidImageFromURL(avartarURL, imageLoad: self.workerImage)
        }
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        if commentTextView.textColor == UIColor.lightGray {
            commentTextView.text = ""
            commentTextView.textColor = UIColor.black
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if commentTextView.text == "" {
            commentTextView.text = "(Optional)\nLeave us your comment..."
            commentTextView.textColor = UIColor.lightGray
        }
    }
    
    
    @IBAction func rateAction(_ sender: AnyObject) {
        //let booking = listBookingDoneWithoutRating2[indexItemShow]
        isSubmitted = true
        //ratingView2.defineLevelRating()
//        rating = ratingView2.currentLevel
//        booking.bookingID = booking.booking_ref_id
//        booking.rating = Int(rating)
//        booking.comment = commentTextView.text
        count = count + 1
        dismissKeyboard()
        updateBookingDoneWithoutRating()
        self.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "" {
            guard let destination = segue.destination as? AvailabelServicesViewController else {
                return
            }
            destination.isSubmitted = true
        }
    }
    
    
    func updateBookingDoneWithoutRating() {
        let rating = listBookingDoneWithoutRating2[indexItemShow]
        let id = rating.booking_ref_id ?? ""
        let rate = Int(ratingView2.currentLevel)
        var cmt: String = ""
        if commentTextView.textColor != UIColor.gray {
            cmt = commentTextView.text
        }
        
        let parameters = updateBookingDoneWithoutRatingAPI.getParams(id, rating: rate, comment: cmt)
        sendRequest(parameters, request: updateBookingDoneWithoutRatingAPI, requestType: .giveARatingComment, isSetLoadingView: true)
    }
    
    func sendRequest(_ parameters: [String: AnyObject],
                     request: RequestManager,
                     requestType: RequestType,
                     isSetLoadingView: Bool) {
        // Check for internet connection
        if RequestHelper.isInternetConnectionFailed() {
            RequestHelper.showNoInternetConnectionAlert(self)
            return
        }
        
        var headers = RequestManager.getAuthenticateHeader()
        headers["Content-Type"] = "application/json"
        
        Alamofire.request("\(Configuration.serverUrl)\(Configuration.giveARatingACommentURL)", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .responseJSON {  response in
                debugPrint(response)
                if((response.result.value) != nil) {
                    let swiftyJsonVar = JSON(response.result.value!)
                    if let message = swiftyJsonVar["messageInfo"].string {
                        // @todo show and alert with the message from the server
                        print(message);
                    }
                }
        }
    }
    
    func handleResponse(_ response: DataResponse<Any>, requestType: RequestType) {
        let result = ResponseHandler.responseHandling(response)
        
        if result.messageCode != MessageCode.success {
            // Show alert
            handleResponseError(result.messageCode, title: LocalizedStrings.internalErrorTitle, message: result.messageInfo, requestType: requestType)
            
            return
        }
        
        if requestType == .giveARatingComment {
            handleUpdateBookingDoneWithoutRatingResponse(result, requestType: .giveARatingComment)
        }
    }
    
    func handleUpdateBookingDoneWithoutRatingResponse(_ result: ResponseObject, requestType: RequestType) {
        
    }
}

