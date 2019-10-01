//
//  GuileCards.swift
//  Vitruvius
//
//  Created by Benjamin Frost on 29/9/19.
//  Copyright © 2019 Benjamin Frost. All rights reserved.
//

import Foundation
import PromiseKit

//class CardMistForm: Card {
//    override func performAffect(state: BattleState, descision: IDescisionMaker) -> Promise<Void> {
//        state.playerState.body = EffectMistForm(body: state.playerState.body)
//        return Promise<Void>()
//    }
//    static func newInstance() -> Card {
//        return CardMistForm(
//            uuid: UUID(),
//            name: "Mist Form",
//            cost: Cost.free(),
//            text: "Avoid the next time you would take damage."
//        )
//    }
//}
//
//class EffectMistForm: BodyProxy {
//    override var description: String {
//        return "[MIST] \(super.description)"
//    }
//    override func loseHp(damage: Int) -> (Int, IBody) {
//        if (damage > 0) {
//            print("Mist prevented \(damage) damage")
//            return (0, self.body)
//        } else {
//            return (0, self)
//        }
//    }
//}
