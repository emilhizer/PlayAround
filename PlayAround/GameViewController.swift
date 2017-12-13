//
//  GameViewController.swift
//  PlayAround
//
//  Created by Eric Milhizer on 11/19/17.
//  Copyright © 2017 Eric Milhizer. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
  
  let defaults = UserDefaults.standard

  override func viewDidLoad() {
    super.viewDidLoad()
  
    var initialLevel = "Grassland"
    var initialEntryNodeName = ""

    if let savedLevel = defaults.object(forKey: "ContinuePoint") as? String {
       initialLevel = savedLevel
    }
    
    if let savedEntry = defaults.object(forKey: "CountinueWhere") as? String {
      initialEntryNodeName = savedEntry
    }
    
    if let view = self.view as! SKView? {
      // Load the GameScene:SKScene from initialLevel(.sks)
      let sksNameToLoad = Helpers.checkIfSKSExists(forName: initialLevel)

      if let scene = GameScene(fileNamed: sksNameToLoad) {
        // Set the scale mode to scale to fit the window
        scene.scaleMode = .aspectFill
        scene.currentLevel = initialLevel
        scene.entryNodeName = initialEntryNodeName
      
        // Present the scene
        view.presentScene(scene)
      }
    
      view.ignoresSiblingOrder = true
    
      view.showsFPS = true
      view.showsPhysics = true
      view.showsNodeCount = true
    }
  }

  override var shouldAutorotate: Bool {
    return true
  }

  override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    if UIDevice.current.userInterfaceIdiom == .phone {
      return .allButUpsideDown
    } else {
      return .all
    }
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Release any cached data, images, etc that aren't in use.
  }

  override var prefersStatusBarHidden: Bool {
    return true
  }
}
