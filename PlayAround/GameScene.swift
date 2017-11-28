//
//  GameScene.swift
//  PlayAround
//
//  Created by Eric Milhizer on 11/19/17.
//  Copyright © 2017 Eric Milhizer. All rights reserved.
//

import SpriteKit
import GameplayKit


// MARK: - Enums and Global Constants
enum BodyType {
  
  static var Player     = UInt32(0x0001)
  static var AttackArea = UInt32(0x0002)
  static var Building   = UInt32(0x0004)
  static var Castle     = UInt32(0x0008)
  static var NPC        = UInt32(0x0010)

}

// MARK: - Main Class
class GameScene: SKScene {
  
  // MARK: - Properties
  var thePlayer = SKSpriteNode()
  var building1 = SKSpriteNode()
  var building2 = SKSpriteNode()
  var moveSpeed = TimeInterval(1)
  
  let swipeRightRec = UISwipeGestureRecognizer()
  let swipeLeftRec = UISwipeGestureRecognizer()
  let swipeUpRec = UISwipeGestureRecognizer()
  let swipeDownRec = UISwipeGestureRecognizer()
  let rotateRec = UIRotationGestureRecognizer()
  let tapRec = UITapGestureRecognizer()
  
  var currentLevel = "" // will make this part of init later
  
  var infoLabel1 = SKLabelNode()
  var infoLabel2 = SKLabelNode()
  
  var speechIcon = SKSpriteNode()
  
  var transitionInProgress = false
  

  // MARK: - Init and Load
  override func didMove(to view: SKView) {
    
    physicsWorld.gravity = CGVector(dx: 0, // 1, // add a little wind
                                    dy: 0)
    
    physicsWorld.contactDelegate = self
    
    setupGestures()
    
    setupCameraAndHUD()
    
    setupPlayer()
    
    setupGameObjects()
    
    setupGameData()

    
    
//    checkPhysics()
    
    
  } // didMove:to
  
  
  // MARK: - Functions
  
  func setupCameraAndHUD() {
    
    if let cameraNode = childNode(withName: "Camera") as? SKCameraNode {
      camera = cameraNode
      
      if let infoLabel = cameraNode.childNode(withName: "InfoLabel1") as? SKLabelNode {
        infoLabel1 = infoLabel
        infoLabel1.text = ""
      }
      if let infoLabel = cameraNode.childNode(withName: "InfoLabel2") as? SKLabelNode {
        infoLabel2 = infoLabel
        infoLabel2.text = ""
      }
      if let iconNode = cameraNode.childNode(withName: "SpeechIcon") as? SKSpriteNode {
        speechIcon = iconNode
        speechIcon.isHidden = true
      }
    }
    
  } // setupCamera
  
  
  
  
  
  
  // MARK: - Update
  override func update(_ currentTime: TimeInterval) {

    for node in children {
      if (node.name == "Building") {
        if node.position.y > thePlayer.position.y {
          node.zPosition = -100
        } else {
          node.zPosition = 100
        }
      }
    }
  
    camera?.position = thePlayer.position
  
  } // update
  
  
  
  
  
} // GameScene

















