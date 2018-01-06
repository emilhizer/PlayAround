//
//  GameScene+Gestures.swift
//  PlayAround
//
//  Created by Eric Milhizer on 11/27/17.
//  Copyright © 2017 Eric Milhizer. All rights reserved.
//

import Foundation
import SpriteKit


extension GameScene {
  
  func setupGestures() {
    /* No longer using swipe gestures
    swipeRightRec.addTarget(self, action: #selector(swipedRight))
    swipeRightRec.direction = .right
    view?.addGestureRecognizer(swipeRightRec)
    
    swipeLeftRec.addTarget(self, action: #selector(swipedLeft))
    swipeLeftRec.direction = .left
    view?.addGestureRecognizer(swipeLeftRec)
    
    swipeUpRec.addTarget(self, action: #selector(swipedUp))
    swipeUpRec.direction = .up
    view?.addGestureRecognizer(swipeUpRec)
    
    swipeDownRec.addTarget(self, action: #selector(swipedDown))
    swipeDownRec.direction = .down
    view?.addGestureRecognizer(swipeDownRec)
    
    rotateRec.addTarget(self, action: #selector(rotatedView(_:)))
    view?.addGestureRecognizer(rotateRec)
    */
    
    /* No longer using tap gestures
    // Single tap for melee attack
    tapRec.addTarget(self, action: #selector(tappedView(_:)))
    tapRec.numberOfTouchesRequired = 1
    tapRec.numberOfTapsRequired = 1
    view?.addGestureRecognizer(tapRec)

    // Double tap for projectile (ranged) attack
    doubleTapRec.addTarget(self, action: #selector(doubleTappedView(_:)))
    doubleTapRec.numberOfTouchesRequired = 1
    doubleTapRec.numberOfTapsRequired = 2
    view?.addGestureRecognizer(doubleTapRec)
    */
  } // setupGestures

  
  // Tapped
  @objc func tappedView(_ sender: UITapGestureRecognizer) {
    let viewPoint = sender.location(in: view)
    let gsPoint = convertPoint(fromView: viewPoint)
//    print("Tapped location in view: \(viewPoint)")
//    print("Tapped location in GameScene: \(gsPoint)")
    if !disableAttack {
      if attackAnywhere {
        attack()
      } else {
//        if viewPoint.x > (view!.bounds.width / 2) {
        if gsPoint.x > 0 {
          attack()
        }
      }
    }
  } // tappedView
  
  // Double tapped
  @objc func doubleTappedView(_ sender: UITapGestureRecognizer) {
    var proceedToAttack = false
    let viewPoint = sender.location(in: view)
    let gsPoint = convertPoint(fromView: viewPoint)

    if !disableAttack {
      if attackAnywhere || (gsPoint.x > 0) {
        proceedToAttack = true
      }
    }

    if proceedToAttack {
      if thePlayer.currentProjectileName != "" {
        
        if prevProjectileName == thePlayer.currentProjectileName {
          print("-- Reusing Projectile: \(prevProjectileName)")
          rangedAttack(withProjectile: prevProjectile)

        } else {
          if let currentProjectile = projectiles[thePlayer.currentProjectileName] as? [String: Any] {
            print("-- Found Projectile: \(currentProjectile)")
            prevProjectileName = thePlayer.currentProjectileName
            prevProjectile = currentProjectile
            if let value = currentProjectile["Image"] as? String {
              prevProjectileImageName = value
            }
            rangedAttack(withProjectile: prevProjectile)
          } // Found projectile
        }
        
      } // Has currentProjectile
    } // Proceed to attack
    
  } // doubleTappedView
  
  // Rotated
  @objc func rotatedView(_ sender: UIRotationGestureRecognizer) {
    switch sender.state {
    case .began:
      print("rotation began")
    case .changed:
      print("rotation changed")
      //      print(sender.rotation)
      
      let rotateAmount = Measurement(value: Double(sender.rotation),
                                     unit: UnitAngle.radians).converted(to: .degrees).value
      print(rotateAmount)
      
      thePlayer.zRotation = -sender.rotation
      
    case .ended:
      print("rotation ended")
    default:
      print("rotation unknown")
    }
  }
  
  // Swiped Right
  @objc func swipedRight() {
    print("Swiped Right")
    move(withXAmount: 100,
         andYAmount: 0,
         andSpriteAnimation: "WalkRight")
  } // swipedRight
  
  // Swiped Left
  @objc func swipedLeft() {
    print("Swiped Left")
    move(withXAmount: -100,
         andYAmount: 0,
         andSpriteAnimation: "WalkLeft")
  } // swipedLeft
  
  // Swiped Up
  @objc func swipedUp() {
    print("Swiped Up")
    move(withXAmount: 0,
         andYAmount: 100,
         andSpriteAnimation: "WalkBack")
  } // swipedUp
  
  // Swiped Down
  @objc func swipedDown() {
    print("Swiped Down")
    move(withXAmount: 0,
         andYAmount: -100,
         andSpriteAnimation: "WalkFront")
  } // swipedDown
  
  // Required when changing scenes
  // If different scenes have different gesture recognizers
  // Call before presenting a new scene
  func cleanUp() {
    for gesture in (view?.gestureRecognizers)! {
      view?.removeGestureRecognizer(gesture)
    }
  } // cleanUp
  
  
  
} // GameScene+Gestures





