//
//  ShopViewController.swift
//  PaddleBallA52
//
//  Created by iMac21.5 on 7/8/15.
//  Copyright (c) 2015 Garth MacKenzie. All rights reserved.
//

import UIKit

class ShopViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet var backdropImageView: UIImageView!
    @IBOutlet weak var leftTrophyImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var rightTrophyImageView: UIImageView!
    @IBOutlet weak var userPickerView: UIPickerView!
    @IBOutlet weak var userPickerView1: UIPickerView!
    @IBOutlet weak var userPickerView2: UIPickerView!
    @IBOutlet weak var userPickerView3: UIPickerView!
    //MARK: - UIPickerViewDataSource
    private var pickerDataSource: [UIImage] { // a computed property instead of func
        get {
            return (0..<names.count).map {
                UIImage(named: self.names[$0])!
            }
        }
        set { self.pickerDataSource = newValue }
    }
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int { return 4 } //number of wheels in the picker
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerDataSource.count
    }
    //MARK: - UIPickerViewDelegate
    func pickerView(pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 80.0
    }
    func pickerView(pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 80.0
    }
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView!) -> UIView {
        var iv = UIImageView(image: pickerDataSource[row])
        iv.bounds = CGRect(x: 0, y: 0, width: 80, height: 80)
        return iv
    }
    var selectedBallSkin: UIImage?
    var selectedBallSkin1: UIImage?
    var selectedBallSkin2: UIImage?
    var selectedBallSkin3: UIImage?
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 { selectedBallSkin = pickerDataSource[row] }
        if component == 1 { selectedBallSkin1 = pickerDataSource[row] }
        if component == 2 { selectedBallSkin2 = pickerDataSource[row] }
        if component == 3 { selectedBallSkin3 = pickerDataSource[row] }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.font = UIFont(name: "ComicSansMS-Bold", size: 28.0)
        userPickerView.dataSource = self
        userPickerView.delegate = self
        prepareForPurchase()
    }
    var availableCredits = 0
    func prepareForPurchase() {
        let shopTabBarItem = tabBarController!.tabBar.items![4] as! UITabBarItem
        if let ac = shopTabBarItem.badgeValue?.toInt()! {
            if ac > 9 { //everything costs 10 credits or $1
                availableCredits = ac
            }
        } else {
            let alert = UIAlertView(title: "You have \(availableCredits) Credits!", message: "Need at least 10, Try Again...", delegate: self, cancelButtonTitle: "Cancel")
            alert.addButtonWithTitle("Use Credit Card")
            alert.dismissWithClickedButtonIndex(alert.firstOtherButtonIndex, animated: true)
            alert.show()
        }
    }
    // MARK: - no credit
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 1 {
            //use credit card
        }
        if buttonIndex == 0 {
            //canceled...show tab bar
            self.tabBarController?.tabBar.hidden = false
        }
    }
    @IBAction func buyBallSkin(sender: UIButton) {
        switch sender.tag {
        case 0: //println(sender.tag)
            checkout("Deduct 10 coins for selected Ball skin?", sender: sender)
        case 1: println(sender.tag)
        case 2: println(sender.tag)
        case 3: println(sender.tag)
        default: break
        }
    }
    func checkout(message: String, sender: UIButton) {
        if NSClassFromString("UIAlertController") != nil {
            let alertController = UIAlertController(title: "Checkout", message: message, preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(title: "Pay now!", style: UIAlertActionStyle.Default, handler: { (action) in
                self.buy(sender)
            }))
            alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: { (action) in
            }))
            presentViewController(alertController, animated: true, completion: nil)
        }
    }
    func buy (sender: UIButton) {
        switch sender.tag {
        case 0: //availableCredits -= 10
            //add selected ball skin to game
            println(sender.tag)
        case 1: println(sender.tag)
        case 2: println(sender.tag)
        case 3: println(sender.tag)
        default: break
        }
    }
    let names = ["8ball",
                "asian",
                "asian33",
                "baseball",
                "basketball",
                "bully72",
                "c14",
                "cd114",
                "cd115",
                "cufi100",
                "dizzy34",
                "happyTennisBall160",
                "r21",
                "ring",
                "soccer",
                "soccer206",
                "star18",
                "star57",
                "sun56",
                "sun94",
                "tennis80",
                "u157",
                "u158",
                "u191",
                "u193",
                "u194",
                "u195",
                "u196",
                "u197",
                "u199",
                "u200",
                "u201",
                "u202",
                "u203",
                "u204",
                "u205",
                "u207"]
    
}