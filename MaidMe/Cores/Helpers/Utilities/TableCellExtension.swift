//
//  TableCellExtension.swift
//  MaidMe
//
//  Created by Viktor on3/17/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit

extension UITableViewCell {
    
    func removeSeparatorLineInset() {
        // Remove seperator inset
        if (self.responds(to: #selector(setter: UITableViewCell.separatorInset))) {
            self.separatorInset = UIEdgeInsets.zero
        }
        
        // Prevent the cell from inheriting the Table View's margin settings
        if (self.responds(to: #selector(setter: UIView.preservesSuperviewLayoutMargins))) {
            self.preservesSuperviewLayoutMargins = false
        }
        
        // Explictly set your cell's layout margins
        if (self.responds(to: #selector(setter: UIView.layoutMargins))) {
            self.layoutMargins = UIEdgeInsets.zero
        }
    }
    
    func removeSeparatorLine() {
        //self.separatorInset = UIEdgeInsetsMake(0, CGRectGetWidth(self.frame), 0, 0)
        self.separatorInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, self.bounds.size.width)
    }
    
    func showSeparatorLine() {
        self.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)
    }
}
