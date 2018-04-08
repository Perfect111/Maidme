//
//  CardDetailCell.swift
//  MaidMe
//
//  Created by Viktor on3/2/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit
import SWTableViewCell

class DefaultCardCell: SWTableViewCell {
    
    @IBOutlet weak var endCardNumber: UILabel!
    @IBOutlet weak var defaultCardLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}

class  AddNewCardCell: UITableViewCell{
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
