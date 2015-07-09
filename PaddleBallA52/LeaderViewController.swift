//
//  LeaderViewController.swift
//  PaddleBallA52
//
//  Created by iMac21.5 on 6/18/15.
//  Copyright (c) 2015 Garth MacKenzie. All rights reserved.
//

import UIKit
import AssetsLibrary

class LeaderViewController: UIViewController { //, UIPickerViewDataSource, UIPickerViewDelegate {
 
    @IBOutlet weak var dateCreatedLabel: UILabel!
    @IBOutlet weak var dateCreatedLabel1: UILabel!
    @IBOutlet weak var dateCreatedLabel2: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileButtonImageView: UIButton!
    @IBOutlet weak var profileImageView1: UIImageView!
    @IBOutlet weak var profileImageView2: UIImageView!
    @IBOutlet weak var userIdLabel: UILabel!
    @IBOutlet weak var userIdLabel1: UILabel!
    @IBOutlet weak var userIdLabel2: UILabel!
    @IBOutlet weak var highScoreLabel: UILabel!
    @IBOutlet weak var highScoreLabel1: UILabel!
    @IBOutlet weak var highScoreLabel2: UILabel!
    @IBOutlet weak var leftTrophyImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var rightTrophyImageView: UIImageView!
    @IBOutlet weak var gitImageView: UIImageView!
//    @IBOutlet weak var userPickerView: UIPickerView!
//    //MARK: - UIPickerViewDataSource
//    private var pickerDataSource: [String] { // a computed property instead of func
//        get {
//            var array = [String]()
//            let u0 = self.highScoreLabel.text
//            array.append(u0!)
//            let u1 = self.highScoreLabel1.text
//            array.append(u1!)
//            let u2 = self.highScoreLabel2.text
//            array.append(u2!)
//            return array
//        }
//        set { self.pickerDataSource = newValue }
//    }
//    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int { return 1 } //number of wheels in the picker
//    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//        return pickerDataSource.count
//    }
//    //MARK: - UIPickerViewDelegate
//    func pickerView(titleForRow row: Int, forComponent component: Int) -> String! {
//        return pickerDataSource[row]
//    }
//    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        if profileImageView.tag == row { // 0
//            highScoreLabel.text = pickerDataSource[row] }
//        if profileImageView1.tag == row { // 1
//            highScoreLabel1.text = pickerDataSource[row] }
//        if profileImageView2.tag == row { // 2
//            highScoreLabel2.text = pickerDataSource[row] }
//    }
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        userPickerView.dataSource = self
//        userPickerView.delegate = self
//    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        titleLabel.font = UIFont(name: "ComicSansMS-Bold", size: 36.0)
        addPlayers()
    }
    let formatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.ShortStyle
        formatter.timeStyle = NSDateFormatterStyle.NoStyle
        return formatter
        }()
    let today = NSDate()
    func timestamp(dateCreatedLabel: UILabel?) {
        let timestamp = formatter.stringFromDate(today)
        dateCreatedLabel?.text = timestamp
    }
    private var uid: String { // a computed property instead of func
    get {
        if let login = NSUserDefaults.standardUserDefaults().stringForKey(BallViewController.Constants.UserId) {
            return login
        }
        return "japple"
    }
        set { self.uid = newValue }
    }
    lazy var chosenPlayers: [String] = {
        return [self.uid]
        }()
    func anyUnusedPlayerName() -> String {
        let player = String.randomNickname()
        if !contains(chosenPlayers, player) {
            chosenPlayers.append(player)
        }
        return player
    }
    //MARK: - User is the Model
    func addPlayers() {
        if uid != "japple" && Settings().uid != uid { //player change
            Settings().uid! = uid
            Settings().highScore = 0
            profileImageView!.image = nil
        }
        if let loggedInUser = User.login(uid, password: "foo") { //if uid not valid -> User.login "baddie"
            if profileImageView!.image == nil {
                profileImageView!.image = loggedInUser.image
            }
            userIdLabel.font = UIFont(name: "ComicSansMS-Bold", size: 17.0)
            userIdLabel.text = uid
            if let date1 = formatter.dateFromString(loggedInUser.highScoreDate!) {
                let settingsDate = Settings().highScoreDate!
                if !settingsDate.isEmpty {
                    if let date2 = formatter.dateFromString(Settings().highScoreDate!) {
                        let dateString = formatter.stringFromDate(date1.laterDate(date2))
                        dateCreatedLabel.text = dateString
                    }
                }
                else {
                    dateCreatedLabel.text = formatter.stringFromDate(date1)
                }
            }
            else {
                timestamp(dateCreatedLabel)
            }
            highScoreLabel.text = Settings().highScore.addSeparator
            highScoreLabel.textColor = UIColor.blueColor()
        }
        addPlayer1(anyUnusedPlayerName())
        addPlayer2(anyUnusedPlayerName())
    }
    func addPlayer1(uid1: String) {
        if let user1 = User.login("soccer", password: "foo") {
            profileImageView1!.image = UIImage(named: String.randomBall())
            userIdLabel1.text = uid1
//            if let date = user1.highScoreDate {
//                dateCreatedLabel1?.text = date
//            } else {
//                dateCreatedLabel1.text = formatter.stringFromDate(date)
//            }
            dateCreatedLabel1.text = formatter.stringFromDate(today)
            highScoreLabel1.text = Int.random(100000).addSeparator  //user1.highScore
            highScoreLabel1.textColor = UIColor.blueColor()
        }
    }
    func addPlayer2(uid2: String) {
        if let user2 = User.login("madbum", password: "foo") {
//            if profileImageView2!.image == nil {
//                profileImageView2!.image = user2.image
//            }
            profileImageView2!.image = UIImage(named: String.randomBall())
            userIdLabel2.text = uid2
//            if let date = user2.highScoreDate {
//                dateCreatedLabel2?.text = date
//            } else {
//                //timestamp(dateCreatedLabel2)
//                dateCreatedLabel2.text = formatter.stringFromDate(date)
//            }
            dateCreatedLabel2.text = formatter.stringFromDate(today.dateByAddingTimeInterval(-60*60*24))
            highScoreLabel2.text = Int.random(100000).addSeparator  //user2.highScore
            highScoreLabel2.textColor = UIColor.blueColor()
        }
    }
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let buttonImageView = (sender as? UIButton)?.imageView {
            if segue.identifier == BallViewController.Constants.EditImageSegue {
                if let ivc = segue.destinationViewController.contentViewController as? ImageViewController {
                    //prepare
                    if buttonImageView.tag == 0 {
                        ivc.tag = 0
                    }
                    if buttonImageView.tag == 1 {
                        ivc.tag = 1
                    }

                    if buttonImageView.tag == 2 {
                        ivc.tag = 2
                    }
                }
            }
        }
    }
    @IBAction func unwindFromModalViewController(segue: UIStoryboardSegue) {
        if segue.sourceViewController.tag == 0 {
            if let iv = segue.sourceViewController.imageView {
                if iv?.image != nil {
                    profileImageView!.image = iv!.image
                }
            }
        }
    }
}

