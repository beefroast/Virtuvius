//
//  File.swift
//  Vitruvius
//
//  Created by Benjamin Frost on 29/9/19.
//  Copyright © 2019 Benjamin Frost. All rights reserved.
//

import Foundation






protocol IEffect {
    var uuid: UUID { get }
    var name: String { get }
    func handle(event: Event, handler: EventHandler) -> Bool
}

enum Event {
    case onTurnBegan(PlayerEvent)
    case onTurnEnded(PlayerEvent)
    
    case drawCard(PlayerEvent)
    case discardCard(DiscardCardEvent)
        
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

class DiscardCardEvent {
    let actor: Actor
    let card: ICard
    init(actor: Actor, card: ICard) {
        self.actor = actor
        self.card = card
    }
}



class PlayerEvent {
    var actor: Actor
    init(actor: Actor) {
        self.actor = actor
    }
}

class CardEvent {
    var source: Actor
    var card: ICard
    var target: Actor?
    init(source: Actor, card: ICard, target: Actor? = nil) {
        self.source = source
        self.card = card
        self.target = target
    }
}

class AttackEvent {
    let sourceUuid: UUID
    var source: Actor
    var targets: [Actor]
    var amount: Int
    
    init(sourceUuid: UUID, source: Actor, targets: [Actor], amount: Int) {
        self.sourceUuid = sourceUuid
        self.source = source
        self.targets = targets
        self.amount = amount
    }
}

class UpdateBodyEvent {
    
    var player: Actor
    let sourceUuid: UUID
    var amount: Int
    
    init(player: Actor, sourceUuid: UUID, amount: Int) {
        self.player = player
        self.sourceUuid = sourceUuid
        self.amount = amount
    }
    
    func with(amount: Int) -> UpdateBodyEvent {
        return UpdateBodyEvent(
            player: self.player,
            sourceUuid: self.sourceUuid,
            amount: amount
        )
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
        
        case .drawCard(let event):
            // TODO: Draw cards
            break
            
            
        case .discardCard(let event):
            event.actor.cardZones.hand.cards.removeAll { (card) -> Bool in
                card.uuid == event.card.uuid
            }
            print("\(event.actor.name) discarded \(event.card.name)")

        
        case .willLoseHp(let bodyEvent):
            // Calculate the amount of lost HP
            let remainingHp = max(bodyEvent.player.body.hp - bodyEvent.amount, 0)
            let lostHp = bodyEvent.player.body.hp - remainingHp
            guard lostHp > 0 else {
                return
            }
            bodyEvent.player.body.hp -= lostHp
            self.push(event: Event.didLoseHp(bodyEvent))
            
        case .willLoseBlock(let bodyEvent):
            let remainingBlock = max(bodyEvent.player.body.block - bodyEvent.amount, 0)
            let lostBlock = bodyEvent.player.body.block - remainingBlock
            guard lostBlock > 0 else {
                return
            }
            bodyEvent.player.body.block -= lostBlock
            self.push(event: Event.didLoseBlock(bodyEvent))
            
        case .didLoseHp(let bodyEvent):
            print("\(bodyEvent.player.name) lost \(bodyEvent.amount) hp")
            print("\(bodyEvent.player.name) has \(bodyEvent.player.body.description)")
            
        case .didLoseBlock(let bodyEvent):
            print("\(bodyEvent.player.name) lost \(bodyEvent.amount) block")
            print("\(bodyEvent.player.name) has \(bodyEvent.player.body.description)")
            
        case .willGainHp(let bodyEvent):
            // Gain up to your maximum HP
            let nextHp = min(bodyEvent.player.body.hp + bodyEvent.amount, bodyEvent.player.body.maxHp)
            let gainedLife = nextHp - bodyEvent.player.body.hp
            bodyEvent.player.body.hp += gainedLife
            let event = bodyEvent.with(amount: gainedLife)
            self.push(event: Event.didGainHp(event))
            
        case .willGainBlock(let bodyEvent):
            bodyEvent.player.body.block += bodyEvent.amount
            self.push(event: Event.didGainBlock(bodyEvent))
            
        case .didGainHp(let bodyEvent):
            print("\(bodyEvent.player.name) gained \(bodyEvent.amount) hp")
            print("\(bodyEvent.player.name) has \(bodyEvent.player.body.description)")
            
        case .didGainBlock(let bodyEvent):
            print("\(bodyEvent.player.name) gained \(bodyEvent.amount) block")
            print("\(bodyEvent.player.name) has \(bodyEvent.player.body.description)")
            
        case .playCard(let cardEvent):
            print("\(cardEvent.source.name) played \(cardEvent.card.name)")
            cardEvent.card.resolve(source: cardEvent.source, handler: self, target: cardEvent.target)
            
        case .attack(let attackEvent):
            
            attackEvent.targets.forEach { (target) in
                
                print("\(attackEvent.source.name) attacked \(String(describing: attackEvent.targets.first?.name)) for \(attackEvent.amount)")
                
                // Send the event to reduce the block
                
                let updatedBlock = max(target.body.block - attackEvent.amount, 0)
                let blockLost = target.body.block - updatedBlock
                let damageRemaining = attackEvent.amount - blockLost
                
                if damageRemaining > 0 {
                    self.eventStack.push(elt:
                        Event.willLoseHp(
                            UpdateBodyEvent(player: target, sourceUuid: attackEvent.sourceUuid, amount: damageRemaining)
                        )
                    )
                }
                
                self.eventStack.push(elt:
                    Event.willLoseBlock(
                        UpdateBodyEvent(player: target, sourceUuid: attackEvent.sourceUuid, amount: blockLost)
                    )
                )
            }
        }
    }
    
}

