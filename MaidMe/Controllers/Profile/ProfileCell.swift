//
//  ProfileCell.swift
//  MaidMe
//
//  Created by Viktor on2/26/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit

class ProfileNameCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ratingView: RatingStars!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func showMaidDetails(_ maid: Worker) {
        nameLabel.text = maid.firstName! + " " + maid.lastName!
        ratingView.setRatingLevel(maid.rateAverage == 0 ? 0 : maid.rateAverage)
    }
}

class ProfileReviewCell: UITableViewCell {
    
    @IBOutlet weak var reviewTotalLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func showTotalReview(_ total: Int) {
        reviewTotalLabel.text = LocalizedStrings.review + "(\(total))"
    }
}

class ProfileReviewDetailCell: UITableViewCell {
    
    @IBOutlet weak var serviceNameLabel: UILabel!
    @IBOutlet weak var serviceRatingView: RatingStars!
    @IBOutlet weak var serviceCommentTextView: UITextView!
    @IBOutlet weak var serviceTimeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func showDetail(_ booking: Booking) {
        serviceNameLabel.text = LocalizedStrings.service + "\(booking.service?.name == nil ? "" : booking.service!.name!)"
        serviceRatingView.setRatingLevel(booking.rating == 0 ? 0 : booking.rating)
        serviceCommentTextView.text = booking.comment
        serviceTimeLabel.text = DateTimeHelper.getCreatedTimeDistance(Int64(booking.timeOfRating!.timeIntervalSince1970 + Double(NSTimeZone.local.secondsFromGMT())) * 1000)
    }
}
