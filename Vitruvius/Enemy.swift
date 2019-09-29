//
//  Enemy.swift
//  Vitruvius
//
//  Created by Benjamin Frost on 28/9/19.
//  Copyright © 2019 Benjamin Frost. All rights reserved.
//

import Foundation
import PromiseKit

class Enemy {

    let name: String
    var body: IDamagable
    
    init(name: String, body: IDamagable) {
        self.name = name
        self.body = body
    }
    
    func takeTurn(state: BattleState) -> Promise<Void> {
        return Promise<Void>()
    }
    
    var description: String {
        get {
            return "\(name): \(body.description)"
        }
    }
    
}

class EnemyGoomba: Enemy {
    
    static func newInstance() -> Enemy {
        return EnemyGoomba(name: "Goomba", body: DamagableBody(hp: 20, maxHp: 20, currentBlock: 0))
    }
    
    override func takeTurn(state: BattleState) -> Promise<Void> {
        return state.playerState.body.applyDamage(damage: 10).done { _ in
            self.body.gainBlock(block: 10)
        }
    }
}
