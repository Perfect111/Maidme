//
//  CustomTabbarViewController.swift
//  MaidMe
//
//  Created by Viktor on 1/6/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import UIKit

class CustomTabbarViewController: BaseViewController {
    
    @IBOutlet weak var segmented: UISegmentedControl!
    @IBOutlet weak var containerPast: UIView!
    @IBOutlet weak var containerUpComing: UIView!
    
    var embeddedViewController: PastOrderTableViewCOntroller!
    override func viewDidLoad() {
        super.viewDidLoad()
        //  let segAttributes: NSDictionary = [
        //            NSForegroundColorAttributeName: UIColor(red: 61/255, green: 185/255, blue: 216/255, alpha: 1)]
        
        let segAttributes: NSDictionary = [
            NSAttributedStringKey.foregroundColor: UIColor.black,
            NSAttributedStringKey.font: UIFont(name: "Quicksand", size: 15)!
        ]
        self.segmented.setTitleTextAttributes(segAttributes as! [AnyHashable: Any], for: UIControlState())
        containerPast.alpha = 0
        containerUpComing.alpha = 0
        self.segmented.layer.cornerRadius = 0.1
        self.segmented.layer.borderColor = UIColor.white.cgColor
        selectedSegment()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
		self.navigationItem.hidesBackButton = true
        self.customBackButton()
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(showUpcoming), name: NSNotification.Name(rawValue: "showUpComming"), object: nil)
    }
    @objc func showUpcoming(){
        segmented.selectedSegmentIndex = 0
        selectedSegment()
        NotificationCenter.default.removeObserver(self)
    }
    
    func selectedSegment(){
        let array = segmented.subviews
        if segmented.selectedSegmentIndex == 0{
            let segAttributes: NSDictionary = [
                NSAttributedStringKey.foregroundColor: UIColor.black,
                NSAttributedStringKey.font: UIFont(name: "Quicksand", size: 15)!
            ]
            self.segmented.setTitleTextAttributes(segAttributes as! [AnyHashable: Any], for: UIControlState())
            
            UIView.animate(withDuration: 0.5, animations: {
                self.containerUpComing.alpha = 1
                self.containerPast.alpha = 0
                
                array[0].tintColor = UIColor.white//(red: 61/255, green: 185/255, blue: 216/255, alpha: 1)
                array[1].tintColor = UIColor.white//(red: 61/255, green: 185/255, blue: 216/255, alpha: 1)
                let segAttributes: NSDictionary = [
                    NSAttributedStringKey.foregroundColor: UIColor(red: 61/255, green: 185/255, blue: 216/255, alpha: 1),
                    NSAttributedStringKey.font: UIFont(name: "Quicksand", size: 15)!
                ]
                self.segmented.setTitleTextAttributes(segAttributes as! [AnyHashable: Any], for: UIControlState.selected)
                
                
            })
        }
        else{
            let segAttributes: NSDictionary = [
                NSAttributedStringKey.foregroundColor: UIColor.black,
                NSAttributedStringKey.font: UIFont(name: "Quicksand", size: 15)!
            ]
            self.segmented.setTitleTextAttributes(segAttributes as! [AnyHashable: Any], for: UIControlState())
            
            UIView.animate(withDuration: 0.5, animations: {
                self.containerUpComing.alpha = 0
                self.containerPast.alpha = 1
                array[1].tintColor = UIColor.white//(red: 61/255, green: 185/255, blue: 216/255, alpha: 1)
                array[0].tintColor = UIColor.white//(red: 61/255, green: 185/255, blue: 216/255, alpha: 1)
                let segAttributes: NSDictionary = [
                    NSAttributedStringKey.foregroundColor: UIColor(red: 61/255, green: 185/255, blue: 216/255, alpha: 1),
                    NSAttributedStringKey.font: UIFont(name: "Quicksand", size: 15)!
                ]
                self.segmented.subviews[1]
                self.segmented.setTitleTextAttributes(segAttributes as! [AnyHashable: Any], for: UIControlState.selected)
                
            })
        }

        
    }
    @IBAction func showComponent(_ sender: UISegmentedControl) {
        let array = segmented.subviews
        if sender.selectedSegmentIndex == 0{
            UIView.animate(withDuration: 0.5, animations: {
                self.containerUpComing.alpha = 1
                self.containerPast.alpha = 0
                array[0].tintColor = UIColor.white//(red: 61/255, green: 185/255, blue: 216/255, alpha: 1)
                array[1].tintColor = UIColor.white//(red: 61/255, green: 185/255, blue: 216/255, alpha: 1)
                let segAttributes: NSDictionary = [
                    NSAttributedStringKey.foregroundColor: UIColor(red: 61/255, green: 185/255, blue: 216/255, alpha: 1),
                    NSAttributedStringKey.font: UIFont(name: "Quicksand", size: 15)!
                ]
                
                self.segmented.setTitleTextAttributes(segAttributes as! [AnyHashable: Any], for: UIControlState.selected)
                
            })
        }
        else{
            UIView.animate(withDuration: 0.5, animations: {
                self.containerUpComing.alpha = 0
                self.containerPast.alpha = 1
                array[1].tintColor = UIColor.white//(red: 61/255, green: 185/255, blue: 216/255, alpha: 1)
                array[0].tintColor = UIColor.white//(red: 61/255, green: 185/255, blue: 216/255, alpha: 1)
                let segAttributes: NSDictionary = [
                    NSAttributedStringKey.foregroundColor: UIColor(red: 61/255, green: 185/255, blue: 216/255, alpha: 1),
                    NSAttributedStringKey.font: UIFont(name: "Quicksand", size: 15)!
                ]
                self.segmented.subviews[1]
                self.segmented.setTitleTextAttributes(segAttributes as! [AnyHashable: Any], for: UIControlState.selected)
                let storyboard = self.storyboard
                guard let PastVC = storyboard?.instantiateViewController(withIdentifier: "PastVC") as? PastOrderTableViewCOntroller else {
                    return
                }
                PastVC.tableView.beginUpdates()
                PastVC.tableView.reloadData()
                PastVC.tableView.endUpdates()
                
            })
        }
    }
    
}
