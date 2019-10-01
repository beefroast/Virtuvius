//
//  File.swift
//  Vitruvius
//
//  Created by Benjamin Frost on 29/9/19.
//  Copyright © 2019 Benjamin Frost. All rights reserved.
//

import Foundation


protocol IPlayer {
    var body: IBody { get set }
    func drawCard() -> Void
}

class DummyTarget: IPlayer {
    func drawCard() -> Void {}
    var body: IBody = DamagableBody(hp: 20, maxHp: 20, currentBlock: 4)
}

protocol ICard {
    func resolve(source: IPlayer, handler: EventHandler) -> Void
}

protocol IEffect {
    func handle(event: Event, handler: EventHandler) -> Bool
}

enum Event {
    case onTurnBegan(PlayerEvent)
    case onTurnEnded(PlayerEvent)
    case drawCard(PlayerEvent)
    
    case willLoseHp(UpdateBodyEvent)
    case willLoseBlock(UpdateBodyEvent)
    case didLoseHp(UpdateBodyEvent)
    case didLoseBlock(UpdateBodyEvent)
    
    case willGainHp(UpdateBodyEvent)
    case willGainBlock(UpdateBodyEvent)
    case didGainHp(UpdateBodyEvent)
    case didGainBlock(UpdateBodyEvent)
    
    case playCard(CardEvent)
    case attack(AttackEvent)
}

class PlayerEvent {
    var player: IPlayer
    init(player: IPlayer) {
        self.player = player
    }
}

class CardEvent {
    var source: IPlayer
    var card: ICard
    init(source: IPlayer, card: ICard) {
        self.source = source
        self.card = card
    }
}

class AttackEvent {
    var source: IPlayer
    var targets: [IPlayer]
    var amount: Int
    init(source: IPlayer, targets: [IPlayer], amount: Int) {
        self.source = source
        self.targets = targets
        self.amount = amount
    }
}

class UpdateBodyEvent {
    var body: IBody
    var amount: Int
    init(body: IBody, amount: Int) {
        self.body = body
        self.amount = amount
    }
}


class EventHandler {
    
    var eventStack: Stack<Event>
    var effectList: [IEffect]
    
    init(eventStack: Stack<Event>, effectList: [IEffect]) {
        self.eventStack = eventStack
        self.effectList = effectList
    }
    
    func push(event: Event) -> Void {
        eventStack.push(elt: event)
    }
    
    func popAndHandle() -> Void {
        guard let e = eventStack.pop() else { return }
        self.handle(event: e)
    }
    
    func handle(event: Event) -> Void {
        
        // Loop through the effect list
        self.effectList.removeAll { (effect) -> Bool in
            effect.handle(event: event, handler: self)
        }
    
        switch event {
        
        case .onTurnBegan(let player):
            break
        
        case .onTurnEnded(let player):
            break
        
        case .drawCard(let player):
            break
            
        
        case .willLoseHp(let bodyEvent):
            bodyEvent.body.loseHp(damage: bodyEvent.amount)
            self.push(event: Event.didLoseHp(bodyEvent))
            
        case .willLoseBlock(let bodyEvent):
            bodyEvent.body.loseBlock(block: bodyEvent.amount)
            self.push(event: Event.didLoseBlock(bodyEvent))
            
        case .didLoseHp(let bodyEvent):
            break
            
        case .didLoseBlock(let bodyEvent):
            break
            
        case .willGainHp(let bodyEvent):
            bodyEvent.body.healHp(heal: bodyEvent.amount)
            self.push(event: Event.didGainHp(bodyEvent))
            
        case .willGainBlock(let bodyEvent):
            bodyEvent.body.gainBlock(block: bodyEvent.amount)
            self.push(event: Event.didGainBlock(bodyEvent))
            
        case .didGainHp(let bodyEvent):
            break
            
        case .didGainBlock(let bodyEvent):
            break
            
            
        case .playCard(let cardEvent):
            cardEvent.card.resolve(source: cardEvent.source, handler: self)
            
        case .attack(let attackEvent):
            attackEvent.targets.forEach { (target) in
                
                // Send the event to reduce the block
                
                let updatedBlock = max(target.body.block - attackEvent.amount, 0)
                let blockLost = target.body.block - updatedBlock
                let damageRemaining = attackEvent.amount - blockLost
                
                if damageRemaining > 0 {
                    self.eventStack.push(elt:
                        Event.willLoseHp(
                            UpdateBodyEvent(body: target.body, amount: damageRemaining)
                        )
                    )
                }
                
                self.eventStack.push(elt:
                    Event.willLoseBlock(
                        UpdateBodyEvent(body: target.body, amount: blockLost)
                    )
                )
            }
        }
    }
    
}

class EventStrikeCard: ICard {
    
    func resolve(source: IPlayer, handler: EventHandler) {
        // TODO: Choose a target to attack
        handler.push(
            event: Event.attack(
                AttackEvent(
                    source: source,
                    targets: [DummyTarget()],
                    amount: 6
                )
            )
        )
    }
    
}
