//
//  BookingTabBarController.swift
//  MaidMe
//
//  Created by Vo Minh Long on 12/14/16.
//  Copyright © 2016 SmartDev. All rights reserved.
//

import UIKit

class BookingTabBarController: BaseTabController{
    override func viewDidLoad() {
        self.tabBar.frame = CGRectMake(0, 0, self.view.bounds.size.width,49)
        self.tabBar.autoresizingMask = UIViewAutoresizing.FlexibleTopMargin
        self.tabBar.autoresizingMask = UIViewAutoresizing.FlexibleLeftMargin
        self.tabBar.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        self.tabBar.autoresizingMask = UIViewAutoresizing.FlexibleRightMargin
        let appearance = UITabBarItem.appearance()
      
        let attributes: [String: AnyObject] = [NSFontAttributeName:UIFont(name: CustomFont.quicksanBold, size: 15)!]
        appearance.setTitleTextAttributes(attributes, forState: .Normal)

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //  createRightMenuButton()
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        //    removeRightMenuButton()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

