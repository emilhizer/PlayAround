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
    if let findPlayer = childNode(withName: "Player") as? Player {
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
      
      // Get player class (like a D&D "class" not swift class)
      let playerClassName = defaults.string(forKey: "PlayerClass") ?? "Starting"
      if playerClassName == "Starting" {
        defaults.set("Starting", forKey: "PlayerClass")
      }
      
      parsePropertyListForPlayer(className: playerClassName)
      
      // If specific entry point (node) defined, then move player there
      if entryNodeName != "" {
        if let entryNode = childNode(withName: entryNodeName) {
          thePlayer.position = entryNode.position
        }
      }
    } // thePlayer
  } // setupPlayer

  
  // Parse Player "class" dictionary
  func parsePropertyListForPlayer(className: String) {
    guard let result = getPList(fromFile: "GameData.plist") else {
      fatalError("ERROR: Could not load Game Data plist file")
    }
    
    if let classDict = result["Class"] as? [String: Any] {
      if let playerClassDict = classDict[className] as? [String: Any] {
        thePlayer.setup(withDict: playerClassDict)
      }
    }
  } // parsePropertyListForPlayer
  
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
  func meleeAttack() {
    if !disableAttack {
      attack()
    }
  } // meleeAttack()
  
  func attack() {
    let newAttack = AttackArea(imageNamed:"AttackCircle")
    newAttack.position = thePlayer.position
    newAttack.scaleSize = thePlayer.meleeScaleSize
    newAttack.animationName = thePlayer.meleeAnimationName
    
    newAttack.setup()
    newAttack.zPosition = thePlayer.zPosition - 1
    addChild(newAttack)
    
    var animationName = ""
    switch playerFacing {
    case .front:
      animationName = thePlayer.frontMelee
    case .back:
      // Flip attack animation horiz and vert
      newAttack.xScale = -1
      newAttack.yScale = -1
      animationName = thePlayer.backMelee
    case .left:
      // Flip attack horiz
      newAttack.xScale = -1
      animationName = thePlayer.leftMelee
    case .right:
      animationName = thePlayer.rightMelee
    }
    
    let attackAction = SKAction(named: animationName)!
    let finishAction = SKAction.run {
      self.runIdleAnimation()
    }
    thePlayer.run(SKAction.sequence([attackAction, finishAction]), withKey: "Attack")
    
  } // attack
  
  func rangedAttackStart() {
    if !disableAttack {
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
    } // Attack not disabled
  } // rangedAttackStart
  
  func rangedAttack(withProjectile projectile: [String: Any]) {
    print("  -- Ranged attack with projectile \(projectile)")
    let newProjectile = Projectile(imageNamed: prevProjectileImageName)
    newProjectile.name = prevProjectileName
    newProjectile.position = thePlayer.position
    newProjectile.zPosition = thePlayer.zPosition + 1
    newProjectile.setup(withDict: projectile)
    
    addChild(newProjectile)
    
    var theDistance = CGFloat(200)
    if newProjectile.distance > 0 {
      theDistance = newProjectile.distance
    }
    var moveX = CGFloat(0)
    var moveY = CGFloat(0)
    var projectileRotation = CGFloat(0)
    
    switch playerFacing {
    case .front:
      moveY = -theDistance
    case .back:
      moveY = theDistance
      projectileRotation = CGFloat.pi
    case .left:
      moveX = -theDistance
      projectileRotation = CGFloat.pi * 3/2
    case .right:
      moveX = theDistance
      projectileRotation = CGFloat.pi / 2
    }
    
    newProjectile.zRotation = projectileRotation
    
    let moveAction = SKAction.moveBy(x: moveX,
                                     y: moveY,
                                     duration: newProjectile.travelTime)
    moveAction.timingMode = .easeOut
    
    let finish = SKAction.run {
      if newProjectile.removeAfterThrow {
        newProjectile.removeFromParent()
      }
    }
    
    let sequence = SKAction.sequence([moveAction, finish])
    
    newProjectile.run(sequence)
    
    if newProjectile.rotationTime > 0 {
      let rotateAction = SKAction.rotate(byAngle: CGFloat.pi * 2,
                                         duration: newProjectile.rotationTime)
      let repeatAction = SKAction.repeat(rotateAction,
                                         count: Int(newProjectile.travelTime / newProjectile.rotationTime))
      newProjectile.run(repeatAction)
    }
    
    if walkWithPath {
      thePlayer.removeAction(forKey: thePlayer.backWalk)
      thePlayer.removeAction(forKey: thePlayer.frontWalk)
      thePlayer.removeAction(forKey: thePlayer.leftWalk)
      thePlayer.removeAction(forKey: thePlayer.rightWalk)
    }
    
  } // rangedAttack

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

  func makePlayerFollow(path: CGMutablePath) {
    let followAction = SKAction.follow(path,
                                       asOffset: false,
                                       orientToPath: false,
                                       duration: playerWalkTime)
    print("Player Walk Time: \(playerWalkTime)")
    let finishAction = SKAction.run {
      self.runIdleAnimation()
    }
    thePlayer.run(SKAction.sequence([followAction, finishAction]), withKey: "PlayerMoving")
  } // makePlayerFollow:path
  
  func runIdleAnimation() {
    var faceDirection = ""
    switch playerFacing {
    case .front:
      faceDirection = thePlayer.frontIdle
    case .back:
      faceDirection = thePlayer.backIdle
    case .left:
      faceDirection = thePlayer.leftIdle
    case .right:
      faceDirection = thePlayer.rightIdle
    }
    if faceDirection != "" {
      let idleAnimation = SKAction(named: faceDirection, duration: 1)!
      thePlayer.run(idleAnimation, withKey: "Idle")
    }
  } // runIdleAnimation
  
  func playerUpdateWithPath() {
    if (thePlayer.action(forKey: "PlayerMoving") != nil) &&
       (thePlayer.action(forKey: "Attack") == nil) &&
       (playerLastLocation != CGPoint.zero) {
      let movingX = thePlayer.position.x - playerLastLocation.x
      let movingY = thePlayer.position.y - playerLastLocation.y
      
      var actionKey = ""
      
      // Move more left/right than up/down?
      if abs(movingX) > abs(movingY) {
        if movingX > 0 {
          playerFacing = .right
          actionKey = thePlayer.rightWalk
        } else {
          playerFacing = .left
          actionKey = thePlayer.leftWalk
        }
      // Moving more up/down than left/right
      } else {
        if movingY > 0 {
          playerFacing = .back
          actionKey = thePlayer.backWalk
        } else {
          playerFacing = .front
          actionKey = thePlayer.frontWalk
        }
      } // test move left/right vs. up/down
      
      if thePlayer.action(forKey: actionKey) == nil {
        let walkAnimation = SKAction(named: actionKey, duration: 0.25)!
        thePlayer.run(walkAnimation, withKey: actionKey)
      }
      
    } // is player moving?
    
    playerLastLocation = thePlayer.position
    
  } // playerUpdateWithPath
  
  func playerUpdateWithVPad() {
    if touchingDown {
      let distance = CGFloat(2)
      var posX = thePlayer.position.x
      var posY = thePlayer.position.y
      var animationName = ""
      switch playerFacing {
      case .back:
        posY += distance
        animationName = thePlayer.backWalk
      case .front:
        posY -= distance
        animationName = thePlayer.frontWalk
      case .left:
        posX -= distance
        animationName = thePlayer.leftWalk
      case .right:
        posX += distance
        animationName = thePlayer.rightWalk
      }
      thePlayer.position = CGPoint(x: posX, y: posY)
      if thePlayer.action(forKey: animationName) == nil {
        thePlayer.removeAction(forKey: thePlayer.backWalk)
        thePlayer.removeAction(forKey: thePlayer.frontWalk)
        thePlayer.removeAction(forKey: thePlayer.leftWalk)
        thePlayer.removeAction(forKey: thePlayer.rightWalk)
        
        let walkAnimation = SKAction(named: animationName, duration: 0.25)!
        let repeatAction = SKAction.repeatForever(walkAnimation)
        thePlayer.run(repeatAction, withKey: animationName)
      }
    }
  } // playerUpdateWithVPad
  
  func orientPlayer(toPos pos: CGPoint) {
    let movingX = pos.x - touchDownSprite.position.x
    let movingY = pos.y - touchDownSprite.position.y
    
    // Move more left/right than up/down?
    if abs(movingX) > abs(movingY) {
      if movingX > 0 {
        playerFacing = .right
      } else {
        playerFacing = .left
      }
      // Moving more up/down than left/right
    } else {
      if movingY > 0 {
        playerFacing = .back
      } else {
        playerFacing = .front
      }
    } // test move left/right vs. up/down
    
  } // orientPlayer
  
  
  
  
} // GameScene+Player