class EventStrikeCard: ICard {
    
    let uuid: UUID = UUID()
    let name =  "Strike"
    let requiresSingleTarget: Bool = true
    var cost: Int = 1
    
    func resolve(source: Actor, handler: EventHandler, target: Actor?) {
        
        guard let target = target else {
            return
        }
        
        handler.push(event: Event.discardCard(DiscardCardEvent.init(actor: source, card: self)))
        
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
}



class EventDefendCard: ICard {
    
    let uuid: UUID = UUID()
    let name =  "Defend"
    let requiresSingleTarget: Bool = false
    var cost: Int = 1
    
    func resolve(source: Actor, handler: EventHandler, target: Actor?) {
        handler.push(event: Event.discardCard(DiscardCardEvent.init(actor: source, card: self)))
        handler.push(event: Event.willGainBlock(UpdateBodyEvent(player: source, sourceUuid: self.uuid, amount: 5)))
    }
}


class EventDoubleDamageCard: ICard {
    
    let uuid: UUID = UUID()
    let name = "Double Damage"
    let requiresSingleTarget: Bool = false
    var cost: Int = 1
    
    func resolve(source: Actor, handler: EventHandler, target: Actor?) {
        handler.push(event: Event.discardCard(DiscardCardEvent.init(actor: source, card: self)))
        handler.effectList.append(DoubleDamageTrigger(source: source))
    }
    
    class DoubleDamageTrigger: IEffect {
        
        let uuid: UUID = UUID()
        let name = "Double Damage"
        let source: Actor
        
        init(source: Actor) {
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

class EventSandwichCard: ICard {

    let uuid: UUID = UUID()
    let name = "Sandwich"
    let requiresSingleTarget: Bool = false
    var cost: Int = 1
    
    func resolve(source: Actor, handler: EventHandler, target: Actor?) {
        handler.push(event: Event.discardCard(DiscardCardEvent.init(actor: source, card: self)))
        handler.effectList.append(SandwichTrigger(source: source))
    }
    
    class SandwichTrigger: IEffect {
        
        let uuid: UUID = UUID()
        let name = "+2 Damage"
        let source: Actor
        
        init(source: Actor) {
            self.source = source
        }
        
        func handle(event: Event, handler: EventHandler) -> Bool {
            switch event {
            case .attack(let event):
                if event.source.uuid == self.source.uuid {
                    event.amount += 2
                }
            default: break
            }
            return false
        }
    }
}
