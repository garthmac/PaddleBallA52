//
//  CAEmitterLayerViewController.swift
//  LayerPlayer
//
//  Created by iMac21.5 on 9/9/15. from Scott Gardner tutorial
//  Copyright (c) 2015 Garth MacKenzie. All rights reserved.
//

import UIKit

func degreesToRadians(degrees: Double) -> CGFloat {
    return CGFloat(degrees * M_PI / 180.0)
}

func radiansToDegrees(radians: Double) -> CGFloat {
    return CGFloat(radians / M_PI * 180.0)
}

class CAEmitterLayerViewController: UIViewController {
  
  var viewForEmitterLayer: UIView?
    
  var emitterLayer = CAEmitterLayer()
  var emitterCell = CAEmitterCell()
  
  // MARK: - Quick reference
  
  func setUpEmitterLayer() {
    if viewForEmitterLayer != nil {
        emitterLayer.frame = viewForEmitterLayer!.bounds
        emitterLayer.seed = UInt32(NSDate().timeIntervalSince1970)
        emitterLayer.emitterPosition = CGPoint(x: CGRectGetMidX(viewForEmitterLayer!.bounds) * 1.0, y: CGRectGetMidY(viewForEmitterLayer!.bounds) * -1.0 )
    }
  }
    
  func setUpEmitterCell() {
    let randomIndex = Int(arc4random_uniform(UInt32(ShopViewController().ballSkins.count)))
    emitterCell.enabled = true
    emitterCell.contents = UIImage(named: ShopViewController().ballSkins[randomIndex])?.CGImage
    emitterCell.contentsRect = CGRect(origin: CGPointZero, size: CGSize(width: 1, height: 1))
    emitterCell.color = UIColor(hue: 0.0, saturation: 0.0, brightness: 0.1, alpha: 0.05).CGColor
    emitterCell.redRange = 1.0
    emitterCell.greenRange = 1.0
    emitterCell.blueRange = 1.0
    emitterCell.alphaRange = 0.0
    emitterCell.redSpeed = 0.0
    emitterCell.greenSpeed = 0.0
    emitterCell.blueSpeed = 1.0
    emitterCell.alphaSpeed = 1.0
    emitterCell.scale = 1.0
    emitterCell.scaleRange = 0.0
    emitterCell.scaleSpeed = 0.1
    
    let zeroDegreesInRadians = degreesToRadians(0.0)
    emitterCell.spin = degreesToRadians(130.0)
    emitterCell.spinRange = zeroDegreesInRadians
    emitterCell.emissionLatitude = zeroDegreesInRadians
    emitterCell.emissionLongitude = zeroDegreesInRadians
    emitterCell.emissionRange = degreesToRadians(360.0)
    
    emitterCell.lifetime = 2.0
    emitterCell.lifetimeRange = 0.0
    emitterCell.birthRate = 2.0
    emitterCell.velocity = 50.0
    emitterCell.velocityRange = 500.0
    emitterCell.xAcceleration = 0.0
    emitterCell.yAcceleration = 0.0
  }
  
  // MARK: - View life cycle
  
//  override func viewDidAppear(animated: Bool) {
//    super.viewDidAppear(animated)
//    setUpEmitterCell()
//    resetEmitterCells()
//    setUpEmitterLayer()
//    viewForEmitterLayer.layer.addSublayer(emitterLayer)
//  }
  
//  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//    if let identifier = segue.identifier {
//      switch identifier {
//      case "DisplayEmitterControls":
//        emitterLayer.renderMode = kCAEmitterLayerAdditive
//        let controller = segue.destinationViewController as! CAEmitterLayerControlsViewController
//        controller.emitterLayerViewController = self
//      default:
//        break
//      }
//    }
//  }
  
  // MARK: - Triggered actions
  
//  override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
//    if let touch = touches.first as? UITouch {
//        let location = touch.locationInView(viewForEmitterLayer)
//        emitterLayer.emitterPosition = location
//    }
//  }
//  
//    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
//        if let touch = touches.first as? UITouch {
//            let location = touch.locationInView(viewForEmitterLayer)
//            emitterLayer.emitterPosition = location
//    }
//  }
  
  // MARK: - Helpers
  
  func resetEmitterCells() {
    emitterLayer.emitterCells = nil
    emitterLayer.emitterCells = [emitterCell]
  }
  
}
