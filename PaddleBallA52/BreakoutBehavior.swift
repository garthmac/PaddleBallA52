//
//  BreakoutBehavior.swift
//  BallA5
//
//  Created by iMac21.5 on 5/24/15.
//  Copyright (c) 2015 Garth MacKenzie. All rights reserved.
//

import UIKit

class BreakoutBehavior: UIDynamicBehavior {
 
    lazy var collider: UICollisionBehavior = {
        let lazilyCreatedCollider = UICollisionBehavior()
        lazilyCreatedCollider.action = {
            for ball in self.balls {
                if !CGRectIntersectsRect(self.dynamicAnimator!.referenceView!.bounds, ball.frame) {
                    self.removeBall(ball)
                }
            }
        }
        return lazilyCreatedCollider
        }()
    //To detect a collision, the view controller will be the collision delegate of the collision behavior. For style create a computed variable to set the delegate via the public API of the breakout behavior:
    var collisionDelegate: UICollisionBehaviorDelegate? {
        get { return collider.collisionDelegate }
        set { collider.collisionDelegate = newValue }
    }
    lazy var ballBehavior: UIDynamicItemBehavior = {
        let lazilyCreatedBallBehavior = UIDynamicItemBehavior()
        lazilyCreatedBallBehavior.allowsRotation = true
        lazilyCreatedBallBehavior.elasticity = CGFloat(NSUserDefaults.standardUserDefaults().floatForKey("Ball.Elasticity"))
        lazilyCreatedBallBehavior.friction = CGFloat(NSUserDefaults.standardUserDefaults().floatForKey("Ball.Friction"))
        lazilyCreatedBallBehavior.resistance = 0.0
        return lazilyCreatedBallBehavior
        }()
    lazy var paddleBehavior: UIDynamicItemBehavior = {
        let lazilyCreatedPaddleBehavior = UIDynamicItemBehavior()
        lazilyCreatedPaddleBehavior.allowsRotation = false
        lazilyCreatedPaddleBehavior.elasticity = CGFloat(NSUserDefaults.standardUserDefaults().floatForKey("Paddle.Elasticity"))
        lazilyCreatedPaddleBehavior.friction = CGFloat(NSUserDefaults.standardUserDefaults().floatForKey("Paddle.Friction"))
        lazilyCreatedPaddleBehavior.resistance = 0.0
        return lazilyCreatedPaddleBehavior
        }()
//    func addPaddle(paddle: UIView) {
//        dynamicAnimator?.referenceView?.addSubview(paddle)
//        collider.addItem(paddle)
//        paddleBehavior.addItem(paddle)
//    }
//    func removePaddle(paddle: UIView) {
//        collider.removeItem(paddle)
//        paddleBehavior.removeItem(paddle)
//        paddle.removeFromSuperview()
//    }  see addBarrier ...at bottom
    override init() {
        super.init()
        addChildBehavior(collider)
        addChildBehavior(ballBehavior)
        addChildBehavior(paddleBehavior)
        //bricks only
        addChildBehavior(gravity)
    }
    func addBall(ball: UIView) {
        dynamicAnimator?.referenceView?.addSubview(ball)
        collider.addItem(ball)
        ballBehavior.addItem(ball)
    }
    var balls:[UIView] {
        get {
            return collider.items.filter{$0 is UIView}.map{$0 as! UIView}
        }
    }
    func removeBall(ball: UIView) {
        collider.removeItem(ball)
        ballBehavior.removeItem(ball)
        ball.removeFromSuperview()
    }
    //To change the speed of the ball, add var and use it as magnitude when pushing the ball:
    var speed: CGFloat = 1.0
    func pushBall(ball: UIView) {
        let push = UIPushBehavior(items: [ball], mode: .Instantaneous)
        push.magnitude = speed
        push.angle = CGFloat(Double.random)
        push.action = { [weak push] in
            if !push!.active {
                self.removeChildBehavior(push!)
            }
        }
        addChildBehavior(push)
    }
    //Because the name of the barriers for the bricks are identical to their index, the method to add barriers needs a tiny adjustment to allow integer values as name parameter:
    func addBarrier(path: UIBezierPath, named name: NSCopying) {
    //func addBarrier(path: UIBezierPath, named name: String) {
        collider.removeBoundaryWithIdentifier(name)
        collider.addBoundaryWithIdentifier(name, forPath: path)
    }
    func removeBarrier(name: NSCopying) {
        collider.removeBoundaryWithIdentifier(name)
    }
    //And when a brick gets hit let them fall down using gravity:
    let gravity = UIGravityBehavior()
    
    func addBrick(brick: UIView) {
        gravity.addItem(brick)
    }
    func removeBrick(brick: UIView) {
        gravity.removeItem(brick)
    }
}

// MARK: - extensions
private extension Double {
    static var random: Double { //random angle from 10 - 170 degrees in radians
        switch arc4random() % 16 {
        case 0: return M_PI / 18.0
        case 1: return 2.0 * M_PI / 18.0
        case 2: return 3.0 * M_PI / 18.0
        case 3: return 4.0 * M_PI / 18.0
        case 4: return 5.0 * M_PI / 18.0
        case 5: return 6.0 * M_PI / 18.0
        case 6: return 7.0 * M_PI / 18.0
        case 7: return 8.0 * M_PI / 18.0
        case 8: return 9.0 * M_PI / 18.0
        case 9: return 10.0 * M_PI / 18.0
        case 10: return 11.0 * M_PI / 18.0
        case 11: return 12.0 * M_PI / 18.0
        case 12: return 13.0 * M_PI / 18.0
        case 13: return 14.0 * M_PI / 18.0
        case 14: return 15.0 * M_PI / 18.0
        case 15: return 16.0 * M_PI / 18.0
        default: return 17.0 * M_PI / 18.0
        }
    }
}