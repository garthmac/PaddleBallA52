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
        static let AutoStartKey = "Settings.Auto.Start" //allow balls to appear without user interaction:
        static let BallColorKey = "Settings.Ball.Color"
        static let BallRotationKey = "Settings.Ball.Rotation" //allow balls to rotate when they encounter friction:
        static let BallsKey = "Settings.Balls" //allows to add multiple balls:
        static let ChangeKey = "Settings.Change.Indicator" //if the settings have been changed:
        static let ColumnsKey = "Settings.Columns"
        static let CornerRadiusKey = "Settings.Corner.Radius" //allow brick corner radius adjustment:
        static let CourtColorKey = "Settings.Court.Color"
        static let DifficultyKey = "Settings.Difficulty" //chooses if the last row of bricks should be “black” and thus need two collisions to be destroyed:
        static let HighScoreKey = "Settings.High.Score"
        static let HighScoreDateKey = "Settings.High.Score.Date"
        static let HighScoreOnKey = "Settings.High.Score.On" //toggle to reset high score to zero
        static let PaddleColorKey = "Settings.Paddle.Color"
        static let PaddleWidthMultiplierKey = "Settings.Paddle.Width.Multiplier" //1 thru 4, initially 2 (ball widths)
        static let RowsKey = "Settings.Rows" //half the # of columns
        static let SoundKey = "Settings.Sound" //allow balls make a sound on collision:
        static let SpeedKey = "Settings.Ball.Speed" //control the speed of the ball/push:
    }
    let defaults = NSUserDefaults.standardUserDefaults()
    var autoStart: Bool {
        get { return defaults.objectForKey(Const.AutoStartKey) as? Bool ?? false }
        set { defaults.setObject(newValue, forKey: Const.AutoStartKey) }
    }
    var ballColor: String {
        get { return defaults.objectForKey(Const.BallColorKey) as? String ?? "Yellow" }
        set { defaults.setObject(newValue, forKey: Const.BallColorKey) }
    }
    var ballRotation: Bool {
        get { return defaults.objectForKey(Const.BallRotationKey) as? Bool ?? true }
        set { defaults.setObject(newValue, forKey: Const.BallRotationKey) }
    }
    var balls: Int? {
        get { return defaults.objectForKey(Const.BallsKey) as? Int }
        set { defaults.setObject(newValue, forKey: Const.BallsKey) }
    }
    var columns: Int? {
        get { return defaults.objectForKey(Const.ColumnsKey) as? Int }
        set { defaults.setObject(newValue, forKey: Const.ColumnsKey) }
    }
    var cornerRadius: Float? {
        get { return defaults.objectForKey(Const.CornerRadiusKey) as? Float }
        set { defaults.setObject(newValue, forKey: Const.CornerRadiusKey) }
    }
    var courtColor: String {
        get { return defaults.objectForKey(Const.CourtColorKey) as? String ?? "Purple" }
        set { defaults.setObject(newValue, forKey: Const.CourtColorKey) }
    }
    var difficulty: Int? {
        get { return defaults.objectForKey(Const.DifficultyKey) as? Int }
        set { defaults.setObject(newValue, forKey: Const.DifficultyKey) }
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
    var soundOn: Bool {
        get { return defaults.objectForKey(Const.SoundKey) as? Bool ?? true }
        set { defaults.setObject(newValue, forKey: Const.SoundKey) }
    }
    var speed: Float? {
        get { return defaults.objectForKey(Const.SpeedKey) as? Float ?? 1.0 }
        set { defaults.setObject(newValue, forKey: Const.SpeedKey) }
    }
    var paddleColor: String {
        get { return defaults.objectForKey(Const.PaddleColorKey) as? String ?? "Cyan" }
        set { defaults.setObject(newValue, forKey: Const.PaddleColorKey) }
    }
    var paddleWidthMultiplier: Int? {
        get { return defaults.objectForKey(Const.PaddleWidthMultiplierKey) as? Int }
        set { defaults.setObject(newValue, forKey: Const.PaddleWidthMultiplierKey) }
    }
    var rows: Int? {
        get { return defaults.objectForKey(Const.RowsKey) as? Int }
        set { defaults.setObject(newValue, forKey: Const.RowsKey) }
    }
    var changed: Bool {
        get { return defaults.objectForKey(Const.ChangeKey) as? Bool ?? false }
        set {
            defaults.setObject(newValue, forKey: Const.ChangeKey)
            defaults.synchronize()
        }
    }
    //Instead of the optional variables I could have added the default values in this new class. But there are already a number of “default” values in the view controller, and I did not want to spread them to different parts of the code. Instead I added a convenience initializer to provide default values to the settings class:
    convenience init(defaultColumns: Int, defaultRows: Int, defaultBalls: Int, defaultDifficulty: Int, defaultSpeed: Float, defaultBallColor: String, defaultCourtColor: String, defaultPaddleColor: String, defaultPaddleWidthMultiplier: Int, defaultBrickCornerRadius: Float) {
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
        cornerRadius = defaultBrickCornerRadius
    }
    
}
