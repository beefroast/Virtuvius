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
    
    func resolve(source: Actor, handler: EventHandler, target: Actor?) {
    
        guard let target = target else {
            return
        }
        
        // Push the discard effect
        handler.push(event: Event.discardCard(DiscardCardEvent.init(actor: source, card: self)))
        
        // Push the gain off of damage effect
        handler.effectList.append(
            DrainEffect(
                owner: source,
                sourceUuid: self.uuid
            )
        )
        
        // Push the attack
        handler.push(
            event: Event.attack(
                AttackEvent(
                    sourceUuid: self.uuid,
                    source: source,
                    targets: [target],
                    amount: 6
                )
            )
        )
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
        
        func handle(event: Event, handler: EventHandler) -> Bool {
            
            switch event {
            
            case .didLoseHp(let bodyEvent):
                if (bodyEvent.sourceUuid == self.sourceUuid) {
                    handler.push(
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
