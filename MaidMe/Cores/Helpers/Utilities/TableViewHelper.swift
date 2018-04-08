//
//  TableViewHelper.swift
//  Edgar
//
//  Created by Viktor on12/29/15.
//  Copyright © 2015 smartdev. All rights reserved.
//

import UIKit

extension UITableView {
    /**
     Remove the separator lines.
     
     - parameter tableView: target table view
     */
    func removeSeparatorLines() {
        self.separatorStyle = UITableViewCellSeparatorStyle.none
        self.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: false)
        self.bounces = false
    }
    
    /**
     Hide empty cells of the table.
     
     - parameter tableView: target table view
     */
    func hideTableEmptyCell() {
        let backgroundView = UIView(frame: CGRect.zero)
        self.tableFooterView = backgroundView
    }
    
    /**
     Remove the separator line's inset
     
     - parameter cell:
     */
    func removeSeparatorLineInset(_ cells: [UITableViewCell]) {
        // Remove seperator inset
        for cell in cells {
            cell.removeSeparatorLineInset()
        }
    }

    func removeSeparatorLine(_ cells: [UITableViewCell]) {
        for cell in cells {
            cell.removeSeparatorLine()
        }
    }
    
    func showSeparatorLine(_ cells:[UITableViewCell]) {
        for cell in cells {
            cell.showSeparatorLine()
        }
    }
}
