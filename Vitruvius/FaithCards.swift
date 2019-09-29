//
//  FaithCards.swift
//  Vitruvius
//
//  Created by Benjamin Frost on 29/9/19.
//  Copyright © 2019 Benjamin Frost. All rights reserved.
//

import Foundation
import PromiseKit

class CardDrain: Card {
    
    override func performAffect(state: BattleState, descision: IDescisionMaker) -> Promise<Void> {
        descision.chooseTarget(state: state, card: self).then { (dmg) -> Promise<DamageReport> in
            dmg.applyDamage(damage: 6)
        }.done { (damage) -> Void in
            state.playerState.healHp(heal: damage.unblockedDamageDealt)
        }
    }
    
    static func newInstance() -> Card {
        return CardDrain(
            uuid: UUID(),
            name: "Drain",
            cost: Cost.free(),
            text: "Drains an opponent for 6"
        )
    }
}