// User can't itself have anything UI-related
// but we can add a private UI-specific property
private extension User {
    var image: UIImage? {
        if let image = UIImage(named: login) {
            return image
        } else {
            return UIImage(named: "tennis")!
        }
    }
}

extension UIViewController {
    var contentViewController: UIViewController {
        if let navCon = self as? UINavigationController {
            return navCon.visibleViewController
        } else {
            return self
        }
    }
}

private extension Int {
    var addSeparator: String {
        let nf = NSNumberFormatter()
        nf.groupingSeparator = ","
        nf.numberStyle = NSNumberFormatterStyle.DecimalStyle
        return nf.stringFromNumber(self)!
    }
    static func random(max: Int) -> Int {
        return Int(arc4random() % UInt32(max))
    }
}

private extension String {
    static func randomNickname() -> String {
    let names = ["Spud",
    "The Little General",
    "The Great Bambino",
    "Boom-Dizzle",
    "Big Ben",
    "The Executioner",
    "Dollar Bill",
    "The General",
    "Big Country",
    "Pudge",
    "Cadillac",
    "Big Daddy",
    "The Glide",
    "Coco",
    "Speedy",
    "The Intimidator",
    "Thunder",
    "Mookie",
    "Moose",
    "Big Papi",
    "The Admiral",
    "Brick",
    "Neon",
    "Oil Can",
    "The Worm",
    "Mr November",
    "Action Jackson",
    "Deuce",
    "Doc",
    "Flash",
    "The Pearl",
    "Magic",
    "Too Tall",
    "Duke of Flatbush",
    "Tiger",
    "The Real Deal",
    "The Bull",
    "One Size",
    "Crime Dog",
    "Fred-Ex",
    "The Glove",
    "King George",
    "Iceman",
    "The Hibachi",
    "Big Baby",
    "Big Dog",
    "Mad Dog",
    "The Shark",
    "The Dream",
    "Baby Jordan",
    "Pee Wee",
    "Macho",
    "The Flying Dutchman",
    "Flash",
    "The Hitman",
    "Tmac",
    "Pronk",
    "Vinsanity",
    "The Microwave",
    "Clyde",
    "The Great One",
    "Tree",
    "The Thrill",
    "Flipper",
    "The Say Hey Kid",
    "Strech",
    "Fast",
    "The Stilt",
    "Bad Moon"]
    let randomIndex = Int(arc4random_uniform(UInt32(names.count)))
    return names[randomIndex]
    }
    static func randomBall() -> String {
        let names2 = ["8ball",
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
        let randomIndex = Int(arc4random_uniform(UInt32(names2.count)))
        return names2[randomIndex]
    }

}