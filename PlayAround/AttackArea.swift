//
//  AttackArea.swift
//  PlayAround
//
//  Created by Eric Milhizer on 11/24/17.
//  Copyright © 2017 Eric Milhizer. All rights reserved.
//

import Foundation
import SpriteKit


class AttackArea: SKSpriteNode {
  
  var animationName = ""
  var scaleSize = CGFloat(2)
  
  func setup() {
    
    name = "AttackArea"
    
    let attackBody = SKPhysicsBody(circleOfRadius: frame.size.width / 2)
    physicsBody = attackBody
    
    attackBody.isDynamic = true
    attackBody.affectedByGravity = false
    attackBody.allowsRotation = false
    
    physicsBody?.categoryBitMask = BodyType.AttackArea
    physicsBody?.collisionBitMask = 0 // collides with nothing
    physicsBody?.contactTestBitMask = 0 // contacts nothing
    
    print("Setup Attack Area")
    
    upAndAway()
    
    if animationName != "" {
      run(SKAction(named: animationName)!)
    }
  } // setup

  func upAndAway() {
    
    let grow = SKAction.scale(by: scaleSize, duration: 0.5)
    let finish = SKAction.run {
      self.removeFromParent()
    }
    
    let seq = SKAction.sequence([grow, finish])
    
    run(seq)
    
  } // upAndAway
  
  
  
  
} // AttackArea





