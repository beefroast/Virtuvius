//
//  NeutralCards.swift
//  Vitruvius
//
//  Created by Benjamin Frost on 1/10/19.
//  Copyright © 2019 Benjamin Frost. All rights reserved.
//

import Foundation


class CardStrike: ICard {
    
    let uuid: UUID = UUID()
    let name =  "Strike"
    let requiresSingleTarget: Bool = true
    var cost: Int = 1
    
    func resolve(source: Actor, battleState: BattleState, target: Actor?) {
        
        guard let target = target else {
            return
        }
        
        battleState.eventHandler.push(event: Event.discardCard(DiscardCardEvent.init(actor: source, card: self)))
        
        battleState.eventHandler.push(
            event: Event.attack(
                AttackEvent(
                    sourceUuid: self.uuid,
                    sourceOwner: source,
                    targets: [target],
                    amount: 6
                )
            )
        )
    }
    
    func onDrawn(source: Actor, battleState: BattleState) {}
    func onDiscarded(source: Actor, battleState: BattleState) {}
}



class CardDefend: ICard {
    
    let uuid: UUID = UUID()
    let name =  "Defend"
    let requiresSingleTarget: Bool = false
    var cost: Int = 1
    
    func resolve(source: Actor, battleState: BattleState, target: Actor?) {
        battleState.eventHandler.push(event: Event.discardCard(DiscardCardEvent.init(actor: source, card: self)))
        battleState.eventHandler.push(event: Event.willGainBlock(UpdateBodyEvent(player: source, sourceUuid: self.uuid, amount: 5)))
    }
    
    func onDrawn(source: Actor, battleState: BattleState) {}
    func onDiscarded(source: Actor, battleState: BattleState) {}
}
