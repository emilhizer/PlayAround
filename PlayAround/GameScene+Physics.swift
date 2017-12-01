//
//  GameScene+Physics.swift
//  PlayAround
//
//  Created by Eric Milhizer on 11/27/17.
//  Copyright © 2017 Eric Milhizer. All rights reserved.
//

import Foundation
import SpriteKit


extension GameScene: SKPhysicsContactDelegate {
  
  // Contact began
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
    
    // Touched Castle
    if (node1?.name == "Player") && (node2?.name == "Castle") {
      print("Touched Castle")
      loadLevel("Dungeon")
    }
    
    // Attacked Castle
    if (node1?.name == "AttackArea") && (node2?.name == "Castle") {
      print("Attacked Castle")
//      node2?.removeFromParent()
    }
    
    // NPC Contact
    if let npc = node2 as? NPC, (node1?.name == "Player") {
      print("Touched: \(npc.name!)")
      let (line1, line2) = splitSpeech(withText: npc.speak())
      infoLabel1.text = line1
      infoLabel2.text = line2
      speechIcon.isHidden = false
      speechIcon.texture = SKTexture(imageNamed: npc.speechIcon)
      npc.contactPlayer()
      remember(thisThing: npc.name!, toRemember: "alreadyContacted")
    }
    
    
    
  } // didBegin:contact
  
  // Contact ended
  func didEnd(_ contact: SKPhysicsContact) {
    print("Contact Ended")
    
    var node1 = contact.bodyA.node
    var node2 = contact.bodyB.node
    if (contact.bodyA.categoryBitMask > contact.bodyB.categoryBitMask) {
      node1 = contact.bodyB.node
      node2 = contact.bodyA.node
    }
    
    if let npc = node2 as? NPC, (node1?.name == "Player") {
      print("Finished Touching: \(npc.name!)")
      infoLabel1.text = ""
      infoLabel2.text = ""
      speechIcon.isHidden = true
      npc.endContactPlayer()
    }
    
    
  } // dedEnd:contact
  
  
  //MARK: - Analyze the collision/contact set up
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

  
} // GameScene+Physics





