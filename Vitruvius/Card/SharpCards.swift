//
//  SharpCards.swift
//  Vitruvius
//
//  Created by Benjamin Frost on 1/10/19.
//  Copyright © 2019 Benjamin Frost. All rights reserved.
//

import Foundation


class CardRecall : ICard {
    
    var uuid: UUID = UUID()
    var name: String = "Recall"
    var requiresSingleTarget: Bool = false
    var cost: Int = 0
    
    func resolve(source: Actor, battleState: BattleState, target: Actor?) {
        battleState.eventHandler.push(event: Event.discardCard(DiscardCardEvent.init(actor: source, card: self)))
        battleState.eventHandler.push(event: Event.willDrawCards(DrawCardsEvent.init(actor: source, amount: 3)))
    }
    
    func onDrawn(source: Actor, battleState: BattleState) {}
    func onDiscarded(source: Actor, battleState: BattleState) {}
}

class CardFireball: ICard {
    
    var uuid: UUID = UUID()
    var name: String = "Fireball"
    var requiresSingleTarget: Bool = false
    var cost: Int = 2
    
    // Need to somehow target everyone at once...
    
    func resolve(source: Actor, battleState: BattleState, target: Actor?) {
        battleState.eventHandler.push(event: Event.discardCard(DiscardCardEvent.init(actor: source, card: self)))
        let targets = battleState.getAllOpponentActors(faction: source.faction)
        battleState.eventHandler.push(
            event: Event.attack(AttackEvent.init(sourceUuid: self.uuid, sourceOwner: source, targets: targets, amount: 8))
        )
    }
    
    func onDrawn(source: Actor, battleState: BattleState) {}
    func onDiscarded(source: Actor, battleState: BattleState) {}
    
}
