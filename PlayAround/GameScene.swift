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

class GameScene: SKScene {
  
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
  
  var currentLevel = "Grassland" // will make this part of init later
  
  var infoLabel1 = SKLabelNode()
  var infoLabel2 = SKLabelNode()
  
  var speechIcon = SKSpriteNode()
  

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
        BodyType.Castle
      // If collision bitmask is set, then contact may be redundant
      // See the ContactDelegate tests
      thePlayer.physicsBody!.contactTestBitMask =
        BodyType.Building |
        BodyType.Castle
    } // thePlayer
  } // setupPlayer
  
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
  
  func setupGestures() {
    swipeRightRec.addTarget(self, action: #selector(swipedRight))
    swipeRightRec.direction = .right
    view?.addGestureRecognizer(swipeRightRec)
    
    swipeLeftRec.addTarget(self, action: #selector(swipedLeft))
    swipeLeftRec.direction = .left
    view?.addGestureRecognizer(swipeLeftRec)
    
    swipeUpRec.addTarget(self, action: #selector(swipedUp))
    swipeUpRec.direction = .up
    view?.addGestureRecognizer(swipeUpRec)
    
    swipeDownRec.addTarget(self, action: #selector(swipedDown))
    swipeDownRec.direction = .down
    view?.addGestureRecognizer(swipeDownRec)
    
    rotateRec.addTarget(self, action: #selector(rotatedView(_:)))
    view?.addGestureRecognizer(rotateRec)
    
    tapRec.addTarget(self, action: #selector(tappedView))
    tapRec.numberOfTouchesRequired = 1
    tapRec.numberOfTapsRequired = 1
    view?.addGestureRecognizer(tapRec)
  } // setupGestures
  
  func setupGameData() {
//    let path = Bundle.main.path(forResource: "GameData",
//                                ofType: "plist")
    /*
    var result = [String: Any]()
    if let fileURL = Bundle.main.url(forResource: "GameData",
                                  withExtension: "plist"),
      let data = try? Data(contentsOf: fileURL) {
      if let dataResult = try?
        PropertyListSerialization.propertyList(from: data,
                                               options: [],
                                               format: nil) as? [String: Any] {
        if dataResult != nil {
          result = dataResult!
        } else {
          fatalError("No Game Data found")
        }
      } else {
        fatalError("Game Data file cuold not be read")
      }
    } else {
      fatalError("Game Data file could not be found")
    }
    
    print("Game Data:")
    print(result)
    */
    
    guard let result = getPList(fromFile: "GameData.plist") else {
      fatalError("ERROR: Could not load Game Data plist file")
    }
    print("Game Data:")
    print(result)
    
    // Parse property list dictionary
    if let levelDict = result["Levels"] as? [String: Any] {
      for (key, value) in levelDict {
        print("Key: \(key)")
        if key == currentLevel {
          print("--- Loading Curremt Level ---")
          if let levelData = value as? [String: Any] {
            for (key, value) in levelData {
              print("Key: \(key)")
              if key == "NPC" {
                createNPC(withDict: value as! [String: Any])
              }
            }
          }
        }
      }
      
    } // parse plist
    
  } // setupGameData
  
  func createNPC(withDict dict: [String: Any]) {
    
    for (key, value) in dict {
      
      var baseImage = ""
      var range = ""
      let nickname = key
      
      guard let NPCData = value as? [String: Any] else {
        print("NPC Data not a dictionary")
        return
      }
      
      for (key, value) in NPCData {
        if key == "BaseImage" {
          baseImage = value as! String
        }
        else if key == "Range" {
          range = value as! String
        }
      }
      
      let newNPC = NPC(imageNamed: baseImage)
      newNPC.name = nickname
      newNPC.setup(withDict: value as! [String: Any])
      newNPC.baseFrame = baseImage
      newNPC.zPosition = thePlayer.zPosition - 1
      newNPC.position = putSpriteWithinRange(nodeName: range)
      
      addChild(newNPC)
      
      
    }
  } // createNPC
  
  func putSpriteWithinRange(nodeName: String) -> CGPoint {
    
    var point = CGPoint.zero
    
    for node in children {
      if node.name == nodeName {
        if let rangeNode = node as? SKSpriteNode {
          let nodeWidth = rangeNode.size.width
          let nodeHeight = rangeNode.size.height
          let randomX = arc4random_uniform(UInt32(nodeWidth))
          let randomY = arc4random_uniform(UInt32(nodeHeight))
          let posStartX = rangeNode.position.x - (rangeNode.size.width / 2)
          let posStartY = rangeNode.position.y - (rangeNode.size.height / 2)
          point = CGPoint(x: posStartX + CGFloat(randomX),
                          y: posStartY + CGFloat(randomY))
        }
        break // found it
      }
    }
    return point
  } // putSpriteWithinRange
  
  // Move player down
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
  
  // Run touches
  func touchDown(atPoint pos: CGPoint) {
    print("touch pos: \(pos)")
    
    if (pos.y > 0) {
      
    } else {
//      moveDown()
    }
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
  
  
  // MARK: - Touches
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//    if let touch = touches.first {
//      touchDown(atPoint: touch.location(in: self))
//    }
  } // touchesBegan
  
  
  // MARK: - Gesture Recognizers
  
  // Tapped
  @objc func tappedView() {
    print("Tapped")
    
    attack()
  }
  
  // Rotated
  @objc func rotatedView(_ sender: UIRotationGestureRecognizer) {
    switch sender.state {
    case .began:
      print("rotation began")
    case .changed:
      print("rotation changed")
      //      print(sender.rotation)
      
      let rotateAmount = Measurement(value: Double(sender.rotation),
                                     unit: UnitAngle.radians).converted(to: .degrees).value
      print(rotateAmount)
      
      thePlayer.zRotation = -sender.rotation
      
    case .ended:
      print("rotation ended")
    default:
      print("rotation unknown")
    }
  }
  
  // Swiped Right
  @objc func swipedRight() {
    print("Swiped Right")
    move(withXAmount: 100,
         andYAmount: 0,
         andSpriteAnimation: "WalkRight")
  } // swipedRight
  
  // Swiped Left
  @objc func swipedLeft() {
    print("Swiped Left")
    move(withXAmount: -100,
         andYAmount: 0,
         andSpriteAnimation: "WalkLeft")
  } // swipedLeft
  
  // Swiped Up
  @objc func swipedUp() {
    print("Swiped Up")
    move(withXAmount: 0,
         andYAmount: 100,
         andSpriteAnimation: "WalkBack")
  } // swipedUp
  
  // Swiped Down
  @objc func swipedDown() {
    print("Swiped Down")
    move(withXAmount: 0,
         andYAmount: -100,
         andSpriteAnimation: "WalkFront")
  } // swipedDown
  
  // Required when changing scenes
  // If different scenes have different gesture recognizers
  // Call before presenting a new scene
  func cleanUp() {
    for gesture in (view?.gestureRecognizers)! {
      view?.removeGestureRecognizer(gesture)
    }
  } // cleanUp

  
  
  
  
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




// MARK: - EXTENSIONS
extension GameScene: SKPhysicsContactDelegate {
  
  func didBegin(_ contact: SKPhysicsContact) {
    print("Contact Made")
    
    // Reorder/force Player (and attack) to be the first node
    var node1 = contact.bodyA.node
    var node2 = contact.bodyB.node
    if (contact.bodyA.categoryBitMask > contact.bodyB.categoryBitMask) {
      node1 = contact.bodyB.node
      node2 = contact.bodyA.node
    }

    if (node1?.name == "Player") && (node2?.name == "Building") {
      print("Touched Building")
    }
    if (node1?.name == "Player") && (node2?.name == "Castle") {
      print("Touched Castle")
    }
    print(node1?.name ?? "No Node1 Name Found")
    
    if (node1?.name == "AttackArea") && (node2?.name == "Castle") {
      print("Attacked Castle")
      node2?.removeFromParent()
    }
    
    // NPC Contact
    if (node1?.name == "Player") && (node2?.name == "Villager1") {
      print("Touched Villager1")
      if let npc = node2 as? NPC {
        let (line1, line2) = splitSpeech(withText: npc.speak())
        infoLabel1.text = line1
        infoLabel2.text = line2
        speechIcon.isHidden = false
        speechIcon.texture = SKTexture(imageNamed: npc.speechIcon)
        npc.contactPlayer()
      }
    }
    else if (node1?.name == "Player") && (node2?.name == "Villager2") {
      print("Touched Villager1")
      if let npc = node2 as? NPC {
        let (line1, line2) = splitSpeech(withText: npc.speak())
        infoLabel1.text = line1
        infoLabel2.text = line2
        speechIcon.isHidden = false
        speechIcon.texture = SKTexture(imageNamed: npc.speechIcon)
        npc.contactPlayer()
      }
    }

    
  } // didBegin:contact
  
  
  func didEnd(_ contact: SKPhysicsContact) {
    print("Contact Ended")
    
    var node1 = contact.bodyA.node
    var node2 = contact.bodyB.node
    if (contact.bodyA.categoryBitMask > contact.bodyB.categoryBitMask) {
      node1 = contact.bodyB.node
      node2 = contact.bodyA.node
    }
    
    if (node1?.name == "Player") && (node2?.name == "Villager1") {
      print("Finished Touching Villager1")
      if let npc = node2 as? NPC {
        infoLabel1.text = ""
        infoLabel2.text = ""
        speechIcon.isHidden = true
        npc.endContactPlayer()
      }
    }
    if (node1?.name == "Player") && (node2?.name == "Villager2") {
      print("Finished Touching Villager2")
      if let npc = node2 as? NPC {
        infoLabel1.text = ""
        infoLabel2.text = ""
        speechIcon.isHidden = true
        npc.endContactPlayer()
      }
    }


  } // dedEnd:contact
  
  
} // SKPhysicsContactDelegate














