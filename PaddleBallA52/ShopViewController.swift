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
            return (0..<self.paddles.count).map {
                UIImage(named: self.paddles[$0])!
            }
        }
        set { self.pickerDataSource3 = newValue }
    }
    private var pickerDataSource4: [UIImage] { // a computed property instead of func
        get {
            return (0..<self.paddleWidths.count).map {
                UIImage(named: self.paddleWidths[$0])!
            }
        }
        set { self.pickerDataSource4 = newValue }
    }
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int { return 5 } //number of wheels in the picker
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
        return pickerDataSource4.count
    }
    //MARK: - UIPickerViewDelegate
    func pickerView(pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 70.0
    }
    func pickerView(pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return backdropImageView.bounds.width / 5.25
    }
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView!) -> UIView {
        var iv = UIImageView(image: pickerDataSource3[row])  //use worst case(largest) pickerDataSource3 as default
        if component == 0 {
            iv = UIImageView(image: pickerDataSource[row])
            iv.bounds = CGRect(x: 0, y: 0, width: 65, height: 65)
        }
        if component == 1 {
            iv = UIImageView(image: pickerDataSource1[row])
            iv.bounds = CGRect(x: 0, y: 0, width: 65, height: 65)
        }
        if component == 2 {
            iv = UIImageView(image: pickerDataSource2[row])
            iv.bounds = CGRect(x: 0, y: 0, width: 65, height: 65)
        }
        if component == 3 {
            iv.bounds = CGRect(x: 0, y: 0, width: 65, height: 30)
        }
        if component == 4 {
            iv = UIImageView(image: pickerDataSource4[row])
            iv.bounds = CGRect(x: 0, y: 0, width: 65, height: 65)
        }
        return iv
    }
    var selectedBallSkin: UIImage?
    var selectedLogin: String?
    var selectedBallSkin1: UIImage?
    var selectedLogin1: String?
    var selectedAudio2: UIImage?
    var selectedLogin2: String?
    var selectedPaddle3: UIImage?
    var selectedLogin3: String?
    var selectedPaddleWidth4: UIImage?
    var selectedLogin4: String?
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
            selectedPaddle3 = pickerDataSource3[row]
            selectedLogin3 = paddles[row]
        }
        if component == 4 {
            selectedPaddleWidth4 = pickerDataSource4[row]
            selectedLogin4 = paddleWidths[row]
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
    var availableCredits = Settings().availableCredits
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
            availableCredits += 51
            Settings().availableCredits = availableCredits
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
                let loggedInUser = User.login(login, password: "foo") //SWAP ball out to other owned ball
                paddleBallTabBarItem.badgeValue = login
            } else {
                paddleBallTabBarItem.badgeValue = "tennis"
            }
            self.tabBarController!.selectedIndex = 0
        case 2: //println(sender.tag)
            checkout("Deduct 10 coins for selected Audio?", sender: sender)
        case 3: //println(sender.tag)
            checkout("Deduct 10 coins for selected Paddle skin?", sender: sender)
        case 4: //println(sender.tag)
            checkout("Deduct " + String(minimumPWCredits()) + " coins for selected Paddle Width Multipler?", sender: sender)
        default: break
        }
    }
    func minimumPWCredits() -> Int {
        var minimumCredits = 10
        for i in 0..<paddleWidths.count {
            if paddleWidths[i] == self.selectedLogin4! {
                minimumCredits = i * 10
                return minimumCredits
            }
        }
        return 10
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
                    if self.selectedLogin == nil {
                        pickerView(userPickerView, didSelectRow: 0, inComponent: 0)
                    }
                    userPickerView.reloadAllComponents()               //refresh pickerDataSource1
                    let loggedInUser = User.login(self.selectedLogin!, password: "foo") //new ball
                    let paddleBallTabBarItem = tabBarController!.tabBar.items![0] as! UITabBarItem
                    paddleBallTabBarItem.badgeValue = self.selectedLogin!
                    Settings().mySkins.append(self.selectedLogin!)
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
                    let loggedInUser = User.login(self.selectedLogin2!, password: "foo") //new audio
                    let paddleBallTabBarItem = tabBarController!.tabBar.items![0] as! UITabBarItem
                    paddleBallTabBarItem.badgeValue = self.selectedLogin2!
                    for i in 0..<audios.count {
                        if audios[i] == self.selectedLogin2! {
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
                    if self.selectedLogin3 == nil {
                        pickerView(userPickerView, didSelectRow: 0, inComponent: 3)
                    }
                    let loggedInUser = User.login(self.selectedLogin3!, password: "foo") //new Paddle
                    let settingsTabBarItem = tabBarController!.tabBar.items![1] as! UITabBarItem
                    settingsTabBarItem.badgeValue = self.selectedLogin3!
                    for i in 0..<paddles.count {
                        if paddles[i] == self.selectedLogin3! {
                            Settings().myPaddles.append(self.selectedLogin3!)
                        }
                    }
                } else {
                    prepareForPurchase()
                }
                //println(sender.tag)
            case 4: //adjust paddle to selected paddleWidth
                if availableCredits > self.minimumPWCredits() {
                    availableCredits -= self.minimumPWCredits()
                    let shopTabBarItem = tabBarController!.tabBar.items![4] as! UITabBarItem
                    shopTabBarItem.badgeValue = availableCredits.description
                    Settings().availableCredits = availableCredits
                    if self.selectedLogin4 == nil {
                        pickerView(userPickerView, didSelectRow: 1, inComponent: 4) //no zero allowed- use 1 as minimum
                    }
                    let loggedInUser = User.login(self.selectedLogin4!, password: "foo") //new PaddleWidth
                    let settingsTabBarItem = tabBarController!.tabBar.items![1] as! UITabBarItem
                    settingsTabBarItem.badgeValue = self.selectedLogin4!
                    for i in 0..<paddleWidths.count {
                        if paddleWidths[i] == self.selectedLogin4! {
                            Settings().paddleWidthMultiplier = i
                        }
                    }
                } else {
                    prepareForPurchase()
                }
                //println(sender.tag)
            default: break
        }
    }
    let audios = ["audio52",
        "audio66",
        "audio90",
        "audio96",
        "audio125",
        "audio190"]
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
    let paddles = ["asian33",
        "dizzy2",
        "dizzy34",
        "fireball1",
        "fireball2",
        "happy160",
        "r21",
        "ring",
        "starDavid",
        "star18",
        "star57",
        "sun56",
        "sun94",
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
        "u207",
        "trophy75",
        "pointLeft75",
        "no210",
        "sun135",
        "u148",
        "Unknown-28",
        "Unknown-36",
        "Unknown-37",
        "Unknown-38",
        "Unknown-39",
        "Unknown-44",
        "Unknown-76",
        "Unknown-79",
        "Unknown-95",
        "Unknown-104",
        "Unknown-138",
        "Unknown-139",
        "Unknown-141",
        "Unknown-152",
        "Unknown-154",
        "Unknown-173",
        "Unknown-192",
        "Unknown-198",
        "Unknown-219",
        "Unknown-222"]
    let paddleWidths = ["audio52b",
        "audio66b",
        "audio90b",
        "audio96b",
        "audio125b",
        "audio190b"]
}