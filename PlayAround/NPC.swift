//
//  NPC.swift
//  PlayAround
//
//  Created by Eric Milhizer on 11/26/17.
//  Copyright © 2017 Eric Milhizer. All rights reserved.
//

import Foundation
import SpriteKit


class NPC: SKSpriteNode {
  
  var frontName = ""
  var backName = ""
  var leftName = ""
  var rightName = ""
  
  var isWalking = false
  var initialSpeeches = [String]()
  var reminderSpeeches = [String]()
  var alreadyContacted = false
  var infoDisplayTime = TimeInterval(1)
  
  var baseFrame = ""
  
  var currentSpeech = ""
  var speechIcon = ""
  
  var isCollidableWithPlayer = false
  var isCollidableWithItems = false

  

  func setup(withDict dict: [String: Any]) {
    
    // Setup physics
    let npcBody = SKPhysicsBody(circleOfRadius: frame.size.width / 3)
    physicsBody = npcBody
    
    npcBody.isDynamic = true
    npcBody.affectedByGravity = false
    npcBody.allowsRotation = false
    
    physicsBody?.categoryBitMask = BodyType.NPC
    physicsBody?.contactTestBitMask = BodyType.Player
    
    
    for (key, value) in dict {
      if key == "Front" {
        frontName = value as! String
//        run(SKAction(named:frontName)!)
      }
      else if key == "Back" {
        backName = value as! String
        run(SKAction(named:backName)!)
      }
      else if key == "Left" {
        leftName = value as! String
        run(SKAction(named:leftName)!)
      }
      else if key == "Right" {
        rightName = value as! String
        run(SKAction(named:rightName)!)
      }
      else if key == "InitialSpeech" {
        if let value = value as? [String] {
          initialSpeeches = value
        } else if let value = value as? String {
          initialSpeeches = [value]
        }
      }
      else if key == "ReminderSpeech" {
        if let value = value as? [String] {
          reminderSpeeches = value
        } else if let value = value as? String {
          reminderSpeeches = [value]
        }
      }
      else if key == "Icon" {
        if let value = value as? String {
          speechIcon = value
        }
      }
      else if key == "CollidableWithPlayer" {
        if let value = value as? Bool {
          isCollidableWithPlayer = value
        }
      }
      else if key == "CollidableWithItems" {
        if let value = value as? Bool {
          isCollidableWithItems = value
        }
      }
      else if let displayTime = value as? TimeInterval, key == "SpeechTime" {
        infoDisplayTime = displayTime
      }


    } // loop dict
    
    // Collide with attack area and other NPCs
    var collidesWith = BodyType.AttackArea | BodyType.NPC
    
    // Collide with other things based on GameData
    if isCollidableWithPlayer {
      collidesWith |= BodyType.Player
    }
    if isCollidableWithItems {
      collidesWith |= BodyType.Item
    }
    
    physicsBody?.collisionBitMask = collidesWith
    
    walkRandom()
    
  } // setup
  
  func walkRandom() {
    
    let walkDir = arc4random_uniform(4)
    let waitTime = TimeInterval(arc4random_uniform(3))
    var walkDirName = ""
    var moveByX = CGFloat(0)
    var moveByY = CGFloat(0)
    
    switch walkDir {
    case 0:
      walkDirName = frontName
      moveByY = -50
    case 1:
      walkDirName = backName
      moveByY = 50
    case 2:
      walkDirName = leftName
      moveByX = -50
    case 3:
      walkDirName = rightName
      moveByX = 50
    default:
      print("How did I get here?")
    }
    
    let moveAction = SKAction.moveBy(x: moveByX,
                                     y: moveByY,
                                     duration: 1)
    let finishAction = SKAction.run {
      self.walkRandom()
    }
    let waitAction = SKAction.wait(forDuration: waitTime)
    
    run(SKAction(named:walkDirName)!)
    run(SKAction.sequence([moveAction, waitAction, finishAction]))
    
  } // walkRandom
  
  func contactPlayer() {
    isWalking = false
    removeAllActions()
    
    texture = SKTexture(imageNamed: baseFrame)
    
    if !alreadyContacted {
      alreadyContacted = true
    }
    
  } // contactPlayer()
  
  
  func endContactPlayer() {
    if !isWalking {
      isWalking = true
      walkRandom()
    }
  } // endContactPlayer
  
  
  func speak() -> String {
    if currentSpeech == "" {
      // set a new value for currentSpeech
      if !alreadyContacted {
        let randomLine = Int(arc4random_uniform(UInt32(initialSpeeches.count)))
        currentSpeech = initialSpeeches[randomLine]
      } else {
        let randomLine = Int(arc4random_uniform(UInt32(reminderSpeeches.count)))
        currentSpeech = reminderSpeeches[randomLine]
      }
    }
    return currentSpeech
  } // speak
  
  
} // NPC








