//
//  FaithCards.swift
//  Vitruvius
//
//  Created by Benjamin Frost on 29/9/19.
//  Copyright © 2019 Benjamin Frost. All rights reserved.
//

import Foundation
import PromiseKit

//class CardDrain: Card {
//    
//    override func performAffect(state: BattleState, descision: IDescisionMaker) -> Promise<Void> {
//        descision.chooseTarget(state: state, card: self).then { (damagable) -> Promise<DamageReport> in
//            damagable.applyDamage(damage: 6)
//        }.done { (report) in
//            state.playerState.healHp(heal: report.unblockedDamageDealt)
//        }
//    }
//    
//    static func newInstance() -> Card {
//        return CardDrain(
//            uuid: UUID(),
//            name: "Drain",
//            cost: Cost.free(),
//            text: "Drains an opponent for 6"
//        )
//    }
//}
