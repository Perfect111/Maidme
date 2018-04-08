//
//  RatingStars.swift
//  Edgar
//
//  Created by Viktor on 12/29/15.
//  Copyright © 2015 Mac. All rights reserved.
//

import UIKit

class RatingStars: UIView {
    
    @IBOutlet var view: UIView!
    @IBOutlet weak var star1: UIImageView!
    @IBOutlet weak var star2: UIImageView!
    @IBOutlet weak var star3: UIImageView!
    @IBOutlet weak var star4: UIImageView!
    @IBOutlet weak var star5: UIImageView!
    
    var ratingLevel: Float!
    var stars: [UIImageView]!
    var currentLevel = -1
    var starNone = ImageResources.starNone
    var starAHalf = ImageResources.starAHalf
    var star = ImageResources.star
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        Bundle.main.loadNibNamed(StoryboardIDs.ratingStars, owner: self, options: nil)
        
        self.view.frame = self.bounds
        stars = [star1, star2, star3, star4, star5]
        self.addSubview(view)
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        Bundle.main.loadNibNamed(StoryboardIDs.ratingStars, owner: self, options: nil)
        
        self.view.frame = self.bounds
        stars = [star1, star2, star3, star4, star5]
        self.addSubview(view)
    }
    
    func setStarIcon(_ starNone: String, starAHalf: String, star: String) {
        self.starNone = starNone
        self.starAHalf = starAHalf
        self.star = star
    }
    
    func setRatingLevel(_ level: Float) {
        // Default image is star-on, set star-non depends on level
        for i in ((0 + 1)...stars.count).reversed() {
            if level < Float(i) {
                stars[i - 1].image = UIImage(named: starNone)//ImageResources.starNone)
            }
        }
        
        for i in 0 ..< stars.count {
            setStar(level, level: Float(i), starView: stars[i])
        }
        
        if level < 0 {
            self.alpha = 0.3
        }
        else {
            self.alpha = 1.0
        }
    }
    
    func setStar(_ rating: Float, level: Float, starView: UIImageView) {
        let ratingLevel = roundStar(rating)
        
        if ratingLevel > level {
            starView.image = UIImage(named: star)//ImageResources.star)
        }
        if ratingLevel == level + 0.5 {
            starView.image = UIImage(named: starAHalf)//ImageResources.starAHalf)
        }
    }
    
    func roundStar(_ rate: Float) -> Float {
        let dicimal = rate - floor(rate)
        
        if dicimal > 0 && dicimal <= 0.5 {
            return floor(rate) + 0.5
        }
        
        return ceil(rate)
    }
    
    
    func addGesture() {
        view.isUserInteractionEnabled = true
        
        
        for start in stars {
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(RatingStars.imageTapped(_:)))
            start.addGestureRecognizer(tapGestureRecognizer)
        }
        
    }
    
    @objc func imageTapped(_ sender: UITapGestureRecognizer? = nil) {
        guard let image = sender?.view as? UIImageView else {
            return
        }
        
        for i in 0 ..< stars.count {
            if image == stars[i] {
                print("star index: ", i)
                if(i == 0 && currentLevel == 1) {
                    setRatingLevel(0)
                    currentLevel = 0
                    break
                }
                else {
                    setRatingLevel(Float(i + 1))
                    currentLevel = i+1
                    break
                }
                
            }
        }
    }
    
    
    func defineLevelRating() {
        currentLevel = 4
        setRatingLevel(4)
        
    }
}
