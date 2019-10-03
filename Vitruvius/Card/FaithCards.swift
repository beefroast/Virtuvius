//
//  FaithCards.swift
//  Vitruvius
//
//  Created by Benjamin Frost on 29/9/19.
//  Copyright © 2019 Benjamin Frost. All rights reserved.
//

import Foundation
import PromiseKit

class CardDrain: ICard {

    
    
    var uuid: UUID = UUID()
    var name: String = "Drain"
    var requiresSingleTarget: Bool = true
    var cost: Int = 1
    
    func resolve(source: Actor, battleState: BattleState, target: Actor?) {

        guard let target = target else {
            return
        }
        
        battleState.eventHandler.push(events: [
            
            // Listen for damage done by this source, and gain that much life
            Event.addEffect(DrainEffect(
                owner: source,
                sourceUuid:
                source.uuid
            )),
            
            // Attack for 6
            Event.attack(AttackEvent.init(
                sourceUuid: self.uuid,
                sourceOwner: source,
                targets: [target],
                amount: 6
            )),
            
            // Discard this card
            Event.discardCard(DiscardCardEvent.init(
                actor: source,
                card: self
            )),
            
        ])
        
    }
    

    
    func onDrawn(source: Actor, battleState: BattleState) {
    }
    
    func onDiscarded(source: Actor, battleState: BattleState) {
    }
    
    class DrainEffect: IEffect {
        
        let owner: Actor
        let sourceUuid: UUID
        var uuid: UUID = UUID()
        var name: String = "Drain"
        
        init(owner: Actor, sourceUuid: UUID) {
            self.owner = owner
            self.sourceUuid = sourceUuid
        }
        
        func handle(event: Event, state: BattleState) -> Bool {
            
            switch event {
            
            case .didLoseHp(let bodyEvent):
                if (bodyEvent.sourceUuid == self.sourceUuid) {
                    state.eventHandler.push(
                        event: Event.willGainHp(
                            UpdateBodyEvent(
                                player: owner,
                                sourceUuid: self.uuid,
                                amount: bodyEvent.amount
                            )
                        )
                    )
                    return true
                } else {
                    return false
                }
                
            case .onTurnEnded(_):
                return true
                
            default:
                return false
            }
        }
    }
}

