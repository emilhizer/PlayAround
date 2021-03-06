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
  static var Enemy      = UInt32(0x0008)
  static var Item       = UInt32(0x0010)
  static var Projectile = UInt32(0x0012)

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
  
  var hasCustomPadScene = false
  
  var meleeAttackButton = SKSpriteNode()
  var rangedAttackButton = SKSpriteNode()
  var hasMeleeButton = false
  var hasRangedButton = false
  
  // Stats Labels
  var labelHealth = SKLabelNode()
  var labelArmor = SKLabelNode()
  var labelXP = SKLabelNode()
  var labelXPLevel = SKLabelNode()
  var labelCurrency = SKLabelNode()
  var labelClass = SKLabelNode()

  // Stats XP Array
  var xpArray = [ [String: Any] ]()
  
  // Projectiles
  var projectiles = [String: Any]()
  var prevProjectile = [String: Any]()
  var prevProjectileName = ""
  var prevProjectileImageName = ""
  
  // +Gestures
  let swipeRightRec = UISwipeGestureRecognizer()
  let swipeLeftRec = UISwipeGestureRecognizer()
  let swipeUpRec = UISwipeGestureRecognizer()
  let swipeDownRec = UISwipeGestureRecognizer()
  let rotateRec = UIRotationGestureRecognizer()
  let tapRec = UITapGestureRecognizer()
  let doubleTapRec = UITapGestureRecognizer()
  
  // +Player
  var playerFacing = Facing.front
  var playerLastLocation = CGPoint.zero
  var lastTouchLocation = CGPoint.zero
  var playerWalkTime = TimeInterval(0)
  
  // +Touches
  var playerPath = [CGPoint]()
  var playerTouchOffset = CGPoint.zero
  
  // +GameData
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

  // +Helper
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

    loadStatsInfo()
    
    updateStatsLabels()

    
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
        // Adjust camera if on ipad and no special iPad scene created/exists
        if (UIDevice.current.userInterfaceIdiom == .pad) && !hasCustomPadScene {
          print("No custom iPad SKS file, adjust camera a bit")
          cameraNode.setScale(1.5)
        }
      }
      
      // Stats Bar
      if let labelNode = childNode(withName: "//LabelHealth") as? SKLabelNode {
        labelNode.text = ""
        labelHealth = labelNode
      }
      if let labelNode = childNode(withName: "//LabelArmor") as? SKLabelNode {
        labelNode.text = ""
        labelArmor = labelNode
      }
      if let labelNode = childNode(withName: "//LabelXP") as? SKLabelNode {
        labelNode.text = ""
        labelXP = labelNode
      }
      if let labelNode = childNode(withName: "//LabelXPLevel") as? SKLabelNode {
        labelNode.text = ""
        labelXPLevel = labelNode
      }
      if let labelNode = childNode(withName: "//LabelCurrency") as? SKLabelNode {
        labelNode.text = ""
        labelCurrency = labelNode
      }
      if let labelNode = childNode(withName: "//LabelClass") as? SKLabelNode {
        labelNode.text = ""
        labelClass = labelNode
      }
      
      // Info Labels
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
      
      // Buttons
      if let abButton = childNode(withName: "//RangedButton") as? SKSpriteNode {
        rangedAttackButton = abButton
      }
      if let abButton = childNode(withName: "//MeleeButton") as? SKSpriteNode {
        meleeAttackButton = abButton
      }

      
    } // HUD node found
    
  } // setupCameraAndHUD
  
  func loadStatsInfo() {
    if defaults.integer(forKey: "MaxHealth") != 0 {
      thePlayer.maxHealth = defaults.integer(forKey: "MaxHealth")
    } else {
      defaults.set(thePlayer.maxHealth, forKey: "MaxHealth")
    }
    
    if defaults.integer(forKey: "CurrentHealth") != 0 {
      thePlayer.currentHealth = defaults.integer(forKey: "CurrentHealth")
    } else {
      defaults.set(thePlayer.currentHealth, forKey: "CurrentHealth")
    }
    
    if defaults.integer(forKey: "MaxArmor") != 0 {
      thePlayer.maxArmor = defaults.integer(forKey: "MaxArmor")
    } else {
      defaults.set(thePlayer.maxArmor, forKey: "MaxArmor")
    }
    
    if defaults.integer(forKey: "CurrentArmor") != 0 {
      thePlayer.currentArmor = defaults.integer(forKey: "CurrentArmor")
    } else {
      defaults.set(thePlayer.currentArmor, forKey: "CurrentArmor")
    }
    
    if defaults.integer(forKey: "CurrentXP") != 0 {
      thePlayer.currentXP = defaults.integer(forKey: "CurrentXP")
    } else {
      defaults.set(thePlayer.currentXP, forKey: "CurrentXP")
    }
    
    if defaults.integer(forKey: "XPLevel") != 0 {
      thePlayer.currentXPLevel = defaults.integer(forKey: "CurrentXPLevel")
    } else {
      defaults.set(thePlayer.currentXPLevel, forKey: "CurrentXPLevel")
    }
    loadXPInfo(forCurrentXPLevel: thePlayer.currentXPLevel)
    
    if defaults.integer(forKey: "Currency") != 0 {
      thePlayer.currency = defaults.integer(forKey: "Currency")
    } else {
      defaults.set(thePlayer.currency, forKey: "Currency")
    }
    
    if let value = defaults.string(forKey: "CurrentClass"), value != "" {
      thePlayer.currentClass = value
    } else {
      defaults.set(thePlayer.currentClass, forKey: "CurrentClass")
    }

  } // loadStatsInfo
  
  func loadXPInfo(forCurrentXPLevel xpLevel: Int) {
    guard xpArray.count > 0 else {
      fatalError("Trying to load XP Array that has no data")
    }
    guard xpLevel < xpArray.count else {
      fatalError("Leveled up to a value above max defined")
    }
    
    let xpDictionary = xpArray[xpLevel]
    
    if let value = xpDictionary["Name"] as? String {
      thePlayer.currentXPLevelName = value
    }
    if let value = xpDictionary["Max"] as? Int {
      thePlayer.maxXP = value
    }

  } // loadXPInfo
  
  func updateStatsLabels() {
    print("-- Updating stats labels")
    labelHealth.text = String(thePlayer.currentHealth) + "/" + String(thePlayer.maxHealth)
    labelArmor.text = String(thePlayer.currentArmor) + "/" + String(thePlayer.maxArmor)
    labelXP.text = String(thePlayer.currentXP) + "/" + String(thePlayer.maxXP)
    labelCurrency.text = String(thePlayer.currency)
    labelXPLevel.text = thePlayer.currentXPLevelName
    labelClass.text = thePlayer.currentClass
  } // updateStatsLabels
  
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

















