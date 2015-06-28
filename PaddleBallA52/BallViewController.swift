//
//  BallViewController.swift
//  BallA5
//
//  Created by iMac21.5 on 5/24/15.
//  Copyright (c) 2015 Garth MacKenzie. All rights reserved.
//

import UIKit
import AVFoundation

class BallViewController: UIViewController, UICollisionBehaviorDelegate, AVAudioPlayerDelegate {

    @IBOutlet weak var gameView: UIView!
    private var breakout = BreakoutBehavior()
    private var cornerRadius = Constants.BrickCornerRadius
    // MARK: - scoring
    private var tier: Int = 1
    private var msg: String { // a computed property instead of func
        get {
            if self.newHighScoreAchieved {
                Settings().highScore = self.score
                return "#\(self.tier)  New High Score!    "
            }
            return "#\(self.tier)    "
        }
        set { self.msg = newValue }
    }
    private var score: Int = 0
    private var newHighScoreAchieved: Bool { // a computed property instead of func
        get {
            if Settings().highScoreOn {
                return Settings().highScore < self.score
            }
            return self.score > 1000 //for little kids
        }
        set { self.newHighScoreAchieved = newValue }
    }
    lazy var scoreBoard: UILabel = { let scoreBoard = UILabel(frame: CGRect(origin: CGPoint(x: -1 , y: -1), size: CGSize(width: min(self.gameView.frame.width, self.gameView.frame.height), height: 30.0)))
        scoreBoard.font = UIFont(name: "ComicSansMS-Bold", size: 18.0)
        scoreBoard.textAlignment = NSTextAlignment.Center
        return scoreBoard
        }()
    lazy var powerBallScoreBoard: UILabel = { let scoreBoard = UILabel(frame: CGRect(origin: CGPoint(x: -1 , y: -1), size: CGSize(width: min(self.gameView.frame.width, self.gameView.frame.height), height: 40.0)))
        scoreBoard.font = UIFont(name: "ComicSansMS-Bold", size: 30.0)
        scoreBoard.textAlignment = NSTextAlignment.Center
        return scoreBoard
        }()
    lazy var animator: UIDynamicAnimator = { UIDynamicAnimator(referenceView: self.gameView) }()
    var paddleWidthMultiplier = 2
    var paddleSize = Constants.PaddleSize
    
