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

    func planTurn(state: BattleState) -> Event {
        
        // Can't modify the effects list stack here, so we need to
        // enqueue a plan event...
        // This is fine because we can listen for that event anyway...
        
        return Event.onEnemyPlannedTurn(
            EnemyTurnEffect(
                uuid: UUID(),
                enemy: self,
                name: "\(self.name)'s turn",
                events: [
                    Event.playCard(CardEvent(cardOwner: self, card: CardStrike(), target: state.player)),
                ]
            )
        )
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
            
        case .onEnemyDefeated(let e):
            
            // Remove this event if the enemy is defeated...
            return e.uuid == self.enemy.uuid
            
        case .onTurnBegan(let e):
            
            // When our turn begins...
            guard e.actor.uuid == self.enemy.uuid else {
                return false
            }
            
            state.eventHandler.push(events:
                
                // Do our planned turn
                events + [
                    
                // Plan our next turn
                enemy.planTurn(state: state),
                
                //End our turn
                Event.onTurnEnded(PlayerEvent.init(actor: enemy))
            
            ])
            
            // Remove this listener
            return true
            
        default:
            return false
        }
    }
}
