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
    private var ballSpeed: Float { // a computed property instead of func
        get { if model.hasPrefix("iPad") {
                return 1.5
            }
            return 1.0
        }
        set { self.ballSpeed = newValue }
    }
    private var breakout = BreakoutBehavior()
    private var cornerRadius = Constants.BrickCornerRadius
    // MARK: - scoring
    private var msg: String { // a computed property instead of func
        get { if self.newHighScoreAchieved {
                Settings().highScore = self.score
                return "#\(self.tier)  New High Score!    "
            }
            return "#\(self.tier)    "
        }
        set { self.msg = newValue }
    }
    private var score: Int = 0
    private var newHighScoreAchieved: Bool { // a computed property instead of func
        get { if Settings().highScoreOn {
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
        set { let shopTabBarItem = tabBarController!.tabBar.items![0] 
            shopTabBarItem.badgeValue = "\(newValue)"
            Settings().availableCredits = newValue }
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
        self.coinCount += 1
        if self.coinCount % 3 == 0 {  //move first because of annimation delay
            self.availableCredits += 1
        }
        //prepare for annimation
        largeCoin.image = UIImage(named: "1000CreditsSWars1.png")
        largeCoin.alpha = 1
        largeCoin.center.y = gameView.bounds.minY //move off screen but alpha = 1
        UIView.animateWithDuration(3.0, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.0, options: [], animations: {
            self.resetPaddleAndScoreBoard()
            self.largeCoin.alpha = 0
            }, completion: nil)
        //prepare for annimation
        coinCountLabel.alpha = 0
        coinCountLabel.center.y = gameView.bounds.maxY //move off screen
        let images = (0...2).map {
            UIImage(named: "1000Credits\($0)-20.png") as! AnyObject
        }
        if let image = images[min(coinCount - 1, 2)] as? UIImage {
            coins.image = image
            coins.alpha = 0
            coins.center.y = gameView.bounds.maxY //move off screen
            UIView.animateWithDuration(4.0, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.0, options: [], animations: {
                self.coinCountLabel.text = self.coinCount.addSeparator
                self.resetPaddleAndScoreBoard()
                self.coins.alpha = 1
                self.coinCountLabel.alpha = 1
                }, completion: nil)
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
        case 6: path = NSBundle.mainBundle().pathForResource("Phil Wickham - This Is Amazing Grace", ofType: "mp3")
        case 7: path = NSBundle.mainBundle().pathForResource("Hillsong United - No Other Name - Oceans (Where Feet May Fail)", ofType: "mp3")
        case 8: path = NSBundle.mainBundle().pathForResource("Phil Wickham - At Your Name (Yahweh, Yahweh)", ofType: "mp3")
        case 9: path = NSBundle.mainBundle().pathForResource("Yusuf Islam - Peace Train - OUTSTANDING!-2", ofType: "mp3")
        case 10: path = NSBundle.mainBundle().pathForResource("Titans Spirit(Remember The Titans)-Trevor Rabin", ofType: "mp3")
        default: path = NSBundle.mainBundle().pathForResource("jazzloop2_70", ofType: "mp3")
        }
        let url = NSURL.fileURLWithPath(path!)
        audioPlayer = try? AVAudioPlayer(contentsOfURL: url)
        audioPlayer.delegate = self
        audioPlayer.numberOfLoops = 99 //-1 means continuous
        audioPlayer.prepareToPlay()
    }
    private var tier: Int { // a computed property instead of func
        get { return Settings().tier }
        set { Settings().tier = newValue }
    }
    private var failedTier = 0
    // MARK: - Constants
    struct Constants {
        static let BallSize: CGFloat = 40.0
//        static let BallColor = "Yellow"
        static let BoxPathName = "Box"
        static let CourtColor = "Clear"
//        static let PaddleColor = "Green"
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
        static let MaxScore = 999999
        static let EditImageSegue = "Edit Image"
        static let ReturnImageSegue = "Back to LeaderBoard"
        static let UserId = "User.Login"
//        static let BrickColors = [UIColor.greenColor(), UIColor.blueColor(), UIColor.redColor(), UIColor.yellowColor()]
    }
    func printFonts() {
        let fontFamilyNames = UIFont.familyNames()
        for familyName in fontFamilyNames {
            print("------------------------------")
            print("Font Family Name = [\(familyName)]")
            let names = UIFont.fontNamesForFamilyName(familyName )
            print("Font Names = [\(names)]")
        }
    }
    // MARK: emitterLayerViewController
    var emitterLayerViewController: CAEmitterLayerViewController!
    var emitterLayer: CAEmitterLayer {
        return emitterLayerViewController.emitterLayer
    }
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        Settings().endLevelBonus = 0
        //printFonts()
        prepareAudios()
        self.hidesBottomBarWhenPushed = true
        animator.addBehavior(breakout)
        Settings(defaultColumns: Constants.BrickColumns, defaultRows: Constants.BrickColumns / 2, defaultBalls: Settings().balls, defaultDifficulty: Settings().difficulty, defaultSpeed: ballSpeed, defaultBallColor: Settings().ballColor, defaultCourtColor: Settings().courtColor, defaultPaddleColor: Settings().paddleColor, defaultPaddleWidthMultiplier: Settings().paddleWidthMultiplier, defaultTier: 1)
        emitterLayerViewController = CAEmitterLayerViewController()
        emitterLayer.renderMode = kCAEmitterLayerAdditive
        emitterLayerViewController.viewForEmitterLayer = powerBallScoreBoard  //changeCourtColor
        gameView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "pushBall:"))
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
        let settingsTabBarItem = tabBarController!.tabBar.items![2] 
        settingsTabBarItem.badgeValue = nil  //reset for paddle purchaces
        let shopTabBarItem = tabBarController!.tabBar.items![0] 
        if availableCredits == 0 {
            shopTabBarItem.badgeValue = nil
        } else {
            shopTabBarItem.badgeValue = "\(availableCredits)"
        }
        //Settings().type stuff set here!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        changeCourtColor()
        breakout.speed = CGFloat(Settings().speed)
        breakout.ballBehavior.allowsRotation = Settings().ballRotation
        let pw = Settings().paddleWidthMultiplier
        paddleSize = CGSize(width: (CGFloat(pw) * Constants.BallSize), height: 20.0)
        paddle.frame.size = paddleSize
        paddle.layer.backgroundColor = UIColor.colorFor(Settings().paddleColor).CGColor
        paddle.layer.contents = UIImage(named: Settings().myPaddles.last!)!.CGImage
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
        for (_, brick) in bricks {
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
        //remove the timer when a game hides, and start it again afterwards...
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
        if (Constants.MaxBalls + extraBall) >= ballCounter {
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
    lazy var loggedInUser: User = {
        return User.login(self.uid, password: "foo")
    }()
    func createBall() -> UIView {
        let paddleBallTabBarItem = tabBarController!.tabBar.items![1] 
        if paddleBallTabBarItem.badgeValue != nil {
            loggedInUser = User.login(paddleBallTabBarItem.badgeValue!, password: "foo") //new ball purchased
            Settings().purchasedUid = loggedInUser.login
            paddleBallTabBarItem.badgeValue = nil
        }
        let ballSize = CGSize(width: Constants.BallSize, height: Constants.BallSize)
        let ball = UIView(frame: CGRect(origin: CGPoint.zero, size: ballSize))
        if loggedInUser.login != Settings().purchasedUid && powerBall == 1 {
            loggedInUser = User.login(Settings().purchasedUid!, password: "foo") //keep using new ball
        } else if powerBall == 3 {
            ball.layer.backgroundColor = UIColor.colorFor(Settings().ballColor).CGColor
            ball.layer.contentsGravity = kCAGravityCenter
        }
        ball.layer.contents = loggedInUser.image!.CGImage
        ball.layer.contentsScale = 2.0
        //println(Settings().purchasedUid)
        if Settings().purchasedUid!.isEmpty || ( Settings().purchasedUid == "baddie" ) {
            ball.layer.backgroundColor = UIColor.colorFor(Settings().ballColor).CGColor
            ball.layer.borderColor = UIColor.blackColor().CGColor
            ball.layer.borderWidth = 2.0
        }
        ball.layer.cornerRadius = Constants.BallSize / 2.0
        ball.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        ball.layer.shadowOpacity = 0.5
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
    private var extraBall = 0
    func pushBall(gesture: UITapGestureRecognizer) { //*** lots happening here!
        if gesture.state == .Ended {
            if ((ballCounter > (Constants.MaxBalls + extraBall)) && breakout.balls.count == 0) ||
                    (ballCounter - (Constants.MaxBalls + extraBall) > 1) {  //multiple balls at ounce only
                levelFinished()
            } else if breakout.balls.count < Settings().balls &&
                    (ballCounter <= (Constants.MaxBalls + extraBall)) {  //multiple balls at ounce only
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
        if tier <= 14 || (tier % 2 == 0) {
            brick.backgroundColor = UIColor.random
            if model.hasPrefix("iPad") || Settings().columns < 10 { //can't read values on iPhone
                brick.setTitleColor(UIColor.blackColor(), forState: .Normal) //hides well
                brick.setTitle("\(UIColor.scoreForColor(brick.backgroundColor!))", forState: .Normal)
                brick.titleLabel!.font = UIFont(name: "ComicSansMS", size: 12.0)
            }
        } else {
            brick.backgroundColor = UIColor.randomImage   //game extension
        }
    }
    func changeBrickColor(timer: NSTimer) { //only if overlayed with black
        if let brick = timer.userInfo as? UIButton {
            UIView.animateWithDuration(0.5, animations: { [weak self] in
                self!.prepareBrick(brick)
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
    func collisionBehavior(behavior: UICollisionBehavior, beganContactForItem item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?, atPoint p: CGPoint) {
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
                self.bonus(Int(500 / Settings().paddleWidthMultiplier) * powerBall)
            } else {
                self.score += UIColor.scoreForColor(brick.view.backgroundColor!) * self.powerBall
                self.showScore()
            }
            UIView.transitionWithView(brick.view, duration: 0.3, options: trans, animations: {
                brick.view.alpha = 0.8
                }, completion: { [weak self] (success) -> Void in
                    self!.breakout.addBrick(brick.view)
                    UIView.animateWithDuration(1.5, animations: {  //1.0
                        brick.view.alpha = 0.0  //disappear
                        }, completion: { [weak self] (success) -> Void in
                            self!.breakout.removeBrick(brick.view)
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
    func bonus(amount: Int) { //annimated eg. hit a bom or ball bonus
        bonusScore = amount
        showBonusScore(true)
        score += bonusScore
        //showScore()  wait until next hit
        bonusScore = 0
    }
    func showBonusScore(isBonus: Bool) {
        if isBonus {
            scoreBoard.alpha = 0    //prepare for annimation
            scoreBoard.center.y = 0
            scoreBoard.text = "Bonus!   " + bonusScore.addSeparator
            UIView.animateWithDuration(2.0, delay: 0.0, usingSpringWithDamping: 0.2, initialSpringVelocity: 0.0, options: [], animations: {
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
    
    func levelFinished() {
        for ball in breakout.balls {
            breakout.removeBall(ball)
        }
        let leftover = Constants.MaxBalls + 1 - ballCounter  //penalty for extraBall
        let ballBonus = 500 * leftover / Settings().paddleWidthMultiplier * powerBall
        //bonus(ballBonus)  //unused ball bonus - don't use because of annimation
        score += ballBonus
        showScore()  //will be annimated in next step
        if newHighScoreAchieved {
            Settings().highScore = score
            Settings().highScoreDate = timestamp
        }
        // MARK: - animate PowerBall Achieved!
        if ballCounter == 1 {
            powerBall = 3 //triple score multiplier until removed
            loggedInUser = User.login("japple", password: "foo") //bubble ball
            earnCoin()  //annimated
            powerBallScoreBoard.text = "PowerBall 3X!"
            powerBallScoreBoard.alpha = 0    //prepare for annimation
            powerBallScoreBoard.center.x = 0
            UIView.animateWithDuration(4.0, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.0, options: [], animations: {
                self.resetPaddleAndScoreBoard()
                self.powerBallScoreBoard.alpha = 1
                }, completion: nil)
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
        if powerBall == 3 || score > 10000 {  //levelFinished post bonus/pre continue...above powerBall msg
            if powerBall == 3 && self.coinCount % 3 == 0 { //3rd coin
                scoreBoard.text = "+1 SHOP Credit"
            }
            else {
                if score > 10000 {
                    let testForBonus = score/10000
                    if testForBonus > Settings().endLevelBonus {
                        Settings().endLevelBonus += 1
                        earnCoin()  //annimated
                        if powerBall == 1 { //only show if new coin wasn't 3rd coin
                            scoreBoard.text = "+10k COIN added"
                        }
                    }
                }  //side effect...existing score is annimated if +=10k not reached and shop credit not attained
            }
            scoreBoard.font = UIFont(name: "ComicSansMS-Bold", size: 30.0)    //prepare for annimation
            scoreBoard.textColor = UIColor.redColor()
            UIView.animateWithDuration(2.0, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.0, options: [], animations: {
                self.scoreBoard.center = CGPoint(x: self.scoreBoard.center.x, y: (self.gameView.bounds.midY - (self.gameView.bounds.midY / 2.0) ) )
                }, completion: { [weak self] (success) -> Void in
                    UIView.animateWithDuration(2.5, animations: {
                        self!.resetPaddleAndScoreBoard()
                        self!.scoreBoard.alpha = 0  //disappear
                        }, completion: { [weak self] (success) -> Void in
                            self!.scoreBoard.font = UIFont(name: "ComicSansMS-Bold", size: 18.0)
                            self!.scoreBoard.alpha = 1
                    })
            })
        }
        var title = "Game Over!", message = "Try Again...", cancelButtonTitle = "Restart?"
        if (tier % 14) == 0 && bricks.count == 0 {
            title = "Set Complete"
            if score > Constants.MaxScore {  //game extension
                message = "You Won!!!"
                cancelButtonTitle = "Restart..."
            } else {
                message = "Good Job!!!"
                cancelButtonTitle = "Next Set..."
            }
        }
        // MARK: - game over -> restart
        if (self.tier % 14) == 0 ||   // level 14,28, 42... Set complete
                (ballCounter > Constants.MaxBalls && bricks.count != 0) {  // OR level Unfinished
            if (ballCounter > Constants.MaxBalls && bricks.count != 0) {
                failedTier = tier
            }
            if NSClassFromString("UIAlertController") != nil {
                let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
                alertController.addAction(UIAlertAction(title: cancelButtonTitle, style: .Default, handler: { (action) in  //cancelButtonTitle = "Restart..." or "Next Set..."
                    self.resetWall()
                    self.scoreBoard.text = "" //clear any lingering bonus score
                    self.buildCube()
                    self.ballCounter = 0
                    self.extraBall = 0
                    self.cornerRadius = Constants.BrickCornerRadius
                    if (self.tier % 14) == 0 && self.score < Constants.MaxScore {  //game extension level 15, 29, 43...
                        self.tier += 1
                    } else {
                        Settings().endLevelBonus = 0
                        Settings().courtColor = Constants.CourtColor
                        self.coinCount = 0
                        self.coinCountLabel.text = nil
                        self.coins.image = nil
                        self.score = 0
                        self.tier = 1
                    }
                    //don't reset ball or paddle colors or paddleWidth if user changed them!
                    Settings(defaultColumns: Constants.BrickColumns, defaultRows: Constants.BrickColumns / 2, defaultBalls: Settings().balls, defaultDifficulty: Settings().difficulty, defaultSpeed: self.ballSpeed, defaultBallColor: Settings().ballColor, defaultCourtColor: Settings().courtColor, defaultPaddleColor: Settings().paddleColor, defaultPaddleWidthMultiplier: Settings().paddleWidthMultiplier, defaultTier: self.tier)
                    self.changeCourtColor()
                    if !Settings().autoStart {
                        self.autoStartTimer?.invalidate()
                    }
                    self.levelOne(self.tier)
                }))
                alertController.addAction(UIAlertAction(title: "Quit", style: .Cancel, handler: { (action) in
                    if self.tier > 14 {
                        Settings().courtColor = Constants.CourtColor
                    }
                    exit(0)
                }))
                if (ballCounter > Constants.MaxBalls) && bricks.count != 0 && availableCredits > 9 {
                    alertController.addAction(UIAlertAction(title: "Buy Extra Ball NOW!", style: .Default, handler: { (action) in
                        self.extraBall += 1
                        self.availableCredits -= 10
                        self.resetPaddleAndScoreBoard()
                    }))
                }
                presentViewController(alertController, animated: true, completion: nil)
            } else { exit(0) // for iOS 7
            }
        }
        else {
            failedTier = 0
            if NSClassFromString("UIAlertController") != nil {
                let alertController = UIAlertController(title: "Level Complete!", message: "\(leftover) Leftover Balls \n\n Bonus = " + ballBonus.addSeparator, preferredStyle: .Alert)
                alertController.addAction(UIAlertAction(title: "Play", style: .Default, handler: { (action) in
                    self.replay()
                }))
                alertController.addAction(UIAlertAction(title: "Shop...", style: .Cancel, handler: { (action) in
                    self.replay()
                    self.tabBarController!.selectedIndex = 0
                }))
                presentViewController(alertController, animated: true, completion: nil)
            } else { // for iOS 7
                self.replay()
            }
        }
    }
    func replay() {
        ballCounter = 0
        extraBall = 0
        if failedTier > 0 {
            tier = failedTier
        } else {
            tier += 1
        }
        if self.tier > 1 && Settings().difficulty == 0 {  //disable easy if not paid for
            if Settings().purchasedPWM < 4 {
                Settings().difficulty = 1
                Settings().paddleWidthMultiplier = Settings().purchasedPWM  //1..4
                paddleSize = CGSize(width: (CGFloat(Settings().purchasedPWM) * Constants.BallSize), height: 20.0)
                paddle.frame.size = paddleSize
                alert("Easy is now disabled...", message: "until you buy > 3 paddle widths.")
            }
        }
        showScore()
        changeCourtColor()
        if !Settings().autoStart {
            autoStartTimer?.invalidate()
        }
        levelOne(self.tier)
    }
    func changeCourtColor() {
        emitterLayerViewController.setUpEmitterCell()
        emitterLayerViewController.resetEmitterCells()
        emitterLayerViewController.setUpEmitterLayer()
        emitterLayerViewController.viewForEmitterLayer?.layer.addSublayer(emitterLayer)
        if powerBall == 3 {
            gameView.layer.backgroundColor = UIColor.blackColor().CGColor
            if Settings().redBlockOn { 
                emitterLayerViewController.viewForEmitterLayer?.alpha = 1
            } else {
                emitterLayerViewController.viewForEmitterLayer?.alpha = 0
            }
        } else {
            emitterLayerViewController.viewForEmitterLayer?.alpha = 0
            if tier > 14 {  //game extension
                Settings().courtColor = SettingsViewController().pickerDataSource[tier % 7]
            }
            gameView.layer.backgroundColor = UIColor.colorFor(Settings().courtColor).CGColor
        }
        adjustColors()
    }
    func alert(title: String, message: String) {
        if let _: AnyClass = NSClassFromString("UIAlertController") { // iOS 8
            let myAlert: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
            myAlert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            self.presentViewController(myAlert, animated: true, completion: nil)
        } else { // iOS 7
            let alert: UIAlertView = UIAlertView()
            alert.delegate = self
            alert.title = title
            alert.message = message
            alert.addButtonWithTitle("OK")
            alert.show()
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
            layer.cornerRadius = cr * 1.2
            layer.addSublayer(swipeMeTextLayer) //Red Block
            transformLayer.addSublayer(layer)
            
            layer = sideLayerWithColor(UIColor.random.colorWithAlphaComponent(opacity))
            layer.cornerRadius = cr * 1.2
            var transform = CATransform3DMakeTranslation(sideLength / 2.0, 0.0, sideLength / -2.0)
            transform = CATransform3DRotate(transform, degreesToRadians(90.0), 0.0, 1.0, 0.0)
            layer.transform = transform
            transformLayer.addSublayer(layer)
            
            layer = sideLayerWithColor(UIColor.random.colorWithAlphaComponent(opacity))
            layer.cornerRadius = cr * 1.2
            layer.transform = CATransform3DMakeTranslation(0.0, 0.0, -sideLength)
            transformLayer.addSublayer(layer)
            
            layer = sideLayerWithColor(UIColor.random.colorWithAlphaComponent(opacity))
            layer.cornerRadius = cr * 1.2
            transform = CATransform3DMakeTranslation(sideLength / -2.0, 0.0, sideLength / -2.0)
            transform = CATransform3DRotate(transform, degreesToRadians(90.0), 0.0, 1.0, 0.0)
            layer.transform = transform
            transformLayer.addSublayer(layer)
            
            layer = sideLayerWithColor(UIColor.random.colorWithAlphaComponent(opacity))
            layer.cornerRadius = cr * 1.2
            transform = CATransform3DMakeTranslation(0.0, sideLength / -2.0, sideLength / -2.0)
            transform = CATransform3DRotate(transform, degreesToRadians(90.0), 1.0, 0.0, 0.0)
            layer.transform = transform
            transformLayer.addSublayer(layer)
            
            layer = sideLayerWithColor(UIColor.random.colorWithAlphaComponent(opacity))
            layer.cornerRadius = cr * 1.2
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
    class var randomImage: UIColor {  //game extension
        switch arc4random() % 14 {
        case 0: return UIColor(patternImage: UIImage(named: "pineapple_400.jpg")!)
        case 1: return UIColor(patternImage: UIImage(named: "extension_UIImage.png")!)
        case 2: return UIColor(patternImage: UIImage(named: "IMG_3562.jpg")!)
        case 3: return UIColor(patternImage: UIImage(named: "glory.png")!)
        case 4: return UIColor(patternImage: UIImage(named: "paddle1.jpg")!)
        case 5: return UIColor(patternImage: UIImage(named: "paddle520.jpg")!)
        case 6: return UIColor(patternImage: UIImage(named: "pointLeft75.png")!)
        case 7: return UIColor(patternImage: UIImage(named: "u29ID.png")!)
        case 8: return UIColor(patternImage: UIImage(named: "Icon-60@3x.png")!)
        case 9: return UIColor(patternImage: UIImage(named: "u212Bar.png")!)
        case 10: return UIColor(patternImage: UIImage(named: "84px-Coin_Stack.png")!)
        case 11: return UIColor(patternImage: UIImage(named: "back.png")!)
        case 12: return UIColor(patternImage: UIImage(named: "tiles.png")!)
        case 13: return UIColor(patternImage: UIImage(named: "cyan158.png")!)
        default: return UIColor.clearColor()
        }
    }
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
        default:  //game extension     randomImage values used in tier > 28
            let pwm = Double(Settings().paddleWidthMultiplier)
            var numerator = 1.0
            if model.hasPrefix("iPad") {
                numerator = 2.0
            }
            let int = 5 * (Double(arc4random() % 14) + 1)
            return Int(round(int * numerator / pwm))
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
            "109px-Coin",
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