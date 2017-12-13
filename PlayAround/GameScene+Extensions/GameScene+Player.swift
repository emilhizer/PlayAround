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
        BodyType.Item
      // If collision bitmask is set, then contact may be redundant
      // See the ContactDelegate tests
      thePlayer.physicsBody!.contactTestBitMask =
        BodyType.Item
      
      // If specific entry point (node) defined, then move player there
      if entryNodeName != "" {
        if let entryNode = childNode(withName: entryNodeName) {
          thePlayer.position = entryNode.position
        }
      }
    } // thePlayer
  } // setupPlayer

  
  // Contact between Player and World Item
  func playerContact(withItem item: WorldItem) {

    if !playerReceivingInfo {
      thePlayer.removeAllActions()
      playerReceivingInfo = true
      displaySpeech(withText: item.getText())
      if !item.isOpen && (item.lockedIcon != "") {
        displaySpeechIcon(withTextureName: item.lockedIcon)
      }
      else if item.isOpen && (item.openIcon != "") {
        displaySpeechIcon(withTextureName: item.openIcon)
      }
      else if !item.isOpen && (item.timeToOpen > 0) {
        showTimer(forItem: item)
      }
    }

    // Rewards
    // This also checks to see if this item unlocks another
    //   WorldItem in the scene
    if item.rewards.count > 0 {
      parseItemRewards(withDict: item.rewards)
      // Remove all the rewards from the item contacted
      item.rewards.removeAll()
      if item.neverRewardAgain {
        defaults.set(true, forKey: item.name! + "AleardyAwarded")
      }
    }
    
    // Contact behavior for an open item
    if item.isOpen {
      item.afterOpenContact()
    }
    
    // Check if item is a portal to somewhere else (item must be open)
    if item.isPortal && item.isOpen {
      print("Player contacted portal to: \(item.portalToLevel)")
      print("  -- and node name: \(item.portalToWhere)")
      if item.portalToLevel != "" {
        enterPortal(inNewLevelName: item.portalToLevel,
                    withLocationName: item.portalToWhere,
                    delay: item.portalDelay)
        
      } else if item.portalToWhere != "" {
        enterPortalInCurrentLevel(withLocationName: item.portalToWhere,
                                  delay: item.portalDelay)
      }
    } // End check if portal
    
    // Check if item is an alt portal to somewhere else (item must be closed)
    if item.isAltPortal && !item.isOpen {
      print("Player contacted alt portal to: \(item.altPortalToLevel)")
      print("  -- and node name: \(item.altPortalToWhere)")
      if item.altPortalToLevel != "" {
        enterPortal(inNewLevelName: item.altPortalToLevel,
                    withLocationName: item.altPortalToWhere,
                    delay: item.altPortalDelay)
        
      } else if item.altPortalToWhere != "" {
        enterPortalInCurrentLevel(withLocationName: item.altPortalToWhere,
                                  delay: item.altPortalDelay)
      }
    } // End check if alt portal
    
  } // playerContact:withItem
  
  // Ended contact with item
  func playerEndContact(withItem item: WorldItem) {
    fadeOutInfoText(overTime: item.infoDisplayTime)
    if let delayTimer = childNode(withName: item.name! + "Timer") {
      delayTimer.removeFromParent()
    }
  } // playerEndContact

  
  // Move player
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

  func enterPortalInCurrentLevel(withLocationName toWhere: String, delay: TimeInterval) {
    
    if !playerUsingPortal {
      playerUsingPortal = true
      
      thePlayer.physicsBody?.categoryBitMask = 0
      let restoreContactInfo = thePlayer.physicsBody!.contactTestBitMask
      thePlayer.physicsBody?.contactTestBitMask = 0
      let restoreCollisionInfo = thePlayer.physicsBody!.collisionBitMask
      thePlayer.physicsBody?.collisionBitMask = 0
      let newLocation = childNode(withName: toWhere)!.position
      
      let fadePlayerOut = SKAction.fadeOut(withDuration: 0.1)
      let fadePlayerIn = SKAction.fadeIn(withDuration: 0.1)
      
      let movePlayer = SKAction.move(to: newLocation, duration: delay)
      let runAction = SKAction.run {
        self.thePlayer.physicsBody?.categoryBitMask = BodyType.Player
        self.thePlayer.physicsBody?.contactTestBitMask = restoreContactInfo
        self.thePlayer.physicsBody?.collisionBitMask = restoreCollisionInfo
        self.playerUsingPortal = false
      }
      
      thePlayer.run(SKAction.sequence([fadePlayerOut,
                                       movePlayer,
                                       fadePlayerIn,
                                       runAction]))
    }
    
    /* Original portal "jump"
    let waitAction = SKAction.wait(forDuration: delay)
    let runAction = SKAction.run {
    
      // go to somewhere else within this level
      // If specific entry point (node) defined, then move player there
      if let entryNode = self.childNode(withName: toWhere) {
        // Note: use SKActions instead of moving player to new .position
        //  because the player is likely in the middle of an SKAction, so
        //  setting their .position directly will get "overwritten" by
        //  by its concurrently running (moveTo:) SKAction
        self.thePlayer.removeAllActions()
        self.thePlayer.run(SKAction.move(to: entryNode.position,
                                         duration: 0.0))
      }
    } // runAction block
    run(SKAction.sequence([waitAction, runAction]))
    */
  } // enterPortalInCurrentLevel

  func enterPortal(inNewLevelName newLevelName: String, withLocationName toWhere: String, delay: TimeInterval) {
    
    if !playerUsingPortal {
      playerUsingPortal = true
      
      defaults.set(toWhere, forKey: "CountinueWhere")
      
      // Maybe create a player entering portal animation, too
      
      let waitAction = SKAction.wait(forDuration: delay)
      let runAction = SKAction.run {
        // go to another level
        self.playerUsingPortal = false
        self.loadLevel(newLevelName, toNodeName: toWhere)
      }
      run(SKAction.sequence([waitAction, runAction]))
    }
  } // enterPortal

  
} // GameScene+Player







