//
//  Capivara.swift
//  CapivaraInvaders
//
//  Created by Mateus Nunes on 10/03/20.
//  Copyright © 2020 Mateus Nunes. All rights reserved.
//

import Foundation
import SpriteKit
class Capivara:Equatable{
    var vida = Int()
    var node = SKSpriteNode()
    let identifier = UUID()
    init(nVida:Int,nNode:SKSpriteNode) {
        self.vida = nVida
        self.node = nNode
        
    }
    static func == (lhs: Capivara, rhs: Capivara) -> Bool {
        return lhs.node === rhs.node && lhs.vida == rhs.vida && lhs.identifier == rhs.identifier

    }
     
}
