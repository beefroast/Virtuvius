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
    
    func resolve(source: Actor, handler: EventHandler, target: Actor?) {
        
        // Push the discard effect
        handler.push(event: Event.discardCard(DiscardCardEvent.init(actor: source, card: self)))
        
        // Add the mist form effect
        handler.effectList.append(
            MistFormEffect(owner: source)
        )
    }
    
    func onDrawn(source: Actor, handler: EventHandler) {}
    func onDiscarded(source: Actor, handler: EventHandler) {}
    
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
