//
//  BallViewController.swift
//  BallA5
//
//  Created by iMac21.5 on 5/24/15.
//  Copyright (c) 2015 Garth MacKenzie. All rights reserved.
//

import UIKit
import AVFoundation
let model = UIDevice.currentDevice().model

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
        self.gameView.addSubview(scoreBoard)
        return scoreBoard
        }()
    lazy var powerBallScoreBoard: UILabel = { let scoreBoard = UILabel(frame: CGRect(origin: CGPoint(x: -1 , y: -1), size: CGSize(width: min(self.gameView.frame.width, self.gameView.frame.height), height: 40.0)))
        scoreBoard.font = UIFont(name: "ComicSansMS-Bold", size: 30.0)
        scoreBoard.textAlignment = NSTextAlignment.Center
        self.gameView.addSubview(scoreBoard)
        return scoreBoard
        }()
    lazy var animator: UIDynamicAnimator = { UIDynamicAnimator(referenceView: self.gameView) }()
    var paddleSize = Constants.PaddleSize
    
    //To start balls automatically, add a timer which periodically checks, if there is a ball (or the maximum number of balls) and push them if necessary.
    private var autoStartTimer: NSTimer?
    private var audioPlayer: AVAudioPlayer!
    private var path: String! = ""
    private var soundTrack = 0
    private var availableCredits: Int { // a computed property instead of func
        get { return Settings().availableCredits }
        set { Settings().availableCredits = newValue }
    }
    // MARK: - get coins!
    lazy var coins: UIImageView = {
        let size = CGSize(width: 42.0, height: 20.0)
        let coins = UIImageView(frame: CGRect(origin: CGPoint(x: -1 , y: -1), size: size))
        self.gameView.addSubview(coins)
        return coins
        }()
    private var coinCount = 0
    lazy var coinCountLabel: UILabel = { let coinCountLabel = UILabel(frame: CGRect(origin: CGPoint(x: -1 , y: -1), size: CGSize(width: 80.0, height: 20.0)))
        coinCountLabel.font = UIFont(name: "ComicSansMS-Bold", size: 18.0)
        coinCountLabel.textAlignment = NSTextAlignment.Center
        self.gameView.addSubview(coinCountLabel)
        return coinCountLabel
        }()
    lazy var largeCoin: UIImageView = {
        let size = CGSize(width: 100.0, height: 100.0)
        let coin = UIImageView(frame: CGRect(origin: CGPoint(x: -1 , y: -1), size: size))
        self.gameView.addSubview(coin)
        return coin
        }()
    func earnCoin() {
        //prepare for annimation
        largeCoin.image = UIImage(named: "1000CreditsSWars1.png")
        largeCoin.alpha = 1
        largeCoin.center.y = gameView.bounds.minY //move off screen but alpha = 1
        UIView.animateWithDuration(3.0, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.0, options: nil, animations: {
            self.resetPaddleAndScoreBoard()
            self.largeCoin.alpha = 0
            }, completion: nil)
        //prepare for annimation
        coinCountLabel.alpha = 0
        coinCountLabel.center.y = gameView.bounds.maxY //move off screen
        let images = (0...2).map {
            UIImage(named: "1000Credits\($0)-20.png") as! AnyObject
        }
        if let image = images[min(coinCount, 2)] as? UIImage {
            coins.image = image
            coins.alpha = 0
            coins.center.y = gameView.bounds.maxY //move off screen
            self.coinCount += 1
            if self.coinCount % 3 == 0 {
                self.availableCredits += 1
                let shopTabBarItem = tabBarController!.tabBar.items![0] as! UITabBarItem
                shopTabBarItem.badgeValue = "\(self.availableCredits)"
            }
            UIView.animateWithDuration(4.0, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.0, options: nil, animations: {
                self.coinCountLabel.text = self.coinCount.addSeparator
                self.resetPaddleAndScoreBoard()
                self.coins.alpha = 1
                self.coinCountLabel.alpha = 1
                }, completion: nil)
        }
    }
    var tbvcArray: [UIViewController]?
    func prepareTabBar() {
        tbvcArray = tabBarController!.viewControllers as? [UIViewController]
        let cvc = tbvcArray![4]    //CREDITS
        for view in cvc.view.subviews as! [UIView] {
            if let animatedImageView = view as? UIImageView {
                if animatedImageView.tag == 111 {
                    let images = (0...8).map {
                        UIImage(named: "peanuts-anim\($0).png") as! AnyObject
                    }
                    animatedImageView.animationImages = images
                    animatedImageView.animationDuration = 9.0
                    animatedImageView.startAnimating()
                }
                if animatedImageView.tag == 333 {
                    let images = (0...6).map {
                        UIImage(named: "typing-computer\($0).png") as! AnyObject
                    }
                    animatedImageView.animationImages = images
                    animatedImageView.animationDuration = 1.0
                    animatedImageView.startAnimating()
                }
            }
        }
    }
    func prepareAudios() {
        soundTrack = Settings().soundChoice
        switch soundTrack {
        case 0: path = NSBundle.mainBundle().pathForResource("jazzloop2_70", ofType: "mp3")
        case 1: path = NSBundle.mainBundle().pathForResource("CYMATICS- Science Vs. Music - Nigel Stanford-2", ofType: "mp3")
        case 2: path = NSBundle.mainBundle().pathForResource("Phil Wickham-Carry My Soul(Live at RELEVANT)", ofType: "mp3")
        case 3: path = NSBundle.mainBundle().pathForResource("Hudson - Chained", ofType: "mp3")
        case 4: path = NSBundle.mainBundle().pathForResource("Forrest Gump Soundtrack", ofType: "mp3")
        case 5: path = NSBundle.mainBundle().pathForResource("Titanic Soundtrack - Rose", ofType: "mp3")
        case 6: path = NSBundle.mainBundle().pathForResource("Diana Ross - Ain't No Mountain High Enough 1981", ofType: "mp3")
        case 7: path = NSBundle.mainBundle().pathForResource("Phil Wickham - This Is Amazing Grace", ofType: "mp3")
        case 8: path = NSBundle.mainBundle().pathForResource("Hillsong United - No Other Name - Oceans (Where Feet May Fail)", ofType: "mp3")
        case 9: path = NSBundle.mainBundle().pathForResource("Phil Wickham - At Your Name (Yahweh, Yahweh)", ofType: "mp3")
        case 10: path = NSBundle.mainBundle().pathForResource("Yusuf Islam - Peace Train - OUTSTANDING!-2", ofType: "mp3")
        default: path = NSBundle.mainBundle().pathForResource("jazzloop2_70", ofType: "mp3")
        }
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
        static let CourtColor = "Clear"
        static let PaddleColor = "Green"
        static let PaddleCornerRadius: CGFloat = 5.0
        static let PaddlePathName = "Paddle"
        static let PaddleSize = CGSize(width: 80.0, height: 20.0)
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
        Settings().endLevelBonus = 0
        //printFonts()
        prepareAudios()
        prepareTabBar()
        self.hidesBottomBarWhenPushed = true
        animator.addBehavior(breakout)
        Settings(defaultColumns: Constants.BrickColumns, defaultRows: Constants.BrickColumns / 2, defaultBalls: 1, defaultDifficulty: 1, defaultSpeed: Constants.BallSpeed, defaultBallColor: Constants.BallColor, defaultCourtColor: Constants.CourtColor, defaultPaddleColor: Constants.PaddleColor, defaultPaddleWidthMultiplier: Settings().paddleWidthMultiplier)
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
        setUpSwipeMeTextLayer()
        breakout.collisionDelegate = self
        self.tabBarController!.tabBar.hidden = true
        levelOne(tier)
    }
    func adjustColors() {
        if Settings().courtColor == "Blue" {
            scoreBoard.textColor = UIColor.whiteColor()
            powerBallScoreBoard.textColor = UIColor.yellowColor()
            coinCountLabel.textColor = UIColor.whiteColor()
        } else {
            scoreBoard.textColor = UIColor.blueColor()
            powerBallScoreBoard.textColor = UIColor.blueColor()
            coinCountLabel.textColor = UIColor.blueColor()
        }
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let settingsTabBarItem = tabBarController!.tabBar.items![2] as! UITabBarItem
        settingsTabBarItem.badgeValue = nil  //reset for paddle purchaces
        let shopTabBarItem = tabBarController!.tabBar.items![0] as! UITabBarItem
        if availableCredits == 0 {
            shopTabBarItem.badgeValue = nil
        } else {
            shopTabBarItem.badgeValue = "\(availableCredits)"
        }
        //Settings().type stuff set here!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        adjustColors()
        breakout.speed = CGFloat(Settings().speed)
        breakout.ballBehavior.allowsRotation = Settings().ballRotation
        gameView.layer.backgroundColor = UIColor.colorFor(Settings().courtColor).CGColor
        let pw = Settings().paddleWidthMultiplier
        paddleSize = CGSize(width: (CGFloat(pw) * Constants.BallSize), height: 20.0)
        paddle.frame.size = paddleSize
        if Settings().myPaddles.count == 1 {
            paddle.layer.backgroundColor = UIColor.colorFor(Settings().paddleColor).CGColor
        } else {
            paddle.layer.contents = UIImage(named: Settings().myPaddles.last!)!.CGImage
        }
        if Settings().redBlockOn && powerBall == 1 {
            buildCube()
        } else if self.transformLayer != nil {
            self.transformLayer.removeFromSuperlayer()
            self.viewForTransformLayer.alpha = 0
        }
        if Settings().soundChoice != soundTrack {
            audioPlayer.pause()
            prepareAudios()
        }
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
        if Settings().soundOn {
            audioPlayer.pause()
        }
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
        if Constants.MaxBalls + 1 > ballCounter {
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
        let paddleBallTabBarItem = tabBarController!.tabBar.items![1] as! UITabBarItem
        if paddleBallTabBarItem.badgeValue != nil {
            loggedInUser = User.login(paddleBallTabBarItem.badgeValue!, password: "foo") //new ball purchased
            Settings().purchasedUid = loggedInUser?.login
            paddleBallTabBarItem.badgeValue = nil
        }
        let ballSize = CGSize(width: Constants.BallSize, height: Constants.BallSize)
        let ball = UIView(frame: CGRect(origin: CGPoint.zeroPoint, size: ballSize))
        ball.layer.backgroundColor = UIColor.colorFor(Settings().ballColor).CGColor
        if loggedInUser != nil {
            if loggedInUser!.login != Settings().purchasedUid && powerBall == 1 {
                loggedInUser = User.login(Settings().purchasedUid!, password: "foo") //keep using new ball
            }
            ball.layer.contents = loggedInUser!.image!.CGImage
            ball.layer.contentsGravity = kCAGravityCenter
            ball.layer.contentsScale = 2.0
        }
        //println(Settings().purchasedUid)
        if Settings().purchasedUid!.isEmpty || ( Settings().purchasedUid == "baddie" ) {
            ball.layer.cornerRadius = Constants.BallSize / 2.0
            ball.layer.borderColor = UIColor.blackColor().CGColor
            ball.layer.borderWidth = 2.0
            ball.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
            ball.layer.shadowOpacity = 0.5
        }
        ballCounter += 1
        return ball
    }
    func placeBall(ball: UIView) {
        //ball.center = CGPoint(x: gameView.bounds.midX, y: gameView.bounds.midY)  //from ball game
        var center = paddle.center
        center.y -= paddleSize.height/2 + Constants.BallSize/2
        ball.center = center
    }
    private var ballCounter = 0
    func pushBall(gesture: UITapGestureRecognizer) { //*** lots happening here!
        if gesture.state == .Ended {
            if ballCounter > Constants.MaxBalls && breakout.balls.count == 0 {
                levelFinished()
            } else if breakout.balls.count < Settings().balls {
                let ball = createBall()
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
            let midx = gameView.bounds.midX
            //println("not ContainsRect of paddle")
            paddle.center = CGPoint(x: midx, y: (gameView.bounds.maxY - paddle.bounds.height))
            scoreBoard.center = CGPoint(x: midx, y: (gameView.bounds.maxY - 40.0))
            powerBallScoreBoard.center = CGPoint(x: midx, y: (gameView.bounds.midY + 90.0))
            coins.center = CGPoint(x: (midx - 40.0), y: (gameView.bounds.minY + 12.0))
            coinCountLabel.center = CGPoint(x: (midx + 60.0), y: (gameView.bounds.minY + 10.0))
            largeCoin.center = CGPoint(x: midx, y: gameView.bounds.midY)
        } else {
            let midx = gameView.bounds.midX
            paddle.center = CGPoint(x: midx, y: (gameView.bounds.maxY - paddle.bounds.height))
            scoreBoard.center = CGPoint(x: midx, y: (gameView.bounds.maxY - 40.0))
            powerBallScoreBoard.center = CGPoint(x: midx, y: (gameView.bounds.midY + 90.0))
            coins.center = CGPoint(x: midx - 40.0, y: gameView.bounds.minY + 12.0)
            coinCountLabel.center = CGPoint(x: midx + 60.0, y: (gameView.bounds.minY + 10.0))
            largeCoin.center = CGPoint(x: midx, y: gameView.bounds.midY)
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
    //MARK: RedBlock viewForTransformLayer
    
    //While panning change the position of the paddle according to the panned distance. For swipes move to the far left or right:
    func panPaddle(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .Began:
            self.tabBarController!.tabBar.hidden = true
            //redBlock
            let location = gesture.locationInView(viewForTransformLayer)
            //println(location)
            if trackBall != nil {
                trackBall?.setStartPointFromLocation(location)
            } else {
                trackBall = TrackBall(location: location, inRect: viewForTransformLayer.bounds)
            }
        case .Ended:
            //redBlock
            let location = gesture.locationInView(viewForTransformLayer)
            trackBall?.finalizeTrackBallForLocation(location)
        case .Changed:
            //redBlock
            let location = gesture.locationInView(viewForTransformLayer)
            if let transform = trackBall?.rotationTransformForLocation(location) {
                viewForTransformLayer.layer.sublayerTransform = transform
            }
            placePaddle(gesture.translationInView(gameView))
            gesture.setTranslation(CGPointZero, inView: gameView)
        default: break
        }
    }
    func showTabBar(gesture: UIPinchGestureRecognizer) {
        switch gesture.state {
        case .Ended:
            self.tabBarController!.tabBar.hidden = false
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
    
    var adjust: CGFloat = 1.2
    // MARK: - levelOne
    func levelOne(tier: Int) {
        if bricks.count > 0 { return }
        if tier > 1 {
            if Settings().columns < Settings().rows * 2 {
                if Settings().columns < 16 {
                    Settings().columns += 1
                }
            } else {
                if Settings().rows < Constants.MaxRows {
                    Settings().rows += 1
                }
            }
        }
        var deltaX = Constants.BrickTotalWidth / CGFloat(Settings().columns)
        var deltaY = Constants.BrickTotalHeight / CGFloat(Settings().rows)
        //adjust height of brick wall at lower levels
        if Settings().rows < 4 {
            deltaY = deltaY / adjust  //shorten
            deltaX = deltaX / adjust  //narrow
        } else {
            adjust = 1.0
        }
        var frame = CGRect(origin: CGPointZero, size: CGSize(width: deltaX, height: deltaY))
        for row in 0..<Settings().rows {
            for column in 0..<Settings().columns {
                frame.origin.x = deltaX * CGFloat(column)
                frame.origin.y = deltaY * CGFloat(row) + Constants.BrickTopSpacing
                let brick = UIButton(frame: frame) //used to be UIView
                let test = (row / 2 % 2 == 0) && (column / 2 % 2 == 1)
                if tier > 1 && row > 0 && test {
                    if tier == 2 { //start with bom
                        brick.layer.contents = UIImage(named: "bom")!.CGImage
                    } else {
                        brick.layer.contents = UIImage(named: String.randomBom())!.CGImage
                    }
                } else {
                //brick.backgroundColor = Constants.BrickColors[row % Constants.BrickColors.count]
                    prepareBrick(brick)
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
                    if row + 1 == Settings().rows {
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
                bricks[row * Settings().columns + column] = Brick(relativeFrame: frame, view: brick, action: action)
            }
        }
    }
    func prepareBrick(brick: UIButton) {
        brick.backgroundColor = UIColor.random
        if model.hasPrefix("iPad") || Settings().columns < 10 { //can't read values on iPhone
            brick.setTitleColor(UIColor.blackColor(), forState: .Normal) //hides well
            brick.setTitle("\(UIColor.scoreForColor(brick.backgroundColor!))", forState: .Normal)
            brick.titleLabel!.font = UIFont(name: "ComicSansMS", size: 12.0)
        }
    }
    func changeBrickColor(timer: NSTimer) { //only if overlayed with black
        if let brick = timer.userInfo as? UIButton {
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.prepareBrick(brick)
                }, completion: nil)
        }
    }
    // MARK: - bricks
    private var bricks = [Int:Brick]()
    //Store this structure for each brick in a dictionary:
    private struct Brick {
        var relativeFrame: CGRect
        var view: UIButton
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
            brick.view.transform = CGAffineTransformMakeScale(-1, 1)
            if brick.view.backgroundColor == nil { //bom image
                trans = UIViewAnimationOptions.TransitionCrossDissolve
                self.bonus()
            } else {
                self.score += UIColor.scoreForColor(brick.view.backgroundColor!) * self.powerBall
                self.showScore()
            }
            UIView.transitionWithView(brick.view, duration: 0.3, options: trans, animations: {
                brick.view.alpha = 0.8
                }, completion: { (success) -> Void in
                    self.breakout.addBrick(brick.view)
                    UIView.animateWithDuration(1.5, animations: {  //1.0
                        brick.view.alpha = 0.0  //disappear
                        }, completion: { (success) -> Void in
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
        showBonusScore(false)    }
    var bonusScore = 0
    func bonus() { //hit a bom
        bonusScore = Int(1000 / Settings().paddleWidthMultiplier) * powerBall
        showBonusScore(true)
        score += bonusScore
        bonusScore = 0
    }
    func showBonusScore(isBonus: Bool) {
        if isBonus {
            scoreBoard.alpha = 0    //prepare for annimation
            scoreBoard.center.y = 0
            scoreBoard.text = "Bonus!   " + bonusScore.addSeparator
            UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.2, initialSpringVelocity: 0.0, options: nil, animations: {
                self.resetPaddleAndScoreBoard()
                self.scoreBoard.alpha = 1
                }, completion: nil)
        } else {
            scoreBoard.text = msg + score.addSeparator
        }
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
    var powerBall = 1 //normal multiplier
    //remove the timer when a game has finished, and start it again afterwards...
    func levelFinished() {
        for ball in breakout.balls {
            breakout.removeBall(ball)
        }
        let ballBonus = 2000 * (Constants.MaxBalls + 1 - ballCounter) / Settings().paddleWidthMultiplier
        score += ballBonus
        if newHighScoreAchieved {
            Settings().highScore = score
            Settings().highScoreDate = timestamp
        }
        // MARK: - animate PowerBall Achieved!
        if ballCounter == 1 {
            earnCoin()
            powerBallScoreBoard.text = "PowerBall 3X!"
            powerBallScoreBoard.alpha = 0    //prepare for annimation
            powerBallScoreBoard.center.x = 0
            UIView.animateWithDuration(4.0, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.0, options: nil, animations: {
                self.resetPaddleAndScoreBoard()
                self.powerBallScoreBoard.alpha = 1
                }, completion: nil)
            powerBall = 3 //triple score multiplier until removed
            loggedInUser = User.login("japple", password: "foo") //bubble ball
            if Settings().redBlockOn { //don't rebuild the cube during powerBall round
                self.transformLayer.removeFromSuperlayer()
                self.viewForTransformLayer.alpha = 0  //hide redBlock
            }
        } else {
            powerBallScoreBoard.text = ""
            powerBall = 1 //back to regular scoring
            loggedInUser = User.login(uid, password: "foo")
            buildCube()
        }
        var shopCredit = ( (self.coinCount % 3 == 0) && self.coinCount >= 3 )
        if shopCredit || score > 10000 {  //levelFinished post bonus/pre continue...can be with powerBall msg
            if shopCredit { //3rd coin
                scoreBoard.text = "+1 SHOP Credit"
            }
            if score > 10000 {
                var testForBonus = score/10000
                if testForBonus > Settings().endLevelBonus {
                    earnCoin()  //annimated
                    if !(self.coinCount % 3 == 0) { //only show if new coin wasn't 3rd coin
                        scoreBoard.text = "10k COIN added"
                    } //side effect...score is annimated on a Game Over!
                }
            }
            scoreBoard.font = UIFont(name: "ComicSansMS-Bold", size: 30.0)    //prepare for annimation
            scoreBoard.textColor = UIColor.redColor()
            UIView.animateWithDuration(4.0, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.0, options: nil, animations: {
                self.scoreBoard.center = CGPoint(x: self.scoreBoard.center.x, y: (self.gameView.bounds.midY - (self.gameView.bounds.midY / 2.0) ) )
                }, completion: { (success) -> Void in
                    Settings().endLevelBonus += 1
                    UIView.animateWithDuration(2.5, animations: {
                        self.resetPaddleAndScoreBoard()
                        self.scoreBoard.alpha = 0  //disappear
                        }, completion: { (success) -> Void in
                            self.scoreBoard.font = UIFont(name: "ComicSansMS-Bold", size: 18.0)
                            self.scoreBoard.alpha = 1
                    })
            })
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
            alertController.addAction(UIAlertAction(title: "Play", style: .Default, handler: { (action) in
                self.replay()
            }))
            alertController.addAction(UIAlertAction(title: "Shop...", style: .Cancel, handler: { (action) in
                self.replay()
                self.tabBarController!.selectedIndex = 0
            }))
            presentViewController(alertController, animated: true, completion: nil)
        }
    }
    func replay() {
        ballCounter = 0
        tier += 1
        showScore()
        // change court color
        if powerBall == 3 {
            Settings().courtColor = "Black"
        } else {
            Settings().courtColor = Constants.CourtColor  //SettingsViewController().pickerDataSource[Int(arc4random() % 12)]
        }
        gameView.layer.backgroundColor = UIColor.colorFor(Settings().courtColor).CGColor
        adjustColors()
        // end change court color
        if !Settings().autoStart {
            autoStartTimer?.invalidate()
        }
        levelOne(self.tier)
    }
    // MARK: - game over -> restart
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 1 {
            exit(0)
        }
        if buttonIndex == 0 {
            resetWall()
            scoreBoard.text = "" //clear any lingering bonus score
            buildCube()
            ballCounter = 0
            cornerRadius = Constants.BrickCornerRadius
            Settings().endLevelBonus = 0
            score = 0
            tier = 1
            //don't reset ball or paddle colors or paddleWidth if user changed them!
            Settings(defaultColumns: Constants.BrickColumns, defaultRows: Constants.BrickColumns / 2, defaultBalls: 1, defaultDifficulty: 1, defaultSpeed: Constants.BallSpeed, defaultBallColor: Settings().ballColor, defaultCourtColor: Constants.CourtColor, defaultPaddleColor: Settings().paddleColor, defaultPaddleWidthMultiplier: Settings().paddleWidthMultiplier)
            gameView.layer.backgroundColor = UIColor.colorFor(Settings().courtColor).CGColor
            adjustColors()
            levelOne(tier)
        }
    }
    
    func degreesToRadians(degrees: Double) -> CGFloat {
        return CGFloat(degrees * M_PI / 180.0)
    }
    func radiansToDegrees(radians: Double) -> CGFloat {
        return CGFloat(radians / M_PI * 180.0)
    }
    //MARK: class RedBlockViewController: UIViewController {
    @IBOutlet weak var viewForTransformLayer: UIView!

    lazy var sideLength:CGFloat = {
        return self.viewForTransformLayer.bounds.width //block side
    }()
    var transformLayer: CATransformLayer!
    let swipeMeTextLayer = CATextLayer()
    var trackBall: TrackBall?
    // MARK: - Quick reference
    func setUpSwipeMeTextLayer() {
        swipeMeTextLayer.frame = CGRect(x: 0.0, y: sideLength / 4.0, width: sideLength, height: sideLength / 2.0)
        swipeMeTextLayer.string = "Red\r Block"
        swipeMeTextLayer.alignmentMode = kCAAlignmentCenter
        swipeMeTextLayer.foregroundColor = UIColor.blueColor().CGColor
        let fontName = "ArialMT" as CFString
        let fontRef = CTFontCreateWithName(fontName, 10.0, nil)
        swipeMeTextLayer.font = fontRef
        swipeMeTextLayer.contentsScale = UIScreen.mainScreen().scale
    }
    // MARK: - Helpers
    func buildCube() {
        transformLayer = CATransformLayer()
        if Settings().redBlockOn {
            self.viewForTransformLayer.alpha = 1
            
            let cr: CGFloat = cornerRadius //from bricks
            let opacity: CGFloat = 0.1
            var layer = sideLayerWithColor(UIColor.redColor().colorWithAlphaComponent(opacity))
            layer.cornerRadius = cr
            layer.addSublayer(swipeMeTextLayer) //Red Block
            transformLayer.addSublayer(layer)
            
            layer = sideLayerWithColor(UIColor.random.colorWithAlphaComponent(opacity))
            layer.cornerRadius = cr
            var transform = CATransform3DMakeTranslation(sideLength / 2.0, 0.0, sideLength / -2.0)
            transform = CATransform3DRotate(transform, degreesToRadians(90.0), 0.0, 1.0, 0.0)
            layer.transform = transform
            transformLayer.addSublayer(layer)
            
            layer = sideLayerWithColor(UIColor.random.colorWithAlphaComponent(opacity))
            layer.cornerRadius = cr
            layer.transform = CATransform3DMakeTranslation(0.0, 0.0, -sideLength)
            transformLayer.addSublayer(layer)
            
            layer = sideLayerWithColor(UIColor.random.colorWithAlphaComponent(opacity))
            layer.cornerRadius = cr
            transform = CATransform3DMakeTranslation(sideLength / -2.0, 0.0, sideLength / -2.0)
            transform = CATransform3DRotate(transform, degreesToRadians(90.0), 0.0, 1.0, 0.0)
            layer.transform = transform
            transformLayer.addSublayer(layer)
            
            layer = sideLayerWithColor(UIColor.random.colorWithAlphaComponent(opacity))
            layer.cornerRadius = cr
            transform = CATransform3DMakeTranslation(0.0, sideLength / -2.0, sideLength / -2.0)
            transform = CATransform3DRotate(transform, degreesToRadians(90.0), 1.0, 0.0, 0.0)
            layer.transform = transform
            transformLayer.addSublayer(layer)
            
            layer = sideLayerWithColor(UIColor.random.colorWithAlphaComponent(opacity))
            layer.cornerRadius = cr
            transform = CATransform3DMakeTranslation(0.0, sideLength / 2.0, sideLength / -2.0)
            transform = CATransform3DRotate(transform, degreesToRadians(90.0), 1.0, 0.0, 0.0)
            layer.transform = transform
            transformLayer.addSublayer(layer)
            
            transformLayer.anchorPointZ = sideLength / -2.0
            viewForTransformLayer.layer.addSublayer(transformLayer)
        }
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
        case "Brown": return UIColor.brownColor()
        case "DarkGray": return UIColor.darkGrayColor()
        case "LightGray": return UIColor.lightGrayColor()
        case "Cyan": return UIColor.cyanColor()
        case "White": return UIColor.whiteColor()
        case "Clear": return UIColor.clearColor()
        default: return UIColor.blackColor()
        }
    }
    class func scoreForColor(sel: UIColor) -> Int {
        let pwm = Double(Settings().paddleWidthMultiplier)
        var numerator = 1.0
        if model.hasPrefix("iPad") {
            numerator = 2.0
        }
        switch sel {
        case UIColor.greenColor(): return Int(round(5 * numerator / pwm))
        case UIColor.blueColor(): return Int(round(10 * numerator / pwm))
        case UIColor.orangeColor(): return Int(round(15 * numerator / pwm))
        case UIColor.redColor(): return Int(round(20 * numerator / pwm))
        case UIColor.purpleColor(): return Int(round(25 * numerator / pwm))
        case UIColor.yellowColor(): return Int(round(30 * numerator / pwm))
        case UIColor.brownColor(): return Int(round(35 * numerator / pwm))
        case UIColor.darkGrayColor(): return Int(round(40 * numerator / pwm))
        case UIColor.lightGrayColor(): return Int(round(45 * numerator / pwm))
        case UIColor.cyanColor(): return Int(round(50 * numerator / pwm))
        case UIColor.whiteColor(): return Int(round(55 * numerator / pwm))
        case UIColor.clearColor(): return Int(round(60 * numerator / pwm))
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
        default: return UIColor.clearColor()
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

private extension String {
    static func randomBom() -> String {
        let names = ["bom",
            "trophy75",
            "pointLeft75",
            "109px-Coin_Artwork_-_Super_Mario_3D_World",
            "happy160",
            "no210",
            "sun135",
            "u5",
            "u6",
            "u28",
            "u36",
            "u37",
            "u38",
            "u39",
            "u44",
            "u70",
            "u73",
            "u75",
            "u76",
            "u77",
            "u79",
            "u95",
            "u104",
            "u117",
            "u120",
            "u138",
            "u139",
            "u141",
            "u148",
            "u152",
            "u154",
            "u173",
            "u192",
            "u198",
            "u219",
            "u222",
            "u225",]
        let randomIndex = Int(arc4random_uniform(UInt32(names.count)))
        return names[randomIndex]
    }
}