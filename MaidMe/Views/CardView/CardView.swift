//
//  CardView.swift
//  MaidMe
//
//  Created by Viktor on 3/9/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit

class CardView: UIView {

    @IBOutlet var view: UIView!
    @IBOutlet weak var cardLogo: UIImageView!
    @IBOutlet weak var cardNumberLabel: UILabel!
    @IBOutlet weak var expiryDateLabel: UILabel!
   
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        Bundle.main.loadNibNamed(StoryboardIDs.cardView, owner: self, options: nil)
        
        self.view.frame = self.bounds
        self.addSubview(view)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        Bundle.main.loadNibNamed(StoryboardIDs.cardView, owner: self, options: nil)
        
        self.view.frame = self.bounds
        self.addSubview(view)
    }
    
    func showCardInfo(_ card: Card) {
        if card.brand == CardType.master {
            cardLogo.image = UIImage(named: ImageResources.mastercard)
        }
        else if card.brand == CardType.visa {
            cardLogo.image = UIImage(named: ImageResources.visacard)
        }
        
        cardNumberLabel.text = CardHelper.showLastFourDigit(card.lastFourDigit)
        expiryDateLabel.text = DateTimeHelper.getExpiryDateString(card.expiryMonth, year: card.expiryYear)
    
    }
}
