//
//  Settings.swift
//  PaddleBallA5
//
//  Created by iMac21.5 on 5/30/15.
//  Copyright (c) 2015 Garth MacKenzie. All rights reserved.
//

import Foundation

class Settings {
    
    struct Const {
        static let AudiosKey = "Settings.Audios" //purchased sound tracks
        static let AchievedKey = "Settings.Binary" //tracks user achieved (earned or bought with In-App purchase) extra balls, audio tracks, balls skins, emojis, redBlock-off, poping targets
        static let AutoStartKey = "Settings.Auto.Start" //allow balls to appear without user interaction:
        static let AvailableCreditsKey = "Settings.Available" //
        static let BallColorKey = "Settings.Ball.Color"
        static let BallRotationKey = "Settings.Ball.Rotation" //allow balls to rotate when they encounter friction:
        static let BallsKey = "Settings.Balls" //allows to add multiple balls:
        static let ChangeKey = "Settings.Change.Indicator" //if the settings have been changed:
        static let ColumnsKey = "Settings.Columns"
        static let CourtColorKey = "Settings.Court.Color"
        static let DifficultyKey = "Settings.Difficulty" //chooses if the last row of bricks should be “black” and thus need two collisions to be destroyed:
        static let EndLevelBonusKey = "Settings.End.Level.Bonus" //awarded for each 10,000 points earned
        static let HighScoreKey = "Settings.High.Score"
        static let HighScoreDateKey = "Settings.High.Score.Date"
        static let HighScoreOnKey = "Settings.High.Score.On" //toggle to reset high score to zero
        static let HintIndexKey = "Settings.Hint.Index"
        static let PaddleColorKey = "Settings.Paddle.Color"
        static let PaddlesKey = "Settings.Paddles" //purchased Paddles
        static let PaddleWidthMultiplierKey = "Settings.Paddle.Width.Multiplier" //1 thru 4, initially 2 (ball widths)
        static let PaddleWidthUnlockStepperKey = "Settings.Paddle.Width.Unlock.Stepper" //enable stepper once u purchace max paddle width
        static let PurchasedPWMKey = "Settings.Purchased.PWM"
        static let PurchasedUidKey = "Settings.Purchased.Ball.Uid"
        static let RedBlockKey = "Settings.RedBlock" //turn that annoying RedBlock off!
        static let RowsKey = "Settings.Rows" //half the # of columns
        static let SkinsKey = "Settings.Skins" //purchased ball skins
        static let SoundKey = "Settings.Sound" // on/off
        static let SoundChoiceKey = "Settings.SoundChoice" // 0/1/2/3/4/5
        static let SpeedKey = "Settings.Ball.Speed" //control the speed of the ball/push:
        static let TierKey = "Settings.Level"
        static let UserIdKey = "Settings.User.Id"
    }
    let defaults = NSUserDefaults.standardUserDefaults()
//    var achieved: String {
//        get { return defaults.objectForKey(Const.AchievedKey) as? String ?? "00000000" } //02.. tracks tested and enabled in svc...AchievedKey -tracks user achieved (earned or bought with In-App purchase) (1)extra balls, (2)audio tracks, (3)ball skins, (4)emojis, (5)redBlock-off, (6)poping targets
//        set { defaults.setObject(newValue, forKey: Const.AchievedKey) }
//    }
    var autoStart: Bool {
        get { return defaults.objectForKey(Const.AutoStartKey) as? Bool ?? false }
        set { defaults.setObject(newValue, forKey: Const.AutoStartKey) }
    }
    var availableCredits: Int {
        get { return defaults.objectForKey(Const.AvailableCreditsKey) as? Int ?? 5 }
        set { defaults.setObject(newValue, forKey: Const.AvailableCreditsKey) }
    }
    var ballColor: String {
        get { return defaults.objectForKey(Const.BallColorKey) as? String ?? "Yellow" }
        set { defaults.setObject(newValue, forKey: Const.BallColorKey) }
    }
    var ballRotation: Bool {
        get { return defaults.objectForKey(Const.BallRotationKey) as? Bool ?? true }
        set { defaults.setObject(newValue, forKey: Const.BallRotationKey) }
    }
    var balls: Int {
        get { return defaults.objectForKey(Const.BallsKey) as? Int ?? 1 }
        set { defaults.setObject(newValue, forKey: Const.BallsKey) }
    }
    var columns: Int {
        get { return defaults.objectForKey(Const.ColumnsKey) as? Int ?? 4 }
        set { defaults.setObject(newValue, forKey: Const.ColumnsKey) }
    }
    var courtColor: String {
        get { return defaults.objectForKey(Const.CourtColorKey) as? String ?? "Clear" }
        set { defaults.setObject(newValue, forKey: Const.CourtColorKey) }
    }
    var difficulty: Int {
        get { return defaults.objectForKey(Const.DifficultyKey) as? Int ?? 1 }
        set { defaults.setObject(newValue, forKey: Const.DifficultyKey) }
    }
    var endLevelBonus: Int {
        get { return defaults.objectForKey(Const.EndLevelBonusKey) as? Int ?? 0 }
        set { defaults.setObject(newValue, forKey: Const.EndLevelBonusKey) }
    }
    var highScore: Int {
        get { return defaults.objectForKey(Const.HighScoreKey) as? Int ?? 0 }
        set { defaults.setObject(newValue, forKey: Const.HighScoreKey) }
    }
    var highScoreDate: String? {
        get { return defaults.objectForKey(Const.HighScoreDateKey) as? String ?? "" }
        set { defaults.setObject(newValue, forKey: Const.HighScoreDateKey) }
    }
    var highScoreOn: Bool {
        get { return defaults.objectForKey(Const.HighScoreOnKey) as? Bool ?? true }
        set { defaults.setObject(newValue, forKey: Const.HighScoreOnKey) }
    }
    var lastHint: Int {
        get { return defaults.objectForKey(Const.HintIndexKey) as? Int ?? 0 }
        set { defaults.setObject(newValue, forKey: Const.HintIndexKey) }
    }
    var myAudios: [String] {
        get { return defaults.objectForKey(Const.AudiosKey) as? [String] ?? ["audio77"]}
        set { defaults.setObject(newValue, forKey: Const.AudiosKey) }
    }
    var myPaddles: [String] {
        get { return defaults.objectForKey(Const.PaddlesKey) as? [String] ?? ["dizzy2"]}
        set { defaults.setObject(newValue, forKey: Const.PaddlesKey) }
    }
    var mySkins: [String] {
        get { return defaults.objectForKey(Const.SkinsKey) as? [String] ?? ["tennis"]}
        set { defaults.setObject(newValue, forKey: Const.SkinsKey) }
    }
    var paddleColor: String {
        get { return defaults.objectForKey(Const.PaddleColorKey) as? String ?? "Green" }
        set { defaults.setObject(newValue, forKey: Const.PaddleColorKey) }
    }
    var paddleWidthMultiplier: Int {
        get { return defaults.objectForKey(Const.PaddleWidthMultiplierKey) as? Int ?? 2 }
        set { defaults.setObject(newValue, forKey: Const.PaddleWidthMultiplierKey) }
    }
    var paddleWidthUnlockStepper: Bool {
        get { return defaults.objectForKey(Const.PaddleWidthUnlockStepperKey) as? Bool ?? false }
        set { defaults.setObject(newValue, forKey: Const.PaddleWidthUnlockStepperKey) }
    }
    var purchasedPWM: Int {
        get { return defaults.objectForKey(Const.PurchasedPWMKey) as? Int ?? 2 }
        set { defaults.setObject(newValue, forKey: Const.PurchasedPWMKey) }
    }
    var purchasedUid: String? {
        get { return defaults.objectForKey(Const.PurchasedUidKey) as? String ?? "" }
        set { defaults.setObject(newValue, forKey: Const.PurchasedUidKey) }
    }
    var rows: Int {
        get { return defaults.objectForKey(Const.RowsKey) as? Int ?? 2 }
        set { defaults.setObject(newValue, forKey: Const.RowsKey) }
    }
    var redBlockOn: Bool {
        get { return defaults.objectForKey(Const.RedBlockKey) as? Bool ?? true }
        set { defaults.setObject(newValue, forKey: Const.RedBlockKey) }
    }
    var soundChoice: Int {
        get { return defaults.objectForKey(Const.SoundChoiceKey) as? Int ?? 0 }
        set { defaults.setObject(newValue, forKey: Const.SoundChoiceKey) }
    }
    var soundOn: Bool {
        get { return defaults.objectForKey(Const.SoundKey) as? Bool ?? true }
        set { defaults.setObject(newValue, forKey: Const.SoundKey) }
    }
    var speed: Float {
        get { return defaults.objectForKey(Const.SpeedKey) as? Float ?? 1.0 }
        set { defaults.setObject(newValue, forKey: Const.SpeedKey) }
    }
    var tier: Int {
        get { return defaults.objectForKey(Const.TierKey) as? Int ?? 1 }
        set { defaults.setObject(newValue, forKey: Const.TierKey) }
    }
    var uid: String? {
        get { return defaults.objectForKey(Const.UserIdKey) as? String ?? "" }
        set { defaults.setObject(newValue, forKey: Const.UserIdKey) }
    }
    var changed: Bool {
        get { return defaults.objectForKey(Const.ChangeKey) as? Bool ?? false }
        set {
            defaults.setObject(newValue, forKey: Const.ChangeKey)
            defaults.synchronize()
        }
    }
    //Instead of the optional variables I could have added the default values in this new class. But there are already a number of “default” values in the view controller, and I did not want to spread them to different parts of the code. Instead I added a convenience initializer to provide default values to the settings class:
    convenience init(defaultColumns: Int, defaultRows: Int, defaultBalls: Int, defaultDifficulty: Int, defaultSpeed: Float, defaultBallColor: String, defaultCourtColor: String, defaultPaddleColor: String, defaultPaddleWidthMultiplier: Int, defaultTier: Int) {
        self.init()
        columns = defaultColumns
        rows = defaultRows
        balls = defaultBalls
        difficulty = defaultDifficulty
        speed = defaultSpeed
        ballColor = defaultBallColor
        courtColor = defaultCourtColor
        paddleColor = defaultPaddleColor
        paddleWidthMultiplier = defaultPaddleWidthMultiplier
        tier = defaultTier
    }
    
}
