//
//  MightCards.swift
//  Vitruvius
//
//  Created by Benjamin Frost on 29/9/19.
//  Copyright © 2019 Benjamin Frost. All rights reserved.
//

import Foundation
import PromiseKit

class CardDiamondBody: Card {
    override func performAffect(state: BattleState, descision: IDescisionMaker) -> Promise<Void> {
        state.playerState.body = DiamondBody.init(body: state.playerState.body)
        return Promise<Void>()
    }
    static func newInstance() -> Card {
        return CardDiamondBody(
            uuid: UUID(),
            name: "Diamond Body",
            cost: Cost.free(),
            text: "Whenever you would lose HP, lose 1 fewer HP."
        )
    }
}

class DiamondBody: DamagableProxy {
    override func loseHp(damage: Int) -> Int {
        return super.loseHp(damage: max(damage-1, 0))
    }
}
