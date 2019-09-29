//
//  CharmCards.swift
//  Vitruvius
//
//  Created by Benjamin Frost on 28/9/19.
//  Copyright © 2019 Benjamin Frost. All rights reserved.
//

import Foundation
import PromiseKit


class CardSingingSword: Card {
    override func performAffect(state: BattleState, descision: IDescisionMaker) -> Promise<Void> {
        // TODO: Summon a singing sword
        return super.performAffect(state: state, descision: descision)
    }
    
}

class CardLullabye: Card {
    override func performAffect(state: BattleState, descision: IDescisionMaker) -> Promise<Void> {
        // TODO: Reduce the cost of the next card you play
        return super.performAffect(state: state, descision: descision)
    }
}



