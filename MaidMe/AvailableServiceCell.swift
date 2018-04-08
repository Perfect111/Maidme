//
//  AvailabelServiceCell.swift
//  MaidMe
//
//  Created by Viktor on 12/23/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit
import Alamofire
import SDWebImage

class AvailabelServiceCell: UITableViewCell {
    
    
    @IBOutlet weak var detailService: UILabel!
    @IBOutlet weak var imageName: UIImageView!
    @IBOutlet weak var serviceName: UILabel!
    @IBOutlet weak var backgroundCardView : UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundCardView.backgroundColor = UIColor.white
        contentView.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0)
        self.removeSeparatorLineInset()
        backgroundCardView.clipsToBounds = false
        backgroundCardView.layer.shadowOpacity = 0.25
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        
    }
    
}

var imageCache = [String: UIImage]()
extension UITableViewCell {
    func cropImage(_ imageCrop: UIImage) -> UIImage {
        let imageView = UIImageView(image: imageCrop)
        let crop = CGRect(x: 0, y: imageView.frame.height/2, width: imageView.frame.width, height: imageView.frame.height/2)
        let cgImage = imageCrop.cgImage!.cropping(to: crop)
        let image: UIImage = UIImage(cgImage: cgImage!)
        return image
    }
    func loadImageFromURLwithCache(_ imageString: String,imageLoad: UIImageView) {
        imageLoad.image = nil
        
        let urlString: String = "http:\(imageString)"
        
        
		imageLoad.sd_setImage(with: URL(string: urlString), completed: { (image, error, cacheType, url) in
			if image != nil {
				imageLoad.image = self.cropImage(image!)
			}
		})
	}
}
