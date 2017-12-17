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
  }

  func touchDown(atPoint pos: CGPoint) {
    if thePlayer.action(forKey: "PlayerMoving") != nil {
      thePlayer.removeAction(forKey: "PlayerMoving")
    }
    
    playerPath.removeAll()
    playerTouchOffset = CGPoint(x: thePlayer.position.x - pos.x,
                                y: thePlayer.position.y - pos.y)
    playerPath.append(thePlayer.position)
    playerWalkTime = 0
    lastTouchLocation = pos
  } // touchDown
  
  func touchMoved(toPoint pos: CGPoint) {
    playerWalkTime += TimeInterval(getDeltaDistance(fromPoint: pos) /
      thePlayer.walkSpeed)
    playerPath.append(getDiffToCurrentOffset(fromPoint: pos))
  } // touchMoved

  func touchUp(atPoint pos: CGPoint) {
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
    pathShape.alpha = 0.5
    
    addChild(pathShape)
    
    let fadeOut = SKAction.fadeOut(withDuration: 0.5)
    let removeAction = SKAction.run {
      pathShape.removeFromParent()
    }
    pathShape.run(SKAction.sequence([fadeOut, removeAction]))
    
    makePlayerFollow(path: linePath)
    
    playerPath.removeAll()
    playerTouchOffset = CGPoint.zero
    
  } // touchUp
  
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    if let location = touches.first?.location(in: self) {
      touchDown(atPoint: location)
    }
  } // touchesBegan
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    if let location = touches.first?.location(in: self) {
      touchMoved(toPoint: location)
    }
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    if let location = touches.first?.location(in: self) {
      touchUp(atPoint: location)
    }
  }
  
  override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    playerPath.removeAll()
  }
  
  

} // GameScene+Touches









