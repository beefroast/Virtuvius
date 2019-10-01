//
//  File.swift
//  Vitruvius
//
//  Created by Benjamin Frost on 29/9/19.
//  Copyright © 2019 Benjamin Frost. All rights reserved.
//

import Foundation


protocol IPlayer {
    var name: String { get }
    var body: IBody { get set }
    func drawCard() -> Void
}

class DummyTarget: IPlayer {
    let name: String
    init(name: String) {
        self.name = name
    }
    func drawCard() -> Void {}
    var body: IBody = DamagableBody(hp: 20, maxHp: 20, currentBlock: 4)
}

protocol ICard {
    var name: String { get }
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
    var player: IPlayer
    var amount: Int
    init(player: IPlayer, amount: Int) {
        self.player = player
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
    
    func popAndHandle() -> Bool {
        guard let e = eventStack.pop() else { return false }
        self.handle(event: e)
        return self.eventStack.isEmpty == false
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
            bodyEvent.player.body.loseHp(damage: bodyEvent.amount)
            self.push(event: Event.didLoseHp(bodyEvent))
            
        case .willLoseBlock(let bodyEvent):
            bodyEvent.player.body.loseBlock(block: bodyEvent.amount)
            self.push(event: Event.didLoseBlock(bodyEvent))
            
        case .didLoseHp(let bodyEvent):
            print("\(bodyEvent.player.name) lost \(bodyEvent.amount) hp")
            
        case .didLoseBlock(let bodyEvent):
            print("\(bodyEvent.player.name) lost \(bodyEvent.amount) block")
            
        case .willGainHp(let bodyEvent):
            bodyEvent.player.body.healHp(heal: bodyEvent.amount)
            self.push(event: Event.didGainHp(bodyEvent))
            
        case .willGainBlock(let bodyEvent):
            bodyEvent.player.body.gainBlock(block: bodyEvent.amount)
            self.push(event: Event.didGainBlock(bodyEvent))
            
        case .didGainHp(let bodyEvent):
            print("\(bodyEvent.player.name) gained \(bodyEvent.amount) hp")
            
        case .didGainBlock(let bodyEvent):
            print("\(bodyEvent.player.name) gained \(bodyEvent.amount) block")
            
        case .playCard(let cardEvent):
            print("\(cardEvent.source.name) played \(cardEvent.card.name)")
            cardEvent.card.resolve(source: cardEvent.source, handler: self)
            
        case .attack(let attackEvent):
            
            attackEvent.targets.forEach { (target) in
                
                print("\(attackEvent.source.name) attacked \(attackEvent.targets.first?.name) for \(attackEvent.amount)")
                
                // Send the event to reduce the block
                
                let updatedBlock = max(target.body.block - attackEvent.amount, 0)
                let blockLost = target.body.block - updatedBlock
                let damageRemaining = attackEvent.amount - blockLost
                
                if damageRemaining > 0 {
                    self.eventStack.push(elt:
                        Event.willLoseHp(
                            UpdateBodyEvent(player: target, amount: damageRemaining)
                        )
                    )
                }
                
                self.eventStack.push(elt:
                    Event.willLoseBlock(
                        UpdateBodyEvent(player: target, amount: blockLost)
                    )
                )
            }
        }
    }
    
}

class EventStrikeCard: ICard {
    
    let name =  "Strike"
    
    func resolve(source: IPlayer, handler: EventHandler) {
        // TODO: Choose a target to attack
        handler.push(
            event: Event.attack(
                AttackEvent(
                    source: source,
                    targets: [DummyTarget(name: "Dummy")],
                    amount: 6
                )
            )
        )
    }
}

class EventDefendCard: ICard {
    let name = "Defend"
    func resolve(source: IPlayer, handler: EventHandler) {
        handler.push(event: Event.willGainBlock(UpdateBodyEvent(player: source, amount: 5)))
    }
}


class EventDoubleDamageCard: ICard {
    
    let name = "Double Damage"
    
    func resolve(source: IPlayer, handler: EventHandler) {
        handler.effectList.append(DoubleDamageTrigger(source: source))
    }
    
    class DoubleDamageTrigger: IEffect {
        
        let source: IPlayer
        
        init(source: IPlayer) {
            self.source = source
        }
        
        func handle(event: Event, handler: EventHandler) -> Bool {
            switch event {
                
            case .attack(let event):
                event.amount = 2 * event.amount
                return true
                
            default:
                return false
            }
        }
    }
    
}
