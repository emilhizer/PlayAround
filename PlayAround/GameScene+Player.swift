//
//  GameScene+Player.swift
//  PlayAround
//
//  Created by Eric Milhizer on 11/27/17.
//  Copyright © 2017 Eric Milhizer. All rights reserved.
//

import Foundation
import SpriteKit


extension GameScene {
  
  func setupPlayer() {
    // Get the Player
    if let findPlayer = childNode(withName: "Player") as? SKSpriteNode {
      print("Found Player")
      thePlayer = findPlayer
      
      // at least one physics body must by dynamic to detect collisions and contact
      thePlayer.physicsBody!.isDynamic = true
      thePlayer.physicsBody!.affectedByGravity = false
      
      thePlayer.physicsBody!.categoryBitMask = BodyType.Player
      thePlayer.physicsBody!.collisionBitMask =
        BodyType.Castle
      // If collision bitmask is set, then contact may be redundant
      // See the ContactDelegate tests
      thePlayer.physicsBody!.contactTestBitMask =
        BodyType.Building |
        BodyType.Castle
    } // thePlayer
  } // setupPlayer

  // Move player down
  func move(withXAmount xAmount: CGFloat, andYAmount yAmount: CGFloat, andSpriteAnimation spriteAction: String) {
    
    // enable the little wind to impact the player
    //    thePlayer.physicsBody?.isDynamic = true
    //    thePlayer.physicsBody?.affectedByGravity = true
    
    let wait = SKAction.wait(forDuration: 0.05)
    
    let walkAnimation = SKAction(named: spriteAction, duration: moveSpeed)!
    let moveAction = SKAction.moveBy(x: xAmount,
                                     y: yAmount,
                                     duration: moveSpeed)
    let group = SKAction.group([walkAnimation,
                                moveAction])
    group.timingMode = .easeInEaseOut
    
    let finish = SKAction.run {
      print("Finish")
      // reset play to NOT be affected by wind
      //      self.thePlayer.physicsBody?.isDynamic = false
      //      self.thePlayer.physicsBody?.affectedByGravity = false
    }
    
    let sequence = SKAction.sequence([
      wait,
      group,
      finish])
    
    thePlayer.run(sequence)
  }

  // Player attack
  func attack() {
    let newAttack = AttackArea(imageNamed:"AttackCircle")
    newAttack.position = thePlayer.position
    newAttack.setup()
    newAttack.zPosition = thePlayer.zPosition - 1
    addChild(newAttack)
    
    thePlayer.run(SKAction(named: "FrontAttack")!)
  } // attack

  
  
  
} // GameScene+Player







