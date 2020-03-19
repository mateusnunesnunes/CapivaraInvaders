//
//  GameViewController.swift
//  CapivaraInvaders
//
//  Created by Mateus Nunes on 03/03/20.
//  Copyright © 2020 Mateus Nunes. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        buildScene()
    }
    func buildScene(){
        if let view = self.view as! SKView? {
           if let scene = SKScene(fileNamed: "GameScene") as? GameScene{
               scene.scaleMode = .aspectFill
              
               scene.size = UIScreen.main.bounds.size
               scene.viewController = self
               view.presentScene(scene)
           }
           view.ignoresSiblingOrder = true
           view.preferredFramesPerSecond = 120
            view.showsPhysics = false
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

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
