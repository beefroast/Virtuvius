//
//  Card.swift
//  Vitruvius
//
//  Created by Benjamin Frost on 27/9/19.
//  Copyright © 2019 Benjamin Frost. All rights reserved.
//

import Foundation
import PromiseKit

enum CardPowerTypes {
    case charm
    case guile
    case might
    case faith
    case sharp
}

struct Cost {
    
    let colorless: Int
    let charm: Int
    let guile: Int
    let might: Int
    let faith: Int
    let sharp: Int
    
    init(colorless: Int,
         charm: Int,
         guile: Int,
         might: Int,
         faith: Int,
         sharp: Int) {
        self.colorless = colorless
        self.charm = charm
        self.guile = guile
        self.might = might
        self.faith = faith
        self.sharp = sharp
    }
    
    static func free() -> Cost {
        return Cost(colorless: 0, charm: 0, guile: 0, might: 0, faith: 0, sharp: 0)
    }
    
    static func add(a: Cost, b: Cost) -> Cost {
        return Cost(
            colorless: a.colorless + b.colorless,
            charm: a.charm + b.charm,
            guile: a.guile + b.guile,
            might: a.might + b.might,
            faith: a.faith + b.faith,
            sharp: a.sharp + b.sharp
        )
    }
    
    func negative() -> Cost {
        return Cost(colorless: -colorless, charm: -charm, guile: -guile, might: -might, faith: -faith, sharp: -sharp)
    }
    
    func convertedManacost() -> Int {
        return self.colorless + self.charm + self.guile + self.might + self.faith + self.sharp
    }
    
    static func from(string: String) -> Cost {
        string.map { (c) -> Cost in
            switch c {
            case "1": return Cost(colorless: 1, charm: 0, guile: 0, might: 0, faith: 0, sharp: 0)
            case "2": return Cost(colorless: 2, charm: 0, guile: 0, might: 0, faith: 0, sharp: 0)
            case "3": return Cost(colorless: 3, charm: 0, guile: 0, might: 0, faith: 0, sharp: 0)
            case "4": return Cost(colorless: 4, charm: 0, guile: 0, might: 0, faith: 0, sharp: 0)
            case "5": return Cost(colorless: 5, charm: 0, guile: 0, might: 0, faith: 0, sharp: 0)
            case "6": return Cost(colorless: 6, charm: 0, guile: 0, might: 0, faith: 0, sharp: 0)
            case "7": return Cost(colorless: 7, charm: 0, guile: 0, might: 0, faith: 0, sharp: 0)
            case "8": return Cost(colorless: 8, charm: 0, guile: 0, might: 0, faith: 0, sharp: 0)
            case "9": return Cost(colorless: 9, charm: 0, guile: 0, might: 0, faith: 0, sharp: 0)
            case "C": return Cost(colorless: 0, charm: 1, guile: 0, might: 0, faith: 0, sharp: 0)
            case "G": return Cost(colorless: 0, charm: 0, guile: 1, might: 0, faith: 0, sharp: 0)
            case "M": return Cost(colorless: 0, charm: 0, guile: 0, might: 1, faith: 0, sharp: 0)
            case "F": return Cost(colorless: 0, charm: 0, guile: 0, might: 0, faith: 1, sharp: 0)
            case "S": return Cost(colorless: 0, charm: 0, guile: 0, might: 0, faith: 0, sharp: 1)
            default: return Cost.free()
            }
        }.reduce(Cost.free()) { (x, y) -> Cost in
            return Cost.add(a: x, b: y)
        }
    }
    
    func toString() -> String {
        let x = self.colorless > 0 ? "\(self.colorless)" : ""
        let c = self.charm > 0 ? (0...self.charm-1).map({ _ in "C" }).joined() : ""
        let g = self.guile > 0 ? (0...self.guile-1).map({ _ in "G" }).joined() : ""
        let m = self.might > 0 ? (0...self.might-1).map({ _ in "M" }).joined() : ""
        let f = self.faith > 0 ? (0...self.faith-1).map({ _ in "F" }).joined() : ""
        let s = self.sharp > 0 ? (0...self.sharp-1).map({ _ in "S" }).joined() : ""
        let result = "\(x)\(c)\(g)\(m)\(f)\(s)"
        if result.count == 0 {
            return "0"
        } else {
            return result
        }
        
    }
    
    func canSubtract(cost: Cost) -> Bool {
     
        let dC = self.charm - cost.charm
        let dG = self.guile - cost.guile
        let dM = self.might - cost.might
        let dF = self.faith - cost.faith
        let dS = self.sharp - cost.sharp
        
        guard dC >= 0 && dG >= 0 && dM >= 0 && dF >= 0 && dS >= 0 else {
            return false
        }
        
        let totalRemainingMana = dC + dG + dM + dF + dS
        
        if totalRemainingMana >= cost.colorless {
            return true
        } else {
            return false
        }
    }
    
}



