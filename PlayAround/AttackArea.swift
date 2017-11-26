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
  
  func setup() {
    
    name = "AttackArea"
    
    let attackBody = SKPhysicsBody(circleOfRadius: frame.size.width / 2)
    physicsBody = attackBody
    
    attackBody.isDynamic = true
    attackBody.affectedByGravity = false
    attackBody.allowsRotation = false
    
    physicsBody?.categoryBitMask = BodyType.AttackArea
    physicsBody?.collisionBitMask = 0 // collides with nothing
    physicsBody?.contactTestBitMask = BodyType.Castle
    
    print("Setup Attack Area")
    
    upAndAway()
    
    run(SKAction(named: "Attacking")!)
  }

  func upAndAway() {
    
    let grow = SKAction.scale(by: 3, duration: 0.5)
    let finish = SKAction.run {
      self.removeFromParent()
    }
    
    let seq = SKAction.sequence([grow, finish])
    
    run(seq)
    
  }
  
  
  
  
} // AttackArea





