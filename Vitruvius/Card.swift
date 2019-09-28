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
}

protocol IDamagable {
    func applyDamage(damage: Int) -> Promise<Bool>
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
        return Promise<Void>()
    }
}


class CardStrike: Card {
    
    override func play(state: BattleState, descision: IDescisionMaker) -> Promise<Void> {
        return descision.chooseTarget(state: state, card: self).then { (damagable) -> Promise<Void> in
            return damagable.applyDamage(damage: 12).asVoid()
        }.done { (_) in
            state.playerState.discard(card: self)
        }
    }
    
    class func newInstance() -> CardStrike {
        return CardStrike(
            uuid: UUID(),
            name: "Strike",
            cost: Cost.free(),
            text: "Deals 12 damage to a target"
        )
    }
    
}

class CardDefend: Card {
    override func play(state: BattleState, descision: IDescisionMaker) -> Promise<Void> {
        state.playerState.currentBlock += 6
        state.playerState.discard(card: self)
        return Promise<Void>()
    }
    
    class func newInstance() -> CardDefend {
        return CardDefend(
            uuid: UUID(),
            name: "Defend",
            cost: Cost.free(),
            text: "Gain 6 Block"
        )
    }
}




class DummyPlayer: IDescisionMaker {
    
    func chooseAction(state: BattleState) -> Promise<PlayerAction> {
        
        // Just play the next card in your hand...
        
        guard let nextCard = state.playerState.hand.cards.first else {
            return Promise<PlayerAction>.value(.pass)
        }
        
        return Promise<PlayerAction>.value(.playCard(nextCard))
    }
    

    func chooseTarget(state: BattleState, card: Card) -> Promise<IDamagable> {
        
        guard let enemy = state.enemies.randomElement() else {
            return Promise<IDamagable>.init(error: NSError(domain: "", code: 0, userInfo: nil))
        }
        
        return Promise<IDamagable>.value(enemy)
    }
    
}


