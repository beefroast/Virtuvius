//
//  Enemy.swift
//  Vitruvius
//
//  Created by Benjamin Frost on 2/10/19.
//  Copyright © 2019 Benjamin Frost. All rights reserved.
//

import Foundation



class Enemy: Actor {

    let preBattleCards: [ICard]

    init(uuid: UUID, name: String, faction: Faction, body: Body, cardZones: CardZones, preBattleCards: [ICard]) {
        self.preBattleCards = preBattleCards
        super.init(uuid: uuid, name: name, faction: faction, body: body, cardZones: cardZones)
    }

    func onBattleBegin(state: BattleState) -> Void {

        // Push all the prebattle card effects on the stack...
        // This gives the enemy a chance to pre-buff before a battle, gaining
        // armour or something like that...
        
        for card in self.preBattleCards {
            state.eventHandler.push(event: Event.playCard(CardEvent.init(cardOwner: self, card: card)))
        }

    }

    func planTurn(state: BattleState) -> Void {
        
        // Can't modify the effects list stack here, so we need to
        // enqueue a plan event...
        // This is fine because we can listen for that event anyway...
        
        state.eventHandler.push(event: Event.onEnemyPlannedTurn(
            EnemyTurnEffect(
                uuid: UUID(),
                enemy: self,
                name: "\(self.name)'s turn",
                events: [
                    Event.playCard(CardEvent(cardOwner: self, card: CardStrike(), target: state.player)),
                ]
            )
        ))
    }
}

class EnemyTurnEffect: IEffect {

    var uuid: UUID
    var enemy: Enemy
    var name: String
    var events: [Event]
    
    init(uuid: UUID, enemy: Enemy, name: String, events: [Event]) {
        self.uuid = uuid
        self.enemy = enemy
        self.name = name
        self.events = events
    }
    
    func handle(event: Event, state: BattleState) -> Bool {
        switch event {
        case .onTurnEnded(let e):
            guard e.actor.faction == .player else {
                return false
            }
            enemy.planTurn(state: state)
            state.eventHandler.push(event: Event.onTurnEnded(PlayerEvent(actor: enemy)))
            for event in events {
                state.eventHandler.push(event: event)
            }
            state.eventHandler.push(event: Event.onTurnBegan(PlayerEvent(actor: enemy)))
            return true
            
        default:
            return false
        }
    }
}
