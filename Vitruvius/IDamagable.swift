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
    var body: IBody { get set }
    func set(body: IBody)
}


extension IDamagable {
    
    func healHp(heal: Int) -> Int {
        let (healed, body) = self.body.healHp(heal: heal)
        self.set(body: body)
        return healed
    }
    
    func applyDamage(damage: Int) -> Promise<DamageReport> {
        
        let (blockLost, nextBody) = self.body.loseBlock(block: damage)
        
        let damageRemaining = max(damage - blockLost, 0)
        
        guard damageRemaining > 0 else {
            
            let report = DamageReport(
                target: nil,
                unblockedDamageDealt: 0,
                blockedDamageDealt: blockLost,
                targetKilled: false
            )
            
            self.set(body: nextBody)
            return Promise<DamageReport>.value(report)
        }
        
        let (hpLost, nextNextBody) = nextBody.loseHp(damage: damageRemaining)
        
        let report = DamageReport(
            target: nil,
            unblockedDamageDealt: hpLost,
            blockedDamageDealt: blockLost,
            targetKilled: false // TODO: Fix me
        )
        
        self.set(body: nextNextBody)
        return Promise<DamageReport>.value(report)
    }
}

protocol IBody {
    var block: Int { get }
    var hp: Int { get }
    var maxHp: Int { get }
    var description: String { get }
    var isAlive: Bool { get }
    func gainBlock(block: Int) -> (Int, IBody)
    func loseBlock(block: Int) -> (Int, IBody)
    func healHp(heal: Int) -> (Int, IBody)
    func loseHp(damage: Int) -> (Int, IBody)
    func onTurnBegan() -> IBody
    func onTurnEnded() -> IBody
}


struct DamageReport {
    let target: IDamagable?
    let unblockedDamageDealt: Int
    let blockedDamageDealt: Int
    let targetKilled: Bool
}

class DamagableBody: IBody {
    
    var hp: Int
    var maxHp: Int
    var block: Int
    
    init(hp: Int, maxHp: Int, currentBlock: Int) {
        self.hp = hp
        self.maxHp = maxHp
        self.block = currentBlock
    }
    
    func gainBlock(block: Int) -> (Int, IBody) {
        self.block += block
        return (block, self)
    }
    
    func loseBlock(block: Int) -> (Int, IBody) {
        let updatedBlock = max(self.block - block, 0)
        let deltaBlock = self.block - updatedBlock
        self.block = updatedBlock
        return (deltaBlock, self)
    }
    
    func healHp(heal: Int) -> (Int, IBody) {
        let updatedHp = min(self.hp + heal, self.maxHp)
        let deltaHp = updatedHp - self.hp
        self.hp = updatedHp
        return (deltaHp, self)
    }
    
    func loseHp(damage: Int) -> (Int, IBody) {
        let updatedHp = max(self.hp - damage, 0)
        let deltaHp = self.hp - updatedHp
        self.hp = updatedHp
        return (deltaHp, self)
    }
    
    func onTurnBegan() -> IBody {
        return self
    }
    
    func onTurnEnded() -> IBody {
        return self
    }
    
    var description: String {
        get { return "BODY: (\(block)) \(hp)/\(maxHp)" }
    }
    
    var isAlive: Bool {
        get { return self.hp > 0 }
    }
}

class BodyProxy: IBody {

    var body: IBody
    
    init(body: IBody) {
        self.body = body
    }
    
    var block: Int { get { return body.block } }
    var hp: Int { get { return body.hp } }
    var maxHp: Int { get { return body.maxHp } }
    var isAlive: Bool { get { return body.isAlive } }
    
    func gainBlock(block: Int) -> (Int, IBody) {
        let (blockGained, body) = self.body.gainBlock(block: block)
        self.body = body
        return (blockGained, self)
    }
    
    func loseBlock(block: Int) -> (Int, IBody) {
        let (blockLost, body) = self.body.loseBlock(block: block)
        self.body = body
        return (blockLost, self)
    }
    
    func healHp(heal: Int) -> (Int, IBody) {
        let (hpHealed, body) = self.body.healHp(heal: heal)
        self.body = body
        return (hpHealed, self)
    }
    
    func loseHp(damage: Int) -> (Int, IBody) {
        let (hpLost, body) = self.body.loseHp(damage: damage)
        self.body = body
        return (hpLost, self)
    }
    
    func onTurnBegan() -> IBody {
        self.body = self.body.onTurnBegan()
        return self
    }
    
    func onTurnEnded() -> IBody {
        self.body = self.body.onTurnEnded()
        return self
    }
    
    var description: String { get { return body.description } }
}




