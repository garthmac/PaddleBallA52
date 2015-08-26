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
    //MARK: - UIPickerViewDataSource
    private var pickerDataSource: [UIImage] { // a computed property instead of func
        get {
            return (0..<self.ballSkins.count).map {
                UIImage(named: self.ballSkins[$0])!
            }
        }
        set { self.pickerDataSource = newValue }
    }
    private var pickerDataSource1: [UIImage] { // a computed property instead of func
        get {
            return (0..<Settings().mySkins.count).map {
                UIImage(named: Settings().mySkins[$0])!
            }
        }
        set { self.pickerDataSource1 = newValue }
    }
    private var pickerDataSource2: [UIImage] { // a computed property instead of func
        get {
            return (0..<self.audios.count).map {
                UIImage(named: self.audios[$0])!
            }
        }
        set { self.pickerDataSource2 = newValue }
    }
    private var pickerDataSource3: [UIImage] { // a computed property instead of func
        get {
            return (0..<self.ballSkins.count).map {
                UIImage(named: self.ballSkins[$0])!
            }
        }
        set { self.pickerDataSource3 = newValue }
    }

    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int { return 4 } //number of wheels in the picker
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return pickerDataSource.count
        }
        if component == 1 {
            return pickerDataSource1.count
        }
        if component == 2 {
            return pickerDataSource2.count
        }
        if component == 3 {
            return pickerDataSource3.count
        }
        return pickerDataSource.count
    }
    //MARK: - UIPickerViewDelegate
    func pickerView(pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 75.0
    }
    func pickerView(pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return backdropImageView.bounds.width / 4.1
    }
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView!) -> UIView {
        var iv = UIImageView(image: pickerDataSource[row])
        if component == 1 {
            iv = UIImageView(image: pickerDataSource1[row])
        }
        if component == 2 {
            iv = UIImageView(image: pickerDataSource2[row])
        }
        if component == 3 {
            iv = UIImageView(image: pickerDataSource3[row])
        }
        iv.bounds = CGRect(x: 0, y: 0, width: 80, height: 80)
        return iv
    }
    var selectedBallSkin: UIImage?
    var selectedLogin: String?
    var selectedBallSkin1: UIImage?
    var selectedLogin1: String?
    var selectedAudio2: UIImage?
    var selectedLogin2: String?
    var selectedAudio3: UIImage?
    var selectedLogin3: String?
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            selectedBallSkin = pickerDataSource[row]
            selectedLogin = ballSkins[row]
        }
        if component == 1 {
            selectedBallSkin1 = pickerDataSource1[row]
            selectedLogin1 = Settings().mySkins[row]
        }
        if component == 2 {
            selectedAudio2 = pickerDataSource2[row]
            selectedLogin2 = audios[row]
        }
        if component == 3 {
            selectedAudio3 = pickerDataSource3[row]
            selectedLogin3 = ballSkins[row]  //Settings().myAudios[row]
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.font = UIFont(name: "ComicSansMS-Bold", size: 28.0)
        userPickerView.dataSource = self
        userPickerView.delegate = self
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        prepareForPurchase()
    }
    var availableCredits = 0
    func prepareForPurchase() {
        self.tabBarController?.tabBar.hidden = false
        let shopTabBarItem = tabBarController!.tabBar.items![4] as! UITabBarItem
        if let ac = shopTabBarItem.badgeValue {
            if ac.toInt()! > 0 { //everything costs 10 credits or $1
                availableCredits = ac.toInt()!
            }
        }
        if availableCredits < 10 {
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
            availableCredits += 11
            (tabBarController!.tabBar.items![4] as! UITabBarItem).badgeValue = String(availableCredits)
            prepareForPurchase()
        }
        if buttonIndex == 0 {
            //canceled...show tab bar
            self.tabBarController?.tabBar.hidden = false
        }
    }
    @IBAction func buySelection(sender: UIButton) {
        switch sender.tag {
        case 0: //println(sender.tag)
            checkout("Deduct 10 coins for selected Ball skin?", sender: sender)
        case 1: //println(sender.tag)
            let paddleBallTabBarItem = tabBarController!.tabBar.items![0] as! UITabBarItem
            if let login = self.selectedLogin1 {
                let loggedInUser = User.login(login, password: "foo") //swap ball
                paddleBallTabBarItem.badgeValue = login
            } else {
                paddleBallTabBarItem.badgeValue = "tennis"
            }
        case 2: //println(sender.tag)
            checkout("Deduct 10 coins for selected Audio?", sender: sender)
        case 3: //println(sender.tag)
            checkout("Deduct 10 coins for selected Paddle?", sender: sender)
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
    func buy(sender: UIButton) {
        switch sender.tag {
            case 0: //add selected ball skin to game
                if availableCredits > 9 {
                    availableCredits -= 10
                    let shopTabBarItem = tabBarController!.tabBar.items![4] as! UITabBarItem
                    shopTabBarItem.badgeValue = availableCredits.description
                    Settings().availableCredits = availableCredits
                    Settings().mySkins.append(self.selectedLogin!)
                    userPickerView.reloadAllComponents() //refresh pickerDataSource1
                    let loggedInUser = User.login(self.selectedLogin!, password: "foo") //new ball
                    let paddleBallTabBarItem = tabBarController!.tabBar.items![0] as! UITabBarItem
                    paddleBallTabBarItem.badgeValue = self.selectedLogin!
                } else {
                    prepareForPurchase()
                }
                //println(sender.tag)
            case 1: println(sender.tag)
            case 2: //add selected sound track to game
                if availableCredits > 9 {
                    availableCredits -= 10
                    let shopTabBarItem = tabBarController!.tabBar.items![4] as! UITabBarItem
                    shopTabBarItem.badgeValue = availableCredits.description
                    Settings().availableCredits = availableCredits
                    userPickerView.reloadAllComponents() //refresh pickerDataSource3
                    let loggedInUser = User.login(self.selectedLogin2!, password: "foo") //new audio
                    let paddleBallTabBarItem = tabBarController!.tabBar.items![0] as! UITabBarItem
                    paddleBallTabBarItem.badgeValue = self.selectedLogin2!
                    for i in 0..<ShopViewController().audios.count {
                        if ShopViewController().audios[i] == self.selectedLogin2! {
                            Settings().soundChoice = i
                            Settings().myAudios.append(self.selectedLogin2!)
                        }
                    }
                } else {
                    prepareForPurchase()
                }
                //println(sender.tag)
            case 3: //add selected paddle to game
                if availableCredits > 9 {
                    availableCredits -= 10
                    let shopTabBarItem = tabBarController!.tabBar.items![4] as! UITabBarItem
                    shopTabBarItem.badgeValue = availableCredits.description
                    Settings().availableCredits = availableCredits
                    Settings().myPaddles.append(self.selectedLogin3!)
//                    userPickerView.reloadAllComponents() //refresh pickerDataSource1
//                    let loggedInUser = User.login(self.selectedLogin3!, password: "foo") //new ball
//                    let paddleBallTabBarItem = tabBarController!.tabBar.items![0] as! UITabBarItem
//                    paddleBallTabBarItem.badgeValue = self.selectedLogin3!
                } else {
                    prepareForPurchase()
                }
                //println(sender.tag)
            default: break
        }
    }
    let ballSkins = ["8ball",
                "asian",
                "asian33",
                "baseball",
                "basketball",
                "bully72",
                "c14",
                "cd114",
                "cd115",
                "cufi100",
                "dizzy2",
                "dizzy34",
                "fireball1",
                "fireball2",
                "happy160",
                "r21",
                "ring",
                "soccer",
                "soccer206",
                "starDavid",
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
    let audios = ["audio52",
                "audio66",
                "audio90",
                "audio96",
                "audio125",
                "audio190"]

}