    //To start balls automatically, add a timer which periodically checks, if there is a ball (or the maximum number of balls) and push them if necessary.
    private var autoStartTimer: NSTimer?
    private var audioPlayer: AVAudioPlayer!
    func prepareAudios() {
        let path = NSBundle.mainBundle().pathForResource("jazzloop2_70", ofType: "mp3")
        let url = NSURL.fileURLWithPath(path!)
        audioPlayer = AVAudioPlayer(contentsOfURL: url, error: nil)
        audioPlayer.delegate = self
        audioPlayer.numberOfLoops = 99 //-1 means continuous
        audioPlayer.prepareToPlay()
    }
    // MARK: - Constants
    struct Constants {
        static let BallSize: CGFloat = 40.0
        static let BallColor = "Yellow"
        static let BallSpeed: Float = 1.0
        static let BoxPathName = "Box"
        static let CourtColor = "Black"
        static let PaddlePathName = "Paddle"
        static let PaddleColor = "Green"
        static let PaddleSize = CGSize(width: 80.0, height: 20.0)
        static let PaddleCornerRadius: CGFloat = 5.0
        static let BrickColumns = 4
        static let BrickCornerRadius: CGFloat = 15.0
        static let BrickTotalWidth: CGFloat = 1.0
        static let BrickTotalHeight: CGFloat = 0.46
        static let BrickTopSpacing: CGFloat = 0.02
        static let BrickSpacing: CGFloat = 7.0
        static let MaxBalls = 3
        static let MaxRows = 7
        static let EditImageSegue = "Edit Image"
        static let ReturnImageSegue = "Back to LeaderBoard"
        static let UserId = "User.Login"
//        static let BrickColors = [UIColor.greenColor(), UIColor.blueColor(), UIColor.redColor(), UIColor.yellowColor()]
    }
    func printFonts() {
        let fontFamilyNames = UIFont.familyNames()
        for familyName in fontFamilyNames {
            println("------------------------------")
            println("Font Family Name = [\(familyName)]")
            let names = UIFont.fontNamesForFamilyName(familyName as! String)
            println("Font Names = [\(names)]")
        }
    }
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSwipeMeTextLayer()
        buildCube()
        //printFonts()
        prepareAudios()
        self.hidesBottomBarWhenPushed = true
        animator.addBehavior(breakout)
        Settings(defaultColumns: Constants.BrickColumns, defaultRows: Constants.BrickColumns / 2, defaultBalls: 1, defaultDifficulty: 1, defaultSpeed: Constants.BallSpeed, defaultBallColor: Constants.BallColor, defaultCourtColor: Constants.CourtColor, defaultPaddleColor: Constants.PaddleColor, defaultPaddleWidthMultiplier: paddleWidthMultiplier)
        gameView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "pushBall:"))
        gameView.layer.backgroundColor = UIColor.colorFor(Settings().courtColor).CGColor
        //The pan gesture handles most movement. However in the heat of the game it might be necessary to move faster-that’s what the left and right swipe gestures r4
        gameView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: "panPaddle:"))
        gameView.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: "showTabBar:"))
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: "swipePaddleLeft:")
        swipeLeft.direction = .Left
        gameView.addGestureRecognizer(swipeLeft)
        let swipeRight = UISwipeGestureRecognizer(target: self, action: "swipePaddleRight:")
        swipeRight.direction = .Right
        gameView.addGestureRecognizer(swipeRight)
        gameView.addSubview(scoreBoard)
        gameView.addSubview(powerBallScoreBoard)
        breakout.collisionDelegate = self
        self.tabBarController?.tabBar.hidden = true
        levelOne(tier)
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //Settings().type stuff set here!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        if Settings().courtColor == "Blue" {
            scoreBoard.textColor = UIColor.whiteColor()
            powerBallScoreBoard.textColor = UIColor.yellowColor()
        } else {
            scoreBoard.textColor = UIColor.blueColor()
            powerBallScoreBoard.textColor = UIColor.blueColor()
        }
        breakout.speed = CGFloat(Settings().speed!)
        breakout.ballBehavior.allowsRotation = Settings().ballRotation
        gameView.layer.backgroundColor = UIColor.colorFor(Settings().courtColor).CGColor
        
        let pw = (CGFloat(Settings().paddleWidthMultiplier!) * Constants.BallSize)
        paddleSize = CGSize(width: pw, height: 20.0)
        paddle.frame.size = paddleSize
        paddle.layer.backgroundColor = UIColor.colorFor(Settings().paddleColor).CGColor
        
        if Settings().soundOn {
            audioPlayer.play()
        } else {
            audioPlayer.pause()
        }
        cornerRadius = Constants.BrickCornerRadius
        //reset CORNERRADIUS before resetWall...for intended side effect->..LayoutSub..(placeBricks)
        if Settings().changed {
            resetWall()
            levelOne(tier)
        }
        setAutoStartTimer()
      }
    func resetWall() {
        Settings().changed = false
        for (index, brick) in bricks {
            brick.view.removeFromSuperview()
        }
        bricks.removeAll(keepCapacity: true)
        
        for ball in breakout.balls {
            ball.removeFromSuperview()
        }
        animator.removeAllBehaviors()
        breakout = BreakoutBehavior()
        animator.addBehavior(breakout)
        breakout.collisionDelegate = self
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        autoStartTimer?.invalidate()
        autoStartTimer = nil
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        var gameRect = gameView.bounds
        gameRect.size.height *= 2
        breakout.addBarrier(UIBezierPath(rect: gameRect), named: Constants.BoxPathName)
        //Its not nice if the player looses a ball because the device has been rotated accidentally. In such cases put the ball back on screen:
        for ball in breakout.balls {
            if !CGRectContainsRect(gameView.bounds, ball.frame) {
                placeBall(ball)
                animator.updateItemUsingCurrentState(ball)
            }
        }
        placeBricks()
        //When the paddle is outside the game view (at the beginning and possibly after device roatation), reset its position:
        resetPaddleAndScoreBoard()
    }
    // MARK: - autoStartTimer
    //The timer will be started only when the configuration is set to do so:
    private func setAutoStartTimer() {
        if Settings().autoStart {
            autoStartTimer =  NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: "fireAutoStart:", userInfo: nil, repeats: true)
        }
    }
    //When the timer fires – and there are not “enough” balls, create a new one, place it, add it to the behavior and push it:
    func fireAutoStart(timer: NSTimer) {
        if breakout.balls.count < Settings().balls {
            let ball = createBall()
            placeBall(ball)
            breakout.addBall(ball)
            breakout.pushBall(breakout.balls.last!)
        }
    }
    lazy var uid: String = {
        if let login = NSUserDefaults.standardUserDefaults().stringForKey(Constants.UserId) {
            return login
        }
        return "baddie"
        }()
    // MARK: - ball
    lazy var loggedInUser: User? = {
        if let user = User.login(self.uid, password: "foo") {
            return user
        }
        return nil
    }()
    func createBall() -> UIView {
        let ballSize = CGSize(width: Constants.BallSize, height: Constants.BallSize)
        let ball = UIView(frame: CGRect(origin: CGPoint.zeroPoint, size: ballSize))
        ball.layer.backgroundColor = UIColor.colorFor(Settings().ballColor).CGColor
        if loggedInUser != nil {
            ball.layer.contents = loggedInUser!.image!.CGImage
            ball.layer.contentsGravity = kCAGravityCenter
            ball.layer.contentsScale = 2.0
        }
        ball.layer.cornerRadius = Constants.BallSize / 2.0
        ball.layer.borderColor = UIColor.blackColor().CGColor
        ball.layer.borderWidth = 2.0
        ball.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        ball.layer.shadowOpacity = 0.5
        return ball
    }
    func placeBall(ball: UIView) {
        //ball.center = CGPoint(x: gameView.bounds.midX, y: gameView.bounds.midY)  //from ball game
        var center = paddle.center
        center.y -= paddleSize.height/2 + Constants.BallSize/2
        ball.center = center
    }
    private var ballCounter: Int = 0
    func pushBall(gesture: UITapGestureRecognizer) { //*** lots happening here!
        if gesture.state == .Ended {
            if ballCounter > Constants.MaxBalls {
                levelFinished()
            } else if breakout.balls.count < Settings().balls {
                let ball = createBall()
                ballCounter += 1
                placeBall(ball)
                breakout.addBall(ball)
            }
            if breakout.balls.count > 0 {
                breakout.pushBall(breakout.balls.last!)
            }
        }
    }
    // MARK: - paddle
    lazy var paddle: UIView = {
        let paddle = UIView(frame: CGRect(origin: CGPoint(x: -1 , y: -1), size: self.paddleSize))
        paddle.layer.backgroundColor = UIColor.colorFor(Settings().paddleColor).CGColor
        paddle.layer.cornerRadius = Constants.PaddleCornerRadius
        paddle.layer.borderColor = UIColor.blackColor().CGColor
        paddle.layer.borderWidth = 2.0
        paddle.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        paddle.layer.shadowOpacity = 0.5
        self.gameView.addSubview(paddle)
        return paddle
        }()
    func resetPaddleAndScoreBoard() {
        //** create paddle partly out so it gets reset the first time, then only when device is rotated
        if !CGRectContainsRect(gameView.bounds, paddle.frame) {
            paddle.center = CGPoint(x: gameView.bounds.midX, y: (gameView.bounds.maxY - paddle.bounds.height))
            scoreBoard.center = CGPoint(x: gameView.bounds.midX, y: (gameView.bounds.midY + 80.0))
            powerBallScoreBoard.center = CGPoint(x: gameView.bounds.midX, y: (gameView.bounds.midY + 110.0))
        } else {
            paddle.center = CGPoint(x: paddle.center.x, y: (gameView.bounds.maxY - paddle.bounds.height))
            scoreBoard.center = CGPoint(x: scoreBoard.center.x, y: (gameView.bounds.midY + 80.0))
            powerBallScoreBoard.center = CGPoint(x: scoreBoard.center.x, y: (gameView.bounds.midY + 110.0))
        }
        addPaddleBarrier()
    }
    func addPaddleBarrier() {
        breakout.addBarrier(UIBezierPath(roundedRect: paddle.frame, cornerRadius: Constants.PaddleCornerRadius), named: Constants.PaddlePathName)
    }
    //To change the position of the paddle, change its origin – but take care, not to move it off screen:
    func placePaddle(translation: CGPoint) {
        var origin = paddle.frame.origin
        origin.x = origin.x + translation.x
        paddle.frame.origin = origin
        addPaddleBarrier()
    }
    //While panning change the position of the paddle according to the panned distance. For swipes move to the far left or right:
    func panPaddle(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .Ended: fallthrough
        case .Changed:
            placePaddle(gesture.translationInView(gameView))
            gesture.setTranslation(CGPointZero, inView: gameView)
        default: break
        }
    }
    func showTabBar(gesture: UIPinchGestureRecognizer) {
        switch gesture.state {
        case .Ended:
            self.tabBarController?.tabBar.hidden = false
        default: break
        }
    }
    func swipePaddleLeft(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .Ended:
            placePaddle(CGPoint(x: -gameView.bounds.maxX, y: 0.0))
        default: break
        }
    }
    func swipePaddleRight(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .Ended:
            placePaddle(CGPoint(x: gameView.bounds.maxX, y: 0.0))
        default: break
        }
    }
    
    // MARK: - levelOne
    let model = UIDevice.currentDevice().model
    var adjust: CGFloat = 1.2
    func levelOne(tier: Int) {
        if bricks.count > 0 { return }
        if tier > 1 {
            if Settings().columns! < Settings().rows! * 2 {
                if Settings().columns! < 16 {
                    Settings().columns! += 1
                }
            } else {
                if Settings().rows! < Constants.MaxRows {
                    Settings().rows! += 1
                }
            }
        }
        var deltaX = Constants.BrickTotalWidth / CGFloat(Settings().columns!)
        var deltaY = Constants.BrickTotalHeight / CGFloat(Settings().rows!)
        //adjust height of brick wall at lower levels
        if Settings().rows! < 4 {
            deltaY = deltaY / adjust  //shorten
            deltaX = deltaX / adjust  //narrow
        } else {
            adjust = 1.0
        }
        var frame = CGRect(origin: CGPointZero, size: CGSize(width: deltaX, height: deltaY))
        for row in 0..<Settings().rows! {
            for column in 0..<Settings().columns! {
                frame.origin.x = deltaX * CGFloat(column)
                frame.origin.y = deltaY * CGFloat(row) + Constants.BrickTopSpacing
                let brick = UIButton(frame: frame) //used to be UIView
                let test = (row / 2 % 2 == 0) && (column / 2 % 2 == 1)
                if tier > 1 && row > 0 && test {
                    brick.layer.contents = UIImage(named: "bom")!.CGImage
                } else {
                //brick.backgroundColor = Constants.BrickColors[row % Constants.BrickColors.count]
                    brick.backgroundColor = UIColor.random
                    if model.hasPrefix("iPad") || Settings().columns! < 10 { //can't read numbers on iPhone after 10
                        brick.setTitleColor(UIColor.blackColor(), forState: .Normal)
                        brick.setTitle("\(UIColor.scoreForColor(brick.backgroundColor!))", forState: .Normal)
                        brick.titleLabel!.font = UIFont(name: "ComicSansMS", size: 12.0)
                    }
                    brick.layer.cornerRadius = cornerRadius
                    brick.layer.borderWidth = 1.5
                    brick.layer.borderColor = UIColor.blackColor().CGColor
                    brick.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
                    brick.layer.shadowOpacity = 0.5
                }
                gameView.addSubview(brick)
                var action: BrickAction = nil
                //Add the “black” row only when the difficulty “hard” has been chosen:
                if Settings().difficulty == 1 {
                    if row + 1 == Settings().rows! {
                        brick.backgroundColor = UIColor.blackColor()
                        action = { index in
                            if brick.backgroundColor != UIColor.blackColor() {
                                self.destroyBrickAtIndex(index)
                            } else {
                                NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: "changeBrickColor:", userInfo: brick, repeats: false)
                            }
                        }
                    }
                }
                bricks[row * Settings().columns! + column] = Brick(relativeFrame: frame, view: brick, action: action)
            }
        }
    }
    func changeBrickColor(timer: NSTimer) {
        if let brick = timer.userInfo as? UIView {
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                brick.backgroundColor = UIColor.cyanColor()
                }, completion: nil)
        }
    }
    // MARK: - bricks
    private var bricks = [Int:Brick]()
    //Store this structure for each brick in a dictionary:
    private struct Brick {
        var relativeFrame: CGRect
        var view: UIView
        var action: BrickAction
    }
    private typealias BrickAction = ((Int) -> Void)?
    //just takes the relative frame information boosts it to the device dimensions, and adjusts the barriers for the collision behavior:
    
    func placeBricks() {
        for (index, brick) in bricks {
            brick.view.frame.origin.x = brick.relativeFrame.origin.x * gameView.bounds.width * adjust
            brick.view.frame.origin.y = brick.relativeFrame.origin.y * gameView.bounds.height * adjust
            brick.view.frame.size.width = brick.relativeFrame.width * gameView.bounds.width
            brick.view.frame.size.height = brick.relativeFrame.height * gameView.bounds.height
            brick.view.frame = CGRectInset(brick.view.frame, Constants.BrickSpacing, Constants.BrickSpacing)
            cornerRadius = min(brick.view.frame.width, brick.view.frame.height) / 2.0
            breakout.addBarrier(UIBezierPath(roundedRect: brick.view.frame, cornerRadius: cornerRadius), named: index)
        }
    }
    //When a collision occurs, the barrier identifier is an integer (equals a brick), destroy the brick:
    //destroy bricks only if no special action for that brick has been defined, otherwise run that action:
    func collisionBehavior(behavior: UICollisionBehavior, beganContactForItem item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying, atPoint p: CGPoint) {
        if let index = identifier as? Int {
            if let action = bricks[index]?.action {
                action(index)
            } else {
                destroyBrickAtIndex(index)
            }
        }
    }
    //First remove the barrier – then core animate flip the brick (and make it slightly transparent). Afterwards add it to the behavior, and let it fade out completely. Finally remove the brick from the behavior, the game view and from the brick array:
    private func destroyBrickAtIndex(index: Int) {
        breakout.removeBarrier(index)
        var trans = UIViewAnimationOptions.TransitionFlipFromBottom
        if let brick = bricks[index] {
            if brick.view.backgroundColor == nil {
                trans = UIViewAnimationOptions.TransitionCrossDissolve
            }
            UIView.transitionWithView(brick.view, duration: 0.3, options: trans, animations: {
                brick.view.alpha = 0.8
                }, completion: { (success) -> Void in
                    self.breakout.addBrick(brick.view)
                    UIView.animateWithDuration(1.5, animations: {  //1.0
                        brick.view.alpha = 0.0  //disappear
                        }, completion: { (success) -> Void in
                            if brick.view.backgroundColor == nil { //bom image
                                self.bonus()
                            } else {
                                self.score += UIColor.scoreForColor(brick.view.backgroundColor!) * self.powerBall
                                self.showScore()
                            }
                            self.breakout.removeBrick(brick.view)
                            brick.view.removeFromSuperview()
                    })
            })
            bricks.removeValueForKey(index)
            if bricks.count == 0 {
                levelFinished()
            }
        }
    }
    func showScore() {
        scoreBoard.text = msg + score.addSeparator
    }
    var bonusScore = 0
    func bonus() { //hit a bom
        bonusScore = Int(1000 / Settings().paddleWidthMultiplier!) * powerBall
        showBonusScore()
        score += bonusScore
        bonusScore = 0
    }
    func showBonusScore() {
        scoreBoard.text = "Bonus!   " + bonusScore.addSeparator
    }
    let today = NSDate()
    private var timestamp: String { // a computed property instead of func
        get {
            let formattedDate = NSDateFormatter.localizedStringFromDate(today,
                dateStyle: NSDateFormatterStyle.ShortStyle,
                timeStyle: NSDateFormatterStyle.NoStyle)
            return formattedDate
        }
        set { self.timestamp = newValue }
    }
    var powerBall = 1
    //remove the timer when a game has finished, and start it again afterwards...
    func levelFinished() {
        autoStartTimer?.invalidate()
        autoStartTimer = nil
        for ball in breakout.balls {
            breakout.removeBall(ball)
        }
        let ballBonus = 2000 * (Constants.MaxBalls + 1 - ballCounter) / Settings().paddleWidthMultiplier!
        score += ballBonus
        if newHighScoreAchieved {
            Settings().highScore = score
            Settings().highScoreDate = timestamp
        }
        if ballCounter == 1 {
            powerBallScoreBoard.text = "PowerBall Achieved!"
            powerBall = 3
            loggedInUser = User.login("japple", password: "foo")
        } else {
            powerBallScoreBoard.text = ""
            powerBall = 1
            loggedInUser = User.login(uid, password: "foo")
        }
        var title = "Game Over!", message = "Try Again...", cancelButtonTitle = "Restart?"
        if Settings().rows == Constants.MaxRows && bricks.count == 0 {
            title = "Set Complete"
            message = "You Won!!!"
            cancelButtonTitle = "Start Again"
        }
        if Settings().rows == Constants.MaxRows || (ballCounter > Constants.MaxBalls && bricks.count != 0) {
            tier = 0
            let alert = UIAlertView(title: title, message: message, delegate: self, cancelButtonTitle: cancelButtonTitle)
            alert.addButtonWithTitle("Quit")
            alert.dismissWithClickedButtonIndex(alert.firstOtherButtonIndex, animated: true)
            alert.show()
            //alertView(alert, clickedButtonAtIndex: alert.cancelButtonIndex)
        }
        else if NSClassFromString("UIAlertController") != nil && tier > 0 {
            let alertController = UIAlertController(title: "Level Complete!", message: "Leftover Ball Bonus = " + ballBonus.addSeparator, preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(title: "Continue?", style: .Default, handler: { (action) in
                self.ballCounter = 0
                self.tier += 1
                self.showScore()
                self.levelOne(self.tier)
                self.setAutoStartTimer()
            }))
            alertController.addAction(UIAlertAction(title: "Quit?", style: .Destructive, handler: { (action) in
                exit(0)
            }))
            presentViewController(alertController, animated: true, completion: nil)
        }
    }
    //game over -> restart
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 1 {
            exit(0)
        }
        if buttonIndex == 0 {
            resetWall()
            scoreBoard.text = "" //clear any lingering bonus score
            ballCounter = 0
            cornerRadius = Constants.BrickCornerRadius
            score = 0
            tier = 1
            //don't reset colors or paddleWidth if user changed them!
            Settings(defaultColumns: Constants.BrickColumns, defaultRows: Constants.BrickColumns / 2, defaultBalls: 1, defaultDifficulty: 1, defaultSpeed: Constants.BallSpeed, defaultBallColor: Settings().ballColor, defaultCourtColor: Settings().courtColor, defaultPaddleColor: Settings().paddleColor, defaultPaddleWidthMultiplier: Settings().paddleWidthMultiplier!)
            levelOne(tier)
            setAutoStartTimer()
        }
    }
    
    func degreesToRadians(degrees: Double) -> CGFloat {
        return CGFloat(degrees * M_PI / 180.0)
    }
    
    func radiansToDegrees(radians: Double) -> CGFloat {
        return CGFloat(radians / M_PI * 180.0)
    }
    //class RedBlockViewController: UIViewController {
    //MARK: RedBlockViewController
    @IBOutlet weak var viewForTransformLayer: UIView!
    
    enum Color: Int {
        case Red, Orange, Yellow, Green, Blue, Purple
    }
    let sideLength = CGFloat(220.0) //block side is 250
    
    var transformLayer: CATransformLayer!
    let swipeMeTextLayer = CATextLayer()
    var redColor = UIColor.redColor().colorWithAlphaComponent(0.2)
    var orangeColor = UIColor.orangeColor().colorWithAlphaComponent(0.2)
    var yellowColor = UIColor.yellowColor().colorWithAlphaComponent(0.2)
    var greenColor = UIColor.greenColor().colorWithAlphaComponent(0.2)
    var blueColor = UIColor.blueColor().colorWithAlphaComponent(0.2)
    var purpleColor = UIColor.purpleColor().colorWithAlphaComponent(0.2)
    var trackBall: TrackBall?
    
    // MARK: - Quick reference
    func setUpSwipeMeTextLayer() {
        swipeMeTextLayer.frame = CGRect(x: 0.0, y: sideLength / 4.0, width: sideLength, height: sideLength / 2.0)
        swipeMeTextLayer.string = "Red\r Block"
        swipeMeTextLayer.alignmentMode = kCAAlignmentCenter
        swipeMeTextLayer.foregroundColor = UIColor.whiteColor().CGColor
        let fontName = "Noteworthy-Light" as CFString
        let fontRef = CTFontCreateWithName(fontName, 18.0, nil)
        swipeMeTextLayer.font = fontRef
        swipeMeTextLayer.contentsScale = UIScreen.mainScreen().scale
    }
    
    // MARK: - Triggered actions
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        if let touch = touches.first as? UITouch {
            let location = touch.locationInView(viewForTransformLayer)
            if trackBall != nil {
                trackBall?.setStartPointFromLocation(location)
            } else {
                trackBall = TrackBall(location: location, inRect: viewForTransformLayer.bounds)
            }
            
            for layer in transformLayer.sublayers {
                if let hitLayer = layer.hitTest(location) {
                    //showBoxTappedLabel()
                    break
                }
            }
        }
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        if let touch = touches.first as? UITouch {
            let location = touch.locationInView(viewForTransformLayer)
            if let transform = trackBall?.rotationTransformForLocation(location) {
                viewForTransformLayer.layer.sublayerTransform = transform
            }
        }
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        if let touch = touches.first as? UITouch {
            let location = touch.locationInView(viewForTransformLayer)
            trackBall?.finalizeTrackBallForLocation(location)
        }
    }
    
    // MARK: - Helpers
    func buildCube() {
        transformLayer = CATransformLayer()

        var layer = sideLayerWithColor(UIColor.random.colorWithAlphaComponent(0.2))
        layer.addSublayer(swipeMeTextLayer)
        transformLayer.addSublayer(layer)
        
        layer = sideLayerWithColor(UIColor.random.colorWithAlphaComponent(0.2))
        var transform = CATransform3DMakeTranslation(sideLength / 2.0, 0.0, sideLength / -2.0)
        transform = CATransform3DRotate(transform, degreesToRadians(90.0), 0.0, 1.0, 0.0)
        layer.transform = transform
        transformLayer.addSublayer(layer)
        
        layer = sideLayerWithColor(UIColor.random.colorWithAlphaComponent(0.2))
        layer.transform = CATransform3DMakeTranslation(0.0, 0.0, -sideLength)
        transformLayer.addSublayer(layer)
        
        layer = sideLayerWithColor(UIColor.random.colorWithAlphaComponent(0.2))
        transform = CATransform3DMakeTranslation(sideLength / -2.0, 0.0, sideLength / -2.0)
        transform = CATransform3DRotate(transform, degreesToRadians(90.0), 0.0, 1.0, 0.0)
        layer.transform = transform
        transformLayer.addSublayer(layer)
        
        layer = sideLayerWithColor(UIColor.random.colorWithAlphaComponent(0.2))
        transform = CATransform3DMakeTranslation(0.0, sideLength / -2.0, sideLength / -2.0)
        transform = CATransform3DRotate(transform, degreesToRadians(90.0), 1.0, 0.0, 0.0)
        layer.transform = transform
        transformLayer.addSublayer(layer)
        
        layer = sideLayerWithColor(UIColor.random.colorWithAlphaComponent(0.2))
        transform = CATransform3DMakeTranslation(0.0, sideLength / 2.0, sideLength / -2.0)
        transform = CATransform3DRotate(transform, degreesToRadians(90.0), 1.0, 0.0, 0.0)
        layer.transform = transform
        transformLayer.addSublayer(layer)
        
        transformLayer.anchorPointZ = sideLength / -2.0
        viewForTransformLayer.layer.addSublayer(transformLayer)
    }
    
    func sideLayerWithColor(color: UIColor) -> CALayer {
        let layer = CALayer()
        layer.frame = CGRect(origin: CGPointZero, size: CGSize(width: sideLength, height: sideLength))
        layer.position = CGPoint(x: CGRectGetMidX(viewForTransformLayer.bounds), y: CGRectGetMidY(viewForTransformLayer.bounds))
        layer.backgroundColor = color.CGColor
        return layer
    }
    
}
// MARK: - extensions
private extension UIColor {
    class func colorFor(sel: String) -> UIColor {
        switch sel {
        case "Green": return UIColor.greenColor()
        case "Blue": return UIColor.blueColor()
        case "Orange": return UIColor.orangeColor()
        case "Red": return UIColor.redColor()
        case "Purple": return UIColor.purpleColor()
        case "Yellow": return UIColor.yellowColor()
        case "Cyan": return UIColor.cyanColor()
        case "White": return UIColor.whiteColor()
        case "Black": return UIColor.blackColor()
        case "Clear": return UIColor.clearColor()
        default: return UIColor.blackColor()
        }
    }
    class func scoreForColor(sel: UIColor) -> Int {
        let pwm = Settings().paddleWidthMultiplier!
        switch sel {
        case UIColor.greenColor(): return (8 / pwm * 4)
        case UIColor.blueColor(): return (8 / pwm * 8)
        case UIColor.orangeColor(): return (8 / pwm * 12)
        case UIColor.redColor(): return (8 / pwm * 16)
        case UIColor.purpleColor(): return (8 / pwm * 20)
        case UIColor.yellowColor(): return (8 / pwm * 24)
        case UIColor.brownColor(): return (8 / pwm * 28)
        case UIColor.darkGrayColor(): return (8 / pwm * 32)
        case UIColor.lightGrayColor(): return (8 / pwm * 36)
        case UIColor.cyanColor(): return (8 / pwm * 40)
        case UIColor.whiteColor(): return (8 / pwm * 44)
        default: return 0
        }
    }
    class var random: UIColor {
        switch arc4random() % 11 {
        case 0: return UIColor.greenColor()
        case 1: return UIColor.blueColor()
        case 2: return UIColor.orangeColor()
        case 3: return UIColor.redColor()
        case 4: return UIColor.purpleColor()
        case 5: return UIColor.yellowColor()
        case 6: return UIColor.brownColor()
        case 7: return UIColor.darkGrayColor()
        case 8: return UIColor.lightGrayColor()
        case 9: return UIColor.cyanColor()
        case 10: return UIColor.whiteColor()
        default: return UIColor.blackColor()
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

private extension Int {
    var addSeparator: String {
        let nf = NSNumberFormatter()
        nf.groupingSeparator = ","
        nf.numberStyle = NSNumberFormatterStyle.DecimalStyle
        return nf.stringFromNumber(self)!
    }
}