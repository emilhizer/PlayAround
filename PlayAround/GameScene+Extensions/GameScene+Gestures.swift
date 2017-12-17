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
    
    tapRec.addTarget(self, action: #selector(tappedView))
    tapRec.numberOfTouchesRequired = 1
    tapRec.numberOfTapsRequired = 1
    view?.addGestureRecognizer(tapRec)
  } // setupGestures

  
  // Tapped
  @objc func tappedView() {
    print("Tapped")
    if !disableAttack {
      attack()
    }
  }
  
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





