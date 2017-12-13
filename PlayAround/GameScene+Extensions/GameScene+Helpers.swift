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
  
  // Load the level
  func loadLevel(_ levelName: String, toNodeName: String) {
    
    if !transitionInProgress {
      transitionInProgress = true
      
      let sksNameToLoad = Helpers.checkIfSKSExists(forName: levelName)
      
      if let scene = GameScene(fileNamed: sksNameToLoad) {
        // cleanupScene()
        
        scene.currentLevel = levelName
        scene.scaleMode = .aspectFill
        scene.entryNodeName = toNodeName
        
        let transition = SKTransition.fade(with: SKColor.black,
                                           duration: 2)
        view?.presentScene(scene, transition: transition)
        
      } else {
        print("Could not find level named: \(levelName)")
      }
      
    } // Only transition once
    
  } // loadLevel

  // Split speech text if necessary
  func displaySpeech(withText text: String) {
    print("-- Display speech: \(text)")
    // If text is empty then we're done
    guard text != "" else {
      return
    }
    
    let maxOnLine = 25
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
    
    infoLabel1.removeAllActions()
    infoLabel2.removeAllActions()
    infoLabel1.alpha = 1
    infoLabel2.alpha = 1

    infoLabel1.text = line1
    infoLabel2.text = line2
    
  } // displaySpeech

  // Fade out the display speech
  func fadeOutInfoText(overTime waitTime: TimeInterval = 0.5) {
    print(" -- Fade out info text")
    infoLabel1.removeAllActions()
    infoLabel2.removeAllActions()
    speechIcon.removeAllActions()
    
    let waitAction = SKAction.wait(forDuration: waitTime)
    let fadeAction = SKAction.fadeOut(withDuration: waitTime)
    let wait2xAction = SKAction.wait(forDuration: waitTime * 2)
    let clearAction = SKAction.run {
      self.infoLabel1.text = ""
      self.infoLabel2.text = ""
      self.infoLabel1.alpha = 1
      self.infoLabel2.alpha = 1
      self.speechIcon.isHidden = true
      self.speechIcon.alpha = 1
      self.playerReceivingInfo = false
      print("Player Receiving Info: \(self.playerReceivingInfo)")
    }
    let fadeoutAction = SKAction.sequence([waitAction, fadeAction])
    let cleanupAction = SKAction.sequence([wait2xAction, clearAction])
    
    infoLabel1.run(fadeoutAction)
    infoLabel2.run(fadeoutAction)
    speechIcon.run(fadeoutAction)
    run(cleanupAction)
    
  } // fadeOutInfoText
  
  func displaySpeechIcon(withTextureName textureName: String) {
    print("--Show SpeechIcon: \(textureName)")
    speechIcon.removeAllActions()
    speechIcon.alpha = 1
    speechIcon.isHidden = false
    speechIcon.texture = SKTexture(imageNamed: textureName)
  } // showIcon
  
  // Save info to defaults
  func remember(thisThing thing: String, toRemember: String) {
    
    defaults.set(true, forKey: currentLevel+thing+toRemember)
    // Example key: "GrasslandVillager1alreadyContacted"
    
  } // remember
  
  // Clear items tagged to be cleared at the start of a new level / scene
  func clearTaggedItems(withArray itemsToClear: [String]) {
    for clearItem in itemsToClear {
      defaults.removeObject(forKey: clearItem)
      print("Clearing out item: \(clearItem)")
    }
  } // clearTaggedItems

  // Show the timer animated graphic above an item
  func showTimer(forItem item: WorldItem) {
    if childNode(withName: item.name! + "Timer") == nil {
      let timerNode = SKSpriteNode(color: .clear,
                                   size: CGSize(width: 150, height: 20))
      timerNode.name = item.name! + "Timer"
      timerNode.position = CGPoint(x: item.position.x,
                                   y: item.position.y + (item.size.height / 2))
      timerNode.zPosition = thePlayer.zPosition + 1
      
      addChild(timerNode)
      
      let animateAction = SKAction(named: item.timerName,
                                   duration: item.timeToOpen)!
      let runAction = SKAction.run {
        item.open()
        timerNode.removeFromParent()
        self.playerReceivingInfo = false
        item.currentText = ""
        self.playerContact(withItem: item)
        // Note when player contacts with newly opened item, it will change
        //   the item to the open texture and will remove item's physics body
        //   and thus physics will not detect end of contact (to original item)
        // Therefore, fade out the newly displayed "item is open" text
        self.fadeOutInfoText(overTime: item.infoDisplayTime)
      }
      timerNode.run(SKAction.sequence([animateAction,
                                       runAction]))
    } // if timer not already running in scene
  } // showTimer
  
  
} // GameScene+Helpers





