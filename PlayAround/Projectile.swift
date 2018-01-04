//
//  Projectile.swift
//  PlayAround
//
//  Created by Eric Milhizer on 12/19/17.
//  Copyright © 2017 Eric Milhizer. All rights reserved.
//

import Foundation
import SpriteKit


class Projectile: SKSpriteNode {
  
  var travelTime = TimeInterval(1)
  var rotationTime = TimeInterval(0)
  var distance = CGFloat(0)
  var removeAfterThrow = true

  
  func setup(withDict dict: [String: Any]) {
    print("  -- Setting up projectile with dict: \(dict)")
    
    // Setup physics body
    let body = SKPhysicsBody(texture: texture!, size: texture!.size())
    physicsBody = body
    
    body.isDynamic = true
    body.affectedByGravity = false
    body.allowsRotation = false
    
    physicsBody?.categoryBitMask = BodyType.Projectile
    physicsBody?.collisionBitMask = 0 // nothing
    physicsBody?.contactTestBitMask = BodyType.Enemy | BodyType.Player
    
    // Setup Projectile properties from give dictionary
    if let value = dict["TravelTime"] as? TimeInterval {
      travelTime = value
    }
    if let value = dict["RotationTime"] as? TimeInterval {
      rotationTime = value
    }
    if let value = dict["Distance"] as? CGFloat {
      distance = value
    }
    if let value = dict["Remove"] as? Bool {
      removeAfterThrow = value
    }

    

  } // setup
  
  
  
} // Projectile





