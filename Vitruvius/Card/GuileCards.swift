//
//  GuileCards.swift
//  Vitruvius
//
//  Created by Benjamin Frost on 29/9/19.
//  Copyright © 2019 Benjamin Frost. All rights reserved.
//

import Foundation
import PromiseKit

class CardMistForm: ICard {
    
    var uuid: UUID = UUID()
    var name: String = "Mist Form"
    var requiresSingleTarget: Bool = false
    var cost: Int = 1
    
    func resolve(source: Actor, battleState: BattleState, target: Actor?) {
        
        // Push the discard effect
        battleState.eventHandler.push(event: Event.discardCard(DiscardCardEvent.init(actor: source, card: self)))
        
        // Add the mist form effect
        battleState.eventHandler.effectList.append(
            MistFormEffect(owner: source)
        )
    }
    
    func onDrawn(source: Actor, battleState: BattleState) {}
    func onDiscarded(source: Actor, battleState: BattleState) {}
    
    class MistFormEffect: IEffect {
        
        let owner: Actor
        var uuid: UUID = UUID()
        var name: String = "Mist Form"
        
        init(owner: Actor) {
            self.owner = owner
        }
        
        func handle(event: Event, handler: EventHandler) -> Bool {
            switch event {
                
            case .attack(let attackEvent):
                attackEvent.amount = 0
                return true
                
            default:
                return false
            }
        }
        
    }
}

class CardPierce: ICard {
    
    var uuid: UUID = UUID()
    var name: String = "Pierce"
    var requiresSingleTarget: Bool = true
    var cost: Int = 2
    
    func resolve(source: Actor, battleState: BattleState, target: Actor?) {
        
        // Push the discard effect
        battleState.eventHandler.push(event: Event.discardCard(DiscardCardEvent.init(actor: source, card: self)))
        
        // Attack straight through ignore armour
        battleState.eventHandler.push(
            event: Event.willLoseHp(
                UpdateBodyEvent.init(
                    player:
                    source,
                    sourceUuid: self.uuid,
                    amount: 18
                )
            )
        )
    }
    
    func onDrawn(source: Actor, battleState: BattleState) {}
    func onDiscarded(source: Actor, battleState: BattleState) {}
}
