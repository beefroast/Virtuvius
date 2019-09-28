//
//  Enemy.swift
//  Vitruvius
//
//  Created by Benjamin Frost on 28/9/19.
//  Copyright © 2019 Benjamin Frost. All rights reserved.
//

import Foundation
import PromiseKit

class Enemy: IDamagable {

    let name: String
    var hp: Int
    var maxHp: Int
    var block: Int
    
    init(name: String, hp: Int, maxHp: Int, block: Int) {
        self.name = name
        self.hp = hp
        self.maxHp = maxHp
        self.block = 0
    }
    
    func applyDamage(damage: Int) -> Promise<Bool> {
        
        let hpLost = max(0, damage - self.block)
        let blockLost = damage - hpLost
        
        self.hp -= hpLost
        self.block -= blockLost

        return Promise<Bool>.value(false)
    }
    
    func takeTurn(state: BattleState) -> Promise<Void> {
        return Promise<Void>()
    }
    
    var description: String {
        get {
            return "\(name): (\(block)) \(hp)/\(maxHp)"
        }
    }
    
}

class EnemyGoomba: Enemy {
    
    static func newInstance() -> Enemy {
        return EnemyGoomba(name: "Goomba", hp: 20, maxHp: 20, block: 0)
    }
    
    override func takeTurn(state: BattleState) -> Promise<Void> {
        return state.playerState.applyDamage(damage: 10).done { _ in
            self.block = 10
        }
    }
}