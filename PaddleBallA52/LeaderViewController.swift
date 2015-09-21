//
//  LeaderViewController.swift
//  PaddleBallA52
//
//  Created by iMac21.5 on 6/18/15.
//  Copyright (c) 2015 Garth MacKenzie. All rights reserved.
//

import UIKit
import AssetsLibrary
import GameKit

class LeaderViewController: UIViewController, GKGameCenterControllerDelegate {
    // Game Center
    let gameCenterPlayer=GKLocalPlayer.localPlayer()
    var canUseGameCenter:Bool = false {
        didSet {
            if canUseGameCenter == true {// load prev. achievments form Game Center
                gameCenterLoadAchievements()
            }
        }
    }
    var gameCenterAchievements=[String:GKAchievement]() //dictionary...send high score to leaderboard
    // MARK: Game Center
    // load prev achievement granted to the player
    func gameCenterLoadAchievements(){
        // load all prev. achievements for GameCenter for the user so progress can be added
        GKAchievement.loadAchievementsWithCompletionHandler( { [weak self] (allAchievements, error) -> Void in
            if error != nil {
                print("Game Center: could not load achievements, error: \(error)")
            } else {
                for anAchievement in allAchievements!  {
                    let oneAchievement = anAchievement
                    self!.gameCenterAchievements[oneAchievement.identifier!]=oneAchievement
                }
            }
        })
    }
    // add progress to an achievement
    func gameCenterAddProgressToAnAchievement(progress:Double, achievementID:String) {
        if canUseGameCenter == true { // only update progress if user opt-in to use Game Center
            // lookup if prev progress is logged for this achievement = achievement is already known (and loaded) from Game Center for this user
            let lookupAchievement:GKAchievement? = gameCenterAchievements[achievementID]
            if let achievement = lookupAchievement {
                // found the achievement with the given achievementID, check if it already 100% done
                if achievement.percentComplete != 100 {
                    // set new progress
                    achievement.percentComplete = progress
                    if progress == 100.0  { achievement.showsCompletionBanner=true }  // show banner only if achievement is fully granted (progress is 100%)
                    // try to report the progress to the Game Center
                    GKAchievement.reportAchievements([achievement], withCompletionHandler: { (error) -> Void in
                        if error != nil {
                            print("Couldn't save achievement (\(achievementID)) progress to \(progress) %")
                        }
                    })
                }
                else {// achievemnt already granted, nothing to do
                    print("DEBUG: Achievement (\(achievementID)) already granted")
                }
            } else { // never added  progress for this achievement, create achievement now, recall to add progress
                print("No achievement with ID (\(achievementID)) was found, no progress for this one was recoreded yet. Create achievement now.")
                gameCenterAchievements[achievementID] = GKAchievement(identifier: achievementID)
                // recursive recall this func now that the achievement exist
                gameCenterAddProgressToAnAchievement(progress, achievementID: achievementID)
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        for aView in view.subviews {
            if let button = aView as? UIButton {
                for i in [0, 3] {
                    if i == button.tag {
                        button.layer.cornerRadius = 15.0
                        button.layer.borderWidth = 1.0
                        button.layer.borderColor = UIColor.blueColor().CGColor
                    }
                }
            }
        }
        // Do any additional setup after loading the view.
        gameCenterPlayer.authenticateHandler = { (gameCenterVC:UIViewController?, gameCenterError) -> Void in
            if gameCenterVC != nil {
                self.presentViewController(gameCenterVC!, animated: true, completion: { () -> Void in
                })
            }
            else if self.gameCenterPlayer.authenticated == true {
                self.canUseGameCenter = true
            } else  {
                self.canUseGameCenter = false
            }
            if gameCenterError != nil {
                print("Game Center error: \(gameCenterError)")
            }
        }
    }
    func saveHighscore(score: Int) {
        //check if user is signed in
        if gameCenterPlayer.authenticated {
            let scoreReporter = GKScore(leaderboardIdentifier: "com.garthmackenzie.PaddleBallA52.leaderboard1") //leaderboard id here
            scoreReporter.value = Int64(score)
            let scoreArray: [GKScore] = [scoreReporter]
            GKScore.reportScores(scoreArray, withCompletionHandler: { [weak self] (error) -> Void in
                if error != nil {
                    print("error posting scoreArray to Game Center")
                } else {
                    self!.showLeader()
                }
            })
        }
    }
    //shows leaderboard screen
    func showLeader() {
        let vc = self.view?.window?.rootViewController
        let gc = GKGameCenterViewController()
        gc.gameCenterDelegate = self
        vc!.presentViewController(gc, animated: true, completion: nil)
    }
    //hides leaderboard screen
    func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func gameCenter(sender: UIButton) {
        saveHighscore(Settings().highScore)  //showLeader()
        if canUseGameCenter {
            gameCenterLoadAchievements()
            var percent = (Double(Settings().highScore) / 100000.0)
            print(percent)
            gameCenterAddProgressToAnAchievement(percent, achievementID: "com.garthmackenzie.PaddleBallA52.100kPoints")
            percent = (Double(Settings().highScore) / 200000.0)
            gameCenterAddProgressToAnAchievement(percent, achievementID: "com.garthmackenzie.PaddleBallA52.200kPoints")
            percent = (Double(Settings().highScore) / 300000.0)
            gameCenterAddProgressToAnAchievement(percent, achievementID: "com.garthmackenzie.PaddleBallA52.300kPoints")
            percent = (Double(Settings().highScore) / 400000.0)
            gameCenterAddProgressToAnAchievement(percent, achievementID: "com.garthmackenzie.PaddleBallA52.400kPoints")
            percent = (Double(Settings().highScore) / 500000.0)
            gameCenterAddProgressToAnAchievement(percent, achievementID: "com.garthmackenzie.PaddleBallA52.500kPoints")
            percent = (Double(Settings().highScore) / 1000000.0)
            gameCenterAddProgressToAnAchievement(percent, achievementID: "com.garthmackenzie.PaddleBallA52.999kPoints")
            percent = (Double(Settings().tier) / 30.0)
            gameCenterAddProgressToAnAchievement(percent, achievementID: "com.garthmackenzie.PaddleBallA52.level.30")
            percent = (Double(Settings().tier) / 60.0)
            gameCenterAddProgressToAnAchievement(percent, achievementID: "com.garthmackenzie.PaddleBallA52.level.60")
        }
    }
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

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
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
        if !chosenPlayers.contains(player) {
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
        let loggedInUser = User.login(uid, password: "foo")  //if uid not valid -> User.login "baddie"
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
        addPlayer1(anyUnusedPlayerName())
        addPlayer2(anyUnusedPlayerName())
    }
    func addPlayer1(uid1: String) {
        let user1 = User.login("soccer", password: "foo")
        print(user1)
        profileImageView1!.image = UIImage(named: String.randomBall())
        userIdLabel1.text = uid1
        dateCreatedLabel1.text = formatter.stringFromDate(today)
        highScoreLabel1.text = Int.random(100000).addSeparator  //user1.highScore
        highScoreLabel1.textColor = UIColor.blueColor()
    }
    func addPlayer2(uid2: String) {
        let user2 = User.login("madbum", password: "foo")
        print(user2)
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
        if let ivc = segue.sourceViewController as? ImageViewController {
            profileImageView!.image = ivc.image
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
            return navCon.visibleViewController!
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
            "u207"]
        let randomIndex = Int(arc4random_uniform(UInt32(names2.count)))
        return names2[randomIndex]
    }

}