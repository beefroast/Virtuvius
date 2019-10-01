//
//  IBody.swift
//  Vitruvius
//
//  Created by Benjamin Frost on 1/10/19.
//  Copyright © 2019 Benjamin Frost. All rights reserved.
//

import Foundation

protocol IDamagable {
    var body: Body { get set }
}

class Body {
    
    var block: Int
    var hp: Int
    var maxHp: Int
 
    init(block: Int, hp: Int, maxHp: Int) {
        self.block = block
        self.hp = hp
        self.maxHp = maxHp
    }
    
    var description: String {
        get { return "[\(self.block)] \(self.hp)/\(self.maxHp)hp" }
    }
}
