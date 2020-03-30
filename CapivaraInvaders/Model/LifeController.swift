//
//  LifeController.swift
//  CapivaraInvaders
//
//  Created by Mateus Nunes on 26/03/20.
//  Copyright © 2020 Mateus Nunes. All rights reserved.
//

import Foundation
import SpriteKit

class LifeController:Equatable{
    static func == (lhs: LifeController, rhs: LifeController) -> Bool {
        return lhs.node === rhs.node && lhs.life == rhs.life

    }
    
    
    init(node: SKNode, life: Int) {
        self.node = node
        self.life = life
    }
    
    let identifier = UUID()
    var node: SKNode
    var life: Int
    
}
