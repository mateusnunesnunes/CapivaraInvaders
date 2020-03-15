//
//  Capivara.swift
//  CapivaraInvaders
//
//  Created by Mateus Nunes on 10/03/20.
//  Copyright © 2020 Mateus Nunes. All rights reserved.
//

import Foundation
import SpriteKit
class Capivara:SKScene{
    
    var lastShot = TimeInterval()
    var lastUpdate = TimeInterval()
    var shotInterval = TimeInterval(0.4)
    var interval: Double = 0
    let skins = ["capivarinha1","capivarinha2","capivarinha3"]
    var node: SKSpriteNode!
    
    func setup(){
        self.node = SKSpriteNode(fileNamed: self.skins.randomElement()!)
    }
    
    override func update(_ currentTime: TimeInterval) {
        if lastUpdate == 0{
            lastUpdate = currentTime
            return
        }
        let dTime = currentTime - lastUpdate
        lastUpdate = currentTime
        lastShot += dTime
        if lastShot > shotInterval{
            print("capeidra \(currentTime)")
            lastShot -= shotInterval
        }
    }
    
}
