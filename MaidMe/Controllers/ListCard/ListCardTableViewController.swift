//
//  ListCardTableViewController.swift
//  MaidMe
//
//  Created by Viktor on3/2/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit
import Alamofire

class ListCardTableViewController: BaseTableViewController {

    /*let cardList = [Card(type: .Visa, number: "4485330182280237", expiryDate: DateTimeHelper.getDateFromString("12 / 23", format: DateFormater.monthYearFormat)!, ownerName: "Luciana Ng", cvv: "213", country: "Vietnam"), Card(type: .Master, number: "5534957063308139", expiryDate: DateTimeHelper.getDateFromString("12 / 18", format: DateFormater.monthYearFormat)!, ownerName: "Runawa Hamichi Karito", cvv: "343", country:"United Arab Emirates")]*/
    
        var cardList = [Card]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
       
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "YOUR CARDS"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
  


    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if cardList.count == 0 {
            return 1
        } else {
            return cardList.count + 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if cardList.count != 0 && indexPath.row >= 0 && indexPath.row < cardList.count {
            let cellIdentifier = "defaultCardCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? DefaultCardCell
            let fourDigit :String = cardList[indexPath.row].lastFourDigit
            cell?.endCardNumber.text = "**** **** **** \(fourDigit)"
            if cardList[indexPath.row].isDefault ==  true {
                cell?.defaultCardLabel.text = "DEFAULT CARD"
            } else {
                cell?.defaultCardLabel.text = "CARD"
            }
            return cell!
        }
        else {
            let cellIdentifier = "addNewCardCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? AddNewCardCell
            return cell!
        }
        
    }
    
    @IBAction func editPersonalAction(_ sender: AnyObject) {
        let storyboard = self.storyboard
        guard let personalVC = storyboard?.instantiateViewController(withIdentifier: StoryboardIDs.personalDetails) else {
            return
        }
        self.navigationController?.pushViewController(personalVC, animated: true)
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row != cardList.count {
            self.performSegue(withIdentifier: SegueIdentifiers.doneSelectCard, sender: self)
        } else {
            self.performSegue(withIdentifier: SegueIdentifiers.addNewCard, sender: self)
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == SegueIdentifiers.doneSelectCard || segue.identifier == SegueIdentifiers.addNewCard {
            guard let destination = segue.destination as? PaymentViewController else {
                return
            }
            
            guard let index = tableView.indexPathForSelectedRow else {
                return
            }
            
            if index.row == cardList.count {
                destination.selectedCard = nil
                //destination.newCard = Card()
                destination.resetPaymentInfor()
                return
            }
            
            destination.selectedCard = cardList[index.row]
            //destination.newCard = nil
        }
    }

}
