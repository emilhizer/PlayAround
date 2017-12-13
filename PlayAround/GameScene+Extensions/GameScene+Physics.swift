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
    
    guard !playerUsingPortal else {
      print("Ignoring Contact - Player Using Portal")
      return
    }
    
    // Reorder/force Player (and attack) to be the first node
    let (node1, node2) = orderNodesContacted(withContact: contact)
    print("Node1: \(node1!.name!) contacted Node2: \(node2!.name!)")

    // NPC Contact
    if let npc = node2 as? NPC, (node1?.name == "Player") {
      print(" -- With NPC: \(npc.name!)")
      if !playerReceivingInfo {
        thePlayer.removeAllActions()
        playerReceivingInfo = true
        displaySpeech(withText: npc.speak())
        
        if npc.speechIcon != "" {
          displaySpeechIcon(withTextureName: npc.speechIcon)
        }
        
        npc.contactPlayer()
        remember(thisThing: npc.name!, toRemember: "alreadyContacted")
      } else {
        print("Player contacted NPC but receiving info from elsewhere!")
      }
    }
    
    // WorldItem
    if let worldItem = node2 as? WorldItem, (node1?.name == "Player") {
      print("  -- WorldItem: \(worldItem)")
      playerContact(withItem: worldItem)
    }
    
    
  } // didBegin:contact
  
  // Contact ended
  func didEnd(_ contact: SKPhysicsContact) {
    print("Contact Ended")
    
    guard !playerUsingPortal else {
      print("Ignoring Contact Ended - Player Using Portal")
      return
    }

    let (node1, node2) = orderNodesContacted(withContact: contact)
    
    // End NPC contact
    if let npc = node2 as? NPC, (node1?.name == "Player") {
      print("Finished Touching: \(npc.name!)")
      npc.endContactPlayer()
      fadeOutInfoText(overTime: npc.infoDisplayTime)
    }
    
    // End WorldItem contact
    if let worldItem = node2 as? WorldItem, (node1?.name == "Player") {
      print("Finished Touching: \(worldItem.name!)")
      playerEndContact(withItem: worldItem)
    }

    
  } // dedEnd:contact
  
  // Set expected order of contacted nodes
  func orderNodesContacted(withContact contact: SKPhysicsContact) -> (SKNode?, SKNode?) {
    var node1 = contact.bodyA.node
    var node2 = contact.bodyB.node
    if (contact.bodyA.categoryBitMask > contact.bodyB.categoryBitMask) {
      node1 = contact.bodyB.node
      node2 = contact.bodyA.node
    }
    return (node1, node2)
  } // orderNodesContacted
  
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





