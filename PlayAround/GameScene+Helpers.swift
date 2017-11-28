//
//  GameScene+Helpers.swift
//  PlayAround
//
//  Created by Eric Milhizer on 11/27/17.
//  Copyright © 2017 Eric Milhizer. All rights reserved.
//

import Foundation
import SpriteKit

extension GameScene {
  
  // Setup buildings, castle and other objects
  func setupGameObjects() {
    // Buildings
    for node in children {
      if node.name == "Building" {
        node.physicsBody?.categoryBitMask = BodyType.Building
        node.physicsBody?.collisionBitMask = 0 // collide with nothing
        print("Found Building")
      }
      if let castle = node as? Castle {
        castle.setupCastle()
        castle.dudesInCastle = 5
      }
    }
  } // setupGameObjects
  
  // Split speech text if necessary
  func splitSpeech(withText text: String) -> (String, String) {
    let maxOnLine = 20
    var i = 0
    
    var line1 = ""
    var line2 = ""
    
    var useLine2 = false
    
    for letter in text {
      if (i > maxOnLine) && (letter == " ") {
        useLine2 = true
      }
      if useLine2 {
        line2 = line2 + String(letter)
      } else {
        line1 = line1 + String(letter)
      }
      i += 1
    } // cycle through text
    
    return (line1, line2)
    
  } // splitSpeech

  //
  func loadLevel(_ levelName: String) {
    
    if !transitionInProgress {
      transitionInProgress = true
      
      let sksNameToLoad = Helpers.checkIfSKSExists(forName: levelName)
      
      if let scene = GameScene(fileNamed: sksNameToLoad) {
        // cleanupScene()
        
        scene.currentLevel = levelName
        scene.scaleMode = .aspectFill
        
        let transition = SKTransition.fade(with: SKColor.black,
                                           duration: 2)
        view?.presentScene(scene, transition: transition)
        
      } else {
        print("Could not find level named: \(levelName)")
      }
      
    } // Only transition once
    
  } // loadLevel
  
  
  
  
} // GameScene+Helpers





