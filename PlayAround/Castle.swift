//
//  Castle.swift
//  PlayAround
//
//  Created by Eric Milhizer on 11/23/17.
//  Copyright © 2017 Eric Milhizer. All rights reserved.
//

import Foundation
import SpriteKit


class Castle: SKSpriteNode {
  
  var dudesInCastle = 0
  
  func setupCastle() {
    physicsBody?.categoryBitMask = BodyType.Castle
    physicsBody?.collisionBitMask = BodyType.Player
    physicsBody?.contactTestBitMask = BodyType.Player
    
    print("Setup Castle")
  }
  
  
  
} // Castle







