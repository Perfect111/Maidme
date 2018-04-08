//
//  AddressTitleView.swift
//  MaidMe
//
//  Created by Viktor on 1/3/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import Foundation
import UIKit

class AddressTitleView: UIView {
     let minimumSize: CGSize = CGSize(width: 44.0, height: 44.0)
    @IBOutlet var view: UIView!
    @IBOutlet weak var dropDownImage : UIImageView!
    @IBOutlet weak var buildingNameLabel: UILabel!
    @IBOutlet weak var showListAddressButton: UIButton!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        Bundle.main.loadNibNamed("AddressTitleView", owner: self, options: nil)
        self.view.frame = self.bounds
        self.addSubview(view)
          clipsToBounds = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        Bundle.main.loadNibNamed("AddressTitleView", owner: self, options: nil)
        self.view.frame = self.bounds
        self.addSubview(view)
          clipsToBounds = true
    }
    
   
}
private extension UIView {
    func typedSuperview<T: UIView>() -> T? {
        var parent = superview
        
        while parent != nil {
            if let view = parent as? T {
                return view
            } else {
                parent = parent?.superview
            }
        }
        
        return nil
    }
}
