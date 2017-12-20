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
  static var NPC        = UInt32(0x0004)
  static var Item       = UInt32(0x0008)

}

enum Facing: Int {
  case front, back, left, right
}



// MARK: - Main Class
class GameScene: SKScene {
  
  // MARK: - Constants
  enum Constant {
    
  }
  
  // MARK: - Properties
  var thePlayer = Player()
  var building1 = SKSpriteNode()
  var building2 = SKSpriteNode()
  var moveSpeed = TimeInterval(1)
  
  var hudNode = SKNode()
  
  let swipeRightRec = UISwipeGestureRecognizer()
  let swipeLeftRec = UISwipeGestureRecognizer()
  let swipeUpRec = UISwipeGestureRecognizer()
  let swipeDownRec = UISwipeGestureRecognizer()
  let rotateRec = UIRotationGestureRecognizer()
  let tapRec = UITapGestureRecognizer()
  
  var currentLevel = "" // will make this part of init later
  
  var playerReceivingInfo = false
  var infoLabel1 = SKLabelNode()
  var infoLabel2 = SKLabelNode()
  
  var speechIcon = SKSpriteNode()
  
  var rewards = [String: Any]()
  var clearItems = [String]()
  
  var transitionInProgress = false
  
  var playerUsingPortal = false
  
  let defaults = UserDefaults.standard
  
  // +Player
  var playerFacing = Facing.front
  var playerLastLocation = CGPoint.zero
  var lastTouchLocation = CGPoint.zero
  var playerWalkTime = TimeInterval(0)
  
  // +Touches
  var playerPath = [CGPoint]()
  var playerTouchOffset = CGPoint.zero
  
  // +GameData Extension
  var cameraFollowsPlayer = true
  var cameraOffset = CGPoint.zero
  var disableAttack = false
  
  var attackAnywhere = false
  var pathAlpha = CGFloat(0.3)
  var walkWithPath = false
  var touchingDown = false
  var touchDownSprite = SKSpriteNode()
  var touchFollowSprite = SKSpriteNode()
  var offsetFromTouchToPlayer = CGPoint.zero

  // +Helper Extension
  var entryNodeName = ""
  

  // MARK: - Init and Load
  override func didMove(to view: SKView) {
    
    // Debug test
    //    defaults.set(1, forKey: "CastleKey")
    
    physicsWorld.gravity = CGVector(dx: 0, // 1, // add a little wind
                                    dy: 0)
    
    physicsWorld.contactDelegate = self
    
    // Removing most gestures - full control now using touches
    // But keep tap gesture for attacking
    setupGestures()
    
    setupCameraAndHUD()
    
    setupPlayer()
    
    setupGameObjects()
    
    setupGameData() // aka in tutorial as parsePropertyList()
    
    clearTaggedItems(withArray: clearItems)
    
    parseItemRewards(withDict: rewards)
    
    // Display all the physics contacts to console
//    checkPhysics()
    
    
  } // didMove:to
  
  
  // MARK: - Functions
  
  func setupCameraAndHUD() {
    
    if let hudNode = childNode(withName: "//HUD") {
      print(" -- Found HUD node")
      self.hudNode = hudNode

      if let cameraNode = childNode(withName: "//Camera") as? SKCameraNode {
        print(" -- Found camera")
        camera = cameraNode
      }
      
      if let infoLabel = childNode(withName: "//InfoLabel1") as? SKLabelNode {
        print(" -- Found label1")
        infoLabel1 = infoLabel
        infoLabel1.text = ""
      }
      if let infoLabel = childNode(withName: "//InfoLabel2") as? SKLabelNode {
        print(" -- Found label2")
        infoLabel2 = infoLabel
        infoLabel2.text = ""
      }
      if let iconNode = childNode(withName: "//SpeechIcon") as? SKSpriteNode {
        speechIcon = iconNode
        speechIcon.isHidden = true
      }
      
    } // HUD node found
    
  } // setupCameraAndHUD
  
  
  
  
  
  
  // MARK: - Update
  override func update(_ currentTime: TimeInterval) {

    for node in children {
      if node is AttackArea {
        // Move the attack area node along with player node
        node.position = thePlayer.position
      }
      else if (node.name == "Building") || (node.name == "Chest") {
        if node.position.y > thePlayer.position.y {
          node.zPosition = 1
        } else {
          node.zPosition = 100
        }
      }
    }
  
    if cameraFollowsPlayer {
      hudNode.position = CGPoint(x: thePlayer.position.x + cameraOffset.x,
                                 y: thePlayer.position.y + cameraOffset.y)
    }
    
    if walkWithPath {
      playerUpdateWithPath()
    } else {
      playerUpdateWithVPad()
    }
  } // update
  
  
  
  
  
} // GameScene

