protocol IDescisionMaker {
    func chooseAction(state: BattleState) -> Promise<PlayerAction>
    func chooseTarget(state: BattleState, card: Card) -> Promise<IDamagable>
}



class Card {

    let uuid: UUID
    let name: String
    let cost: Cost
    let text: String
    
    init(uuid: UUID, name: String, cost: Cost, text: String) {
        self.uuid = uuid
        self.name = name
        self.cost = cost
        self.text = text
    }
    
    func play(state: BattleState, descision: IDescisionMaker) -> Promise<Void> {
        payForCard(state: state, descision: descision).then { (_) -> Promise<Void> in
            self.performAffect(state: state, descision: descision)
        }.then { (_) -> Promise<Void> in
            self.onPostCardPlayed(state: state, descision: descision)
        }
    }
    
    func payForCard(state: BattleState, descision: IDescisionMaker) -> Promise<Void> {
        
        // Pay for the card
        state.playerState.currentMana = Cost.add(a: state.playerState.currentMana, b: self.cost.negative())
         
        // TODO: We might have multiple ways of paying for a card
        return Promise<Void>()
    }
    
    func performAffect(state: BattleState, descision: IDescisionMaker) -> Promise<Void> {
        return Promise<Void>()
    }
    
    func onPostCardPlayed(state: BattleState, descision: IDescisionMaker) -> Promise<Void> {
        return discardCard(state: state)
    }
    
    func discardCard(state: BattleState) -> Promise<Void> {
        state.playerState.discard(card: self)
        return Promise<Void>()
    }
    
}


class CardStrike: Card {
    
    override func performAffect(state: BattleState, descision: IDescisionMaker) -> Promise<Void> {
        descision.chooseTarget(state: state, card: self).then { (damagable) -> Promise<Void> in
            return damagable.applyDamage(damage: 12).asVoid()
        }
    }

    
    class func newInstance() -> CardStrike {
        return CardStrike(
            uuid: UUID(),
            name: "Strike",
            cost: Cost.from(string: "M"),
            text: "Deals 12 damage to a target"
        )
    }
}

class CardCleave: Card {
    
    override func performAffect(state: BattleState, descision: IDescisionMaker) -> Promise<Void> {
        let damagePromises = state.enemies.map { (en) -> Promise<DamageReport> in
            en.body.applyDamage(damage: 11)
        }
        return when(fulfilled: damagePromises).asVoid()
    }
    
    class func newInstance() -> CardCleave {
        return CardCleave(
            uuid: UUID(),
            name: "Cleave",
            cost: Cost.from(string: "M"),
            text: "Deals 11 damage to each enemy"
        )
    }
}

class CardDefend: Card {
    
    override func performAffect(state: BattleState, descision: IDescisionMaker) -> Promise<Void> {
        state.playerState.body.gainBlock(block: 6)
        return Promise<Void>()
    }

    class func newInstance() -> CardDefend {
        return CardDefend(
            uuid: UUID(),
            name: "Defend",
            cost: Cost.from(string: "F"),
            text: "Gain 6 Block"
        )
    }
}

class CardHeal: Card {
    override func performAffect(state: BattleState, descision: IDescisionMaker) -> Promise<Void> {
        state.playerState.body.healHp(heal: 12)
        return Promise<Void>()
    }
    
    class func newInstance() -> Card {
        return CardHeal(
            uuid: UUID(),
            name: "Heal",
            cost: Cost.from(string: "F"),
            text: "Heal for 12"
        )
    }
}

class CardAnger: Card {
    
    override func performAffect(state: BattleState, descision: IDescisionMaker) -> Promise<Void> {
        return descision.chooseTarget(state: state, card: self).then { (damagable) -> Promise<Void> in
            return damagable.applyDamage(damage: 6).asVoid()
        }.done { (_) in
            state.playerState.discard.push(elt: CardAnger.newInstance())
        }
    }

    
    class func newInstance() -> CardAnger {
        return CardAnger(
            uuid: UUID(),
            name: "Anger",
            cost: Cost.free(),
            text: "Deals 6 damage to a target. Put a copy of Anger into your discard pile."
        )
    }
}


class DummyPlayer: IDescisionMaker {
    
    func chooseAction(state: BattleState) -> Promise<PlayerAction> {
        
        // Just play the next card you can afford...
        
        guard let nextCard = (state.playerState.hand.cards.first { (c) -> Bool in
            state.playerState.canPlay(card: c)
        }) else {
            return Promise<PlayerAction>.value(.pass)
        }
        
        return Promise<PlayerAction>.value(.playCard(nextCard))
    }
    

    func chooseTarget(state: BattleState, card: Card) -> Promise<IDamagable> {
        
        guard let enemy = state.enemies.randomElement() else {
            return Promise<IDamagable>.init(error: NSError(domain: "", code: 0, userInfo: nil))
        }
        
        return Promise<IDamagable>.value(enemy.body)
    }
    
}


