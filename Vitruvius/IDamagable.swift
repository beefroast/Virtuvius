//
//  IDamagable.swift
//  Vitruvius
//
//  Created by Benjamin Frost on 29/9/19.
//  Copyright © 2019 Benjamin Frost. All rights reserved.
//

import Foundation
import PromiseKit

protocol IDamagable {
    var block: Int { get }
    var hp: Int { get }
    var maxHp: Int { get }
    var description: String { get }
    var isAlive: Bool { get }
    func gainBlock(block: Int) -> Int
    func loseBlock(block: Int) -> Int
    func healHp(heal: Int) -> Int
    func loseHp(damage: Int) -> Int
}

extension IDamagable {
    
    func applyDamage(damage: Int) -> Promise<DamageReport> {
        
        let blockLost = self.loseBlock(block: damage)
        
        let damageRemaining = max(damage - blockLost, 0)
        
        guard damageRemaining > 0 else {
            return Promise<DamageReport>.value(
                DamageReport(
                    target: self,
                    unblockedDamageDealt: 0,
                    blockedDamageDealt: blockLost,
                    targetKilled: false
                )
            )
        }
        
        let hpLost = self.loseHp(damage: damageRemaining)
        
        let report = DamageReport(
            target: self,
            unblockedDamageDealt: hpLost,
            blockedDamageDealt: blockLost,
            targetKilled: false // TODO: Fix me
        )

        return Promise<DamageReport>.value(report)
    }
}

struct DamageReport {
    let target: IDamagable
    let unblockedDamageDealt: Int
    let blockedDamageDealt: Int
    let targetKilled: Bool
}

class DamagableBody: IDamagable {
    
    var hp: Int
    var maxHp: Int
    var block: Int
    
    init(hp: Int, maxHp: Int, currentBlock: Int) {
        self.hp = hp
        self.maxHp = maxHp
        self.block = currentBlock
    }
    
    func gainBlock(block: Int) -> Int {
        self.block += block
        return block
    }
    
    func loseBlock(block: Int) -> Int {
        let updatedBlock = max(self.block - block, 0)
        let deltaBlock = self.block - updatedBlock
        self.block = updatedBlock
        return deltaBlock
    }
    
    func healHp(heal: Int) -> Int {
        let updatedHp = min(self.hp + heal, self.maxHp)
        let deltaHp = updatedHp - self.hp
        self.hp = updatedHp
        return deltaHp
    }
    
    func loseHp(damage: Int) -> Int {
        let updatedHp = max(self.hp - damage, 0)
        let deltaHp = self.hp - updatedHp
        self.hp = updatedHp
        return deltaHp
    }
    
    var description: String {
        get { return "BODY: (\(block)) \(hp)/\(maxHp)" }
    }
    
    var isAlive: Bool {
        get { return self.hp > 0 }
    }
}

class DamagableProxy: IDamagable {

    
    let body: IDamagable
    
    init(body: IDamagable) {
        self.body = body
    }
    
    var block: Int { get { return body.block } }
    var hp: Int { get { return body.hp } }
    var maxHp: Int { get { return body.maxHp } }
    var isAlive: Bool { get { return body.isAlive } }
    
    func gainBlock(block: Int) -> Int { body.gainBlock(block: block) }
    func loseBlock(block: Int) -> Int { body.loseBlock(block: block) }
    func healHp(heal: Int) -> Int { body.healHp(heal: heal) }
    func loseHp(damage: Int) -> Int { body.loseHp(damage: damage) }
    
    var description: String { get { return body.description } }
}




