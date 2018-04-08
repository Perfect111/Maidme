//
//  ClipView.swift
//  MaidMe
//
//  Created by Viktor on 3/13/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit

class ClipView: UIView {
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let child = super.hitTest(point, with: event)
        
        if child == self && self.subviews.count > 0 {
            return self.subviews[0]
        }
        return child
    }
}
