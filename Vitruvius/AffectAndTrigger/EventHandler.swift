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
    
    case awaitPlayerTriggeredEvent
    
    case onTurnBegan(PlayerEvent)
    case onTurnEnded(PlayerEvent)
    
    case willDrawCards(DrawCardsEvent)
    case drawCard(PlayerEvent)
    case onCardDrawn(CardDrawnEvent)
    case discardCard(DiscardCardEvent)
    case discardHand(PlayerEvent)
    case destroyCard(DiscardCardEvent)
    case shuffleDiscardIntoDrawPile(PlayerEvent)
        
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

class DrawCardsEvent {
    var actor: Actor
    var amount: Int
    init(actor: Actor, amount: Int) {
        self.actor = actor
        self.amount = amount
    }
}

class CardDrawnEvent {
    var actor: Actor
    var card: ICard
    init(actor: Actor, card: ICard) {
        self.actor = actor
        self.card = card
    }
}

class CardEvent {
    var cardOwner: Actor
    var card: ICard
    var target: Actor?
    init(cardOwner: Actor, card: ICard, target: Actor? = nil) {
        self.cardOwner = cardOwner
        self.card = card
        self.target = target
    }
}

class AttackEvent {
    
    let sourceUuid: UUID
    var sourceOwner: Actor
    var targets: [Actor]
    var amount: Int
    
    init(sourceUuid: UUID, sourceOwner: Actor, targets: [Actor], amount: Int) {
        self.sourceUuid = sourceUuid
        self.sourceOwner = sourceOwner
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
    
    let handlerUuid: UUID = UUID()
    var eventStack: Stack<Event>
    var effectList: [IEffect]
    
    init(eventStack: Stack<Event>, effectList: [IEffect]) {
        self.eventStack = eventStack
        self.effectList = effectList
    }
    
    func push(event: Event) -> Void {
        eventStack.push(elt: event)
    }
    
    func flushEvents(battleState: BattleState) -> Void {
        var hasEvents = !self.eventStack.isEmpty
        while hasEvents {
            _ = self.popAndHandle(battleState: battleState)
            hasEvents = !self.eventStack.isEmpty
        }
    }
    
    func popAndHandle(battleState: BattleState) -> Bool {
        guard let e = eventStack.pop() else { return false }
        self.handle(event: e, battleState: battleState)
        return !self.eventStack.isEmpty
    }
    
    func handle(event: Event, battleState: BattleState) -> Void {
        
        // Loop through the effect list
        self.effectList.removeAll { (effect) -> Bool in
            effect.handle(event: event, handler: self)
        }
    
        switch event {
            
        case .awaitPlayerTriggeredEvent:
            break
        
        case .onTurnBegan(let event):
            
            print("\n\(event.actor.name) turn began.")
            
            // Lose all your block
            // TODO: We might want to lose less block here
            
            self.push(
                event: Event.willLoseBlock(
                    UpdateBodyEvent(player: event.actor, sourceUuid: handlerUuid, amount: event.actor.body.block)
                )
            )
        
        case .onTurnEnded(let event):
            
            print("\n\(event.actor.name) turn ended.")
            
            // Discard hand then draw 5 cards
            // TODO: Make this a variable amount
            
            self.push(event: Event.willDrawCards(DrawCardsEvent(actor: event.actor, amount: 5)))
            self.push(event: Event.discardHand(PlayerEvent(actor: event.actor)))
        
        case .drawCard(let event):
            
            print("\(event.actor.name) draws card.")
            
            guard event.actor.cardZones.drawPile.hasDraw() else {
                guard event.actor.cardZones.discard.isEmpty == false else {
                    // Cannot draw a card or reshuffle so do nothing instead
                    return
                }
                
                // Reshuffle and then draw again
                self.push(event: Event.drawCard(event))
                self.push(event: Event.shuffleDiscardIntoDrawPile(event))
                return
            }
            
            // Draw a card
            guard let card = event.actor.cardZones.drawPile.drawRandom() else {
                return
            }
            
            event.actor.cardZones.hand.cards.append(card)
            self.push(event: Event.onCardDrawn(CardDrawnEvent(actor: event.actor, card: card)))
            
        case .discardCard(let event):
            
            event.actor.cardZones.hand.cards.removeAll { (card) -> Bool in
                card.uuid == event.card.uuid
            }
            event.actor.cardZones.discard.push(elt: event.card)
            
            print("\(event.actor.name) discarded \(event.card.name).")
        
        case .destroyCard(let event):
            break
            
        case .discardHand(let event):
            
            print("\(event.actor.name) discards their hand.")
            
            for card in event.actor.cardZones.hand.cards {
                self.push(event: Event.discardCard(DiscardCardEvent.init(actor: event.actor, card: card)))
            }
            
        case .willDrawCards(let drawCardsEvent):
            
            print("\(drawCardsEvent.actor.name) will draw \(drawCardsEvent.amount) cards.")
            
            // Enqueue a draw for each in amount
            guard drawCardsEvent.amount > 0 else { return }
            for _ in 0...drawCardsEvent.amount-1 {
                self.push(event: Event.drawCard(PlayerEvent(actor: drawCardsEvent.actor)))
            }
            
        case .onCardDrawn(let event):
            
            print("\(event.actor.name) drew \(event.card.name).")
            
            event.card.onDrawn(source: event.actor, battleState: battleState)
            
        case .shuffleDiscardIntoDrawPile(let event):
            
            print("\(event.actor.name) shuffles their discard into their draw pile.")
            
            let discardedCards = event.actor.cardZones.discard.asArray()
            event.actor.cardZones.drawPile.shuffleIn(cards: discardedCards)
            
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
            print("\n\(cardEvent.cardOwner.name) played \(cardEvent.card.name)")
            cardEvent.card.resolve(source: cardEvent.cardOwner, battleState: battleState, target: cardEvent.target)
            
        case .attack(let attackEvent):
            
            attackEvent.targets.forEach { (target) in
                
                print("\(attackEvent.sourceOwner.name) attacked \(String(describing: attackEvent.targets.first?.name)) for \(attackEvent.amount)")
                
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




class EventDoubleDamageCard: ICard {
    
    let uuid: UUID = UUID()
    let name = "Double Damage"
    let requiresSingleTarget: Bool = false
    var cost: Int = 1
    
    func resolve(source: Actor, battleState: BattleState, target: Actor?) {
        battleState.eventHandler.push(event: Event.discardCard(DiscardCardEvent.init(actor: source, card: self)))
        battleState.eventHandler.effectList.append(DoubleDamageTrigger(source: source))
    }
    
    func onDrawn(source: Actor, battleState: BattleState) {}
    func onDiscarded(source: Actor, battleState: BattleState) {}
    
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
    
    func resolve(source: Actor, battleState: BattleState, target: Actor?) {
        battleState.eventHandler.push(event: Event.discardCard(DiscardCardEvent.init(actor: source, card: self)))
        battleState.eventHandler.effectList.append(SandwichTrigger(source: source))
    }
    
    func onDrawn(source: Actor, battleState: BattleState) {}
    func onDiscarded(source: Actor, battleState: BattleState) {}
    
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
                if event.sourceOwner.uuid == self.source.uuid {
                    event.amount += 2
                }
            default: break
            }
            return false
        }
    }
}
