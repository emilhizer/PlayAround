//
//  GameScene+Touches.swift
//  PlayAround
//
//  Created by Eric Milhizer on 12/13/17.
//  Copyright © 2017 Eric Milhizer. All rights reserved.
//

import Foundation
import SpriteKit


extension GameScene {
  
  
  func getDiffToCurrentOffset(fromPoint: CGPoint) -> CGPoint {
    let newPoint = CGPoint(x: fromPoint.x + playerTouchOffset.x,
                           y: fromPoint.y + playerTouchOffset.y)
    return newPoint
  } // getDiffToCurrentOffset
  
  func getDeltaDistance(fromPoint currentPoint: CGPoint) -> CGFloat {
    let deltaDistance = sqrt( pow(currentPoint.x - lastTouchLocation.x, 2) +
                              pow(currentPoint.y - lastTouchLocation.y, 2) )
    lastTouchLocation = currentPoint
    return deltaDistance
  } // getDeltaDistance
  
  // MARK: - Action Buttons
  
  func checkIfMeleeButtonPressed(atPos pos: CGPoint) -> Bool {
    var pressed = false
    let touchedNode = nodes(at: pos).first
    
    if let nodeName = touchedNode?.name, nodeName == "MeleeButton" {
      pressed = true
      highlightAndFadeAttackButtons()
    }
    
    return pressed
  } // checkIfMeleeButtonPressed
  
  func checkIfRangedButtonPressed(atPos pos: CGPoint) -> Bool {
    var pressed = false
    let touchedNode = nodes(at: pos).first
    
    if let nodeName = touchedNode?.name, nodeName == "RangedButton" {
      pressed = true
      highlightAndFadeAttackButtons()
    }
    
    return pressed
  } // checkIfMeleeButtonPressed
  
  func highlightAndFadeAttackButtons() {
    rangedAttackButton.removeAllActions()
    meleeAttackButton.removeAllActions()
    
    rangedAttackButton.alpha = 1
    meleeAttackButton.alpha = 1
    
    let fadeOut = SKAction.fadeAlpha(to: 0.05, duration: 1)
    rangedAttackButton.run(fadeOut)
    meleeAttackButton.run(fadeOut)
  } // highlightAndFadeAttackButtons
  
  func fadeInAttackButtons() {
    rangedAttackButton.removeAllActions()
    meleeAttackButton.removeAllActions()

    let fadeIn = SKAction.fadeAlpha(to: 1, duration: 0.1)
    rangedAttackButton.run(fadeIn)
    meleeAttackButton.run(fadeIn)
  } // fadeInAttackButtons

  // MARK: - Touch Down
  func touchDownOnPath(atPoint pos: CGPoint) {
    if thePlayer.action(forKey: "PlayerMoving") != nil {
      thePlayer.removeAction(forKey: "PlayerMoving")
    }
    
    playerPath.removeAll()
    playerTouchOffset = CGPoint(x: thePlayer.position.x - pos.x,
                                y: thePlayer.position.y - pos.y)
    playerPath.append(thePlayer.position)
    playerWalkTime = 0
    lastTouchLocation = pos
  } // touchDownOnPath
  
  func touchDownWithVPad(atPoint pos: CGPoint) {

    let posInHUD = convert(pos, to: hudNode)
    let playerPosInHUD = convert(thePlayer.position, to: hudNode)
//    print("-- Touched Down w VPad at GS Point: \(pos); HUD Point: \(posInHUD)")
    
    // VPad only enabled when touching left side of screen
    if posInHUD.x < 0 {
      touchingDown = true
      thePlayer.removeAction(forKey: "Idle")
      offsetFromTouchToPlayer = CGPoint(x: playerPosInHUD.x - posInHUD.x,
                                        y: playerPosInHUD.y - posInHUD.y)
      
      if touchDownSprite.parent == nil {
        touchDownSprite = SKSpriteNode(imageNamed: "TouchDown")
        touchDownSprite.zPosition = 1000
        hudNode.addChild(touchDownSprite)
      }
      touchDownSprite.position = posInHUD
      
      if touchFollowSprite.parent == nil {
        touchFollowSprite = SKSpriteNode(imageNamed: "TouchDown")
        touchFollowSprite.zPosition = 1000
        hudNode.addChild(touchFollowSprite)
      }
      touchFollowSprite.position = posInHUD
    } // Enable VPad
    
  } // touchDownWithVPad

  // MARK: - Touch Moved
  func touchMovedOnPath(toPoint pos: CGPoint) {
    playerWalkTime += TimeInterval(getDeltaDistance(fromPoint: pos) /
      thePlayer.walkSpeed)
    playerPath.append(getDiffToCurrentOffset(fromPoint: pos))
  } // touchMovedOnPath
  
  func touchMovedWithVPad(toPoint pos: CGPoint) {
    if touchingDown {
      let posInHUD = convert(pos, to: hudNode)
      orientPlayer(toPos: posInHUD)
      touchFollowSprite.position = posInHUD
    }
  } // touchMovedWithVPad
  
  // MARK: - Touch Up
  func touchUpOnPath(atPoint pos: CGPoint) {
    if thePlayer.action(forKey: "PlayerMoving") != nil {
      thePlayer.removeAction(forKey: "PlayerMoving")
    }
    
    playerPath.append(getDiffToCurrentOffset(fromPoint: pos))
    let linePath = CGMutablePath()
    linePath.move(to: playerPath[0])
    for point in playerPath {
      linePath.addLine(to: point)
    }
    
    let pathShape = SKShapeNode()
    pathShape.path = linePath
    pathShape.lineWidth = 10
    pathShape.strokeColor = .white
    pathShape.alpha = pathAlpha
    
    addChild(pathShape)
    
    let fadeOut = SKAction.fadeOut(withDuration: 0.5)
    let removeAction = SKAction.run {
      pathShape.removeFromParent()
    }
    pathShape.run(SKAction.sequence([fadeOut, removeAction]))
    
    makePlayerFollow(path: linePath)
    
    playerPath.removeAll()
    playerTouchOffset = CGPoint.zero
    
  } // touchUpOnPath
  
  func touchUpWithVPad(atPoint pos: CGPoint) {
    print("TouchUp")
    thePlayer.removeAllActions()
    touchingDown = false
    touchFollowSprite.removeFromParent()
    touchDownSprite.removeFromParent()
    runIdleAnimation()
  } // touchUpWithVPad
  
  // MARK: - Touch Handlers
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    if let location = touches.first?.location(in: self) {
      if checkIfMeleeButtonPressed(atPos: location) {
        print("--Melee Button Pressed")
        meleeAttack()
      }
      else if checkIfRangedButtonPressed(atPos: location) {
        print("--Ranged Button Pressed")
        rangedAttackStart()
      }

      else if walkWithPath {
        touchDownOnPath(atPoint: location)
      } else {
        touchDownWithVPad(atPoint: location)
      }
    }
  } // touchesBegan
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    if let location = touches.first?.location(in: self) {
      if walkWithPath {
        touchMovedOnPath(toPoint: location)
      } else {
        touchMovedWithVPad(toPoint: location)
      }
    }
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    if let location = touches.first?.location(in: self) {
      if walkWithPath {
        touchUpOnPath(atPoint: location)
      } else {
        touchUpWithVPad(atPoint: location)
      }
    }
    fadeInAttackButtons()
  } // touchesEnded
  
  override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    playerPath.removeAll()
  }
  
  

} // GameScene+Touches









