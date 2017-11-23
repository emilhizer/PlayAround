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
  static var Building   = UInt32(0x0002)
  static var Something  = UInt32(0x0004)
  static var Castle     = UInt32(0x0008)
  
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
  

  // MARK: - Init and Load
  override func didMove(to view: SKView) {
    
//    anchorPoint = CGPoint(x: 0.5, y: 0.0)
    
    physicsWorld.gravity = CGVector(dx: 1, // add a little right-to-left wind
                                    dy: 0)
    
    physicsWorld.contactDelegate = self
    
    swipeRightRec.addTarget(self, action: #selector(swipedRight))
    swipeRightRec.direction = .right
    view.addGestureRecognizer(swipeRightRec)

    swipeLeftRec.addTarget(self, action: #selector(swipedLeft))
    swipeLeftRec.direction = .left
    view.addGestureRecognizer(swipeLeftRec)
    
    swipeUpRec.addTarget(self, action: #selector(swipedUp))
    swipeUpRec.direction = .up
    view.addGestureRecognizer(swipeUpRec)
    
    swipeDownRec.addTarget(self, action: #selector(swipedDown))
    swipeDownRec.direction = .down
    view.addGestureRecognizer(swipeDownRec)
    
    rotateRec.addTarget(self, action: #selector(rotatedView(_:)))
    view.addGestureRecognizer(rotateRec)
    
    tapRec.addTarget(self, action: #selector(tappedView))
    tapRec.numberOfTouchesRequired = 2
    tapRec.numberOfTapsRequired = 3
    view.addGestureRecognizer(tapRec)

    // Get the Player
    if let findPlayer = childNode(withName: "Player") as? SKSpriteNode {
      thePlayer = findPlayer
      
      // at least one physics body must by dynamic to detect collisions and contact
      thePlayer.physicsBody!.isDynamic = true
      thePlayer.physicsBody!.affectedByGravity = false
      
      thePlayer.physicsBody!.categoryBitMask = BodyType.Player
      thePlayer.physicsBody!.collisionBitMask =
        BodyType.Castle |
        BodyType.Something
      // If collision bitmask is set, then contact may be redundant
      // See the ContactDelegate tests
      thePlayer.physicsBody!.contactTestBitMask =
        BodyType.Building |
        BodyType.Castle |
        BodyType.Something
    } // thePlayer
    
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
    /*
    for possibleBuilding in children {
      if (possibleBuilding.name == "Building1") {
        building1 = possibleBuilding as! SKSpriteNode
        building1.physicsBody?.isDynamic = false
        building1.physicsBody?.categoryBitMask = BodyType.Building
        building1.physicsBody?.contactTestBitMask = BodyType.Player
        building1.physicsBody?.collisionBitMask = BodyType.Player
        print("Found Building1")
      }
      if (possibleBuilding.name == "Building2") {
        building2 = possibleBuilding as! SKSpriteNode
        building2.physicsBody?.isDynamic = true
        building2.physicsBody?.allowsRotation = true
        building2.physicsBody?.categoryBitMask = BodyType.Building
        building2.physicsBody?.contactTestBitMask = BodyType.Player
        building2.physicsBody?.collisionBitMask = BodyType.Player
        print("Found Building1")
      }
    } // Buildings
    
    checkPhysics()
    
    if building1.physicsBody!.categoryBitMask & thePlayer.physicsBody!.contactTestBitMask == 0 {
      print("Player has no contact with Building 1")
    }
    */
    
  } // didMove:to
  
  // MARK: - Gesture Recognizer
  
  // Tapped
  @objc func tappedView() {
    print("Tapped with two fingers, three taps")
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
  
  // MARK: - Functions
  
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
      self.thePlayer.physicsBody?.isDynamic = false
      self.thePlayer.physicsBody?.affectedByGravity = false
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
  
  
  // MARK: - Touches
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//    if let touch = touches.first {
//      touchDown(atPoint: touch.location(in: self))
//    }
  } // touchesBegan
  
  
  
  
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
  
  
  } // update
  
  //MARK: - Analyse the collision/contact set up.
  func checkPhysics() {
    
    // Create an array of all the nodes with physicsBodies
    var physicsNodes = [SKNode]()
    
    //Get all physics bodies
    for node in children {
      if let _ = node.physicsBody {
        physicsNodes.append(node)
      } else {
        let nodeName = node.name ?? "No Name"
        print("\(nodeName) does not have a physics body so cannot collide or be involved in contacts.")
      }
    }
    
    //For each node, check it's category against every other node's collion and contctTest bit mask
    for node in physicsNodes {
      let category = node.physicsBody!.categoryBitMask
      // Identify the node by its category if the name is blank
      let nodeName = node.name ?? "Category \(category)"
      let collisionMask = node.physicsBody!.collisionBitMask
      let contactMask = node.physicsBody!.contactTestBitMask
      
      // If all bits of the collisonmask set, just say it collides with everything.
      if collisionMask == UInt32.max {
        print("\(nodeName) collides with everything")
      }
      
      for otherNode in physicsNodes {
        if (node != otherNode) && (node.physicsBody?.isDynamic == true) {
          let otherCategory = otherNode.physicsBody!.categoryBitMask
          // Identify the node by its category if the name is blank
          let otherName = otherNode.name ?? "Category \(otherCategory)"
          
          // If the collisonmask and category match, they will collide
          if ((collisionMask & otherCategory) != 0) && (collisionMask != UInt32.max) {
            print("\(nodeName) collides with \(otherName)")
          }
          // If the contactMAsk and category match, they will contact
          if (contactMask & otherCategory) != 0 {print("\(nodeName) notifies when contacting \(otherName)")}
        }
      }
    }
  } // checkPhysics
  
} // GameScene


// MARK: - EXTENSIONS
extension GameScene: SKPhysicsContactDelegate {
  
  func didBegin(_ contact: SKPhysicsContact) {
    print("Contact Made")
    var playerNode = contact.bodyA.node
    var otherNode = contact.bodyB.node
    if (contact.bodyA.categoryBitMask != BodyType.Player) {
      playerNode = contact.bodyB.node
      otherNode = contact.bodyA.node
    }
    if (otherNode?.name == "Building") {
      print("Touched Building")
    }
    if (otherNode?.name == "Castle") {
      print("Touched Castle")
    }
    
  } // didBegin:contact
  
  
  
} // SKPhysicsContactDelegate














