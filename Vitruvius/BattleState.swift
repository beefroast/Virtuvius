//
//  BattleState.swift
//  Vitruvius
//
//  Created by Benjamin Frost on 28/9/19.
//  Copyright © 2019 Benjamin Frost. All rights reserved.
//

import Foundation
import PromiseKit

enum PlayerAction {
    case playCard(Card)
    case pass
}


enum BattleOutcome {
    case victory
    case defeat
    case ongoing
}

class BattleState {
    
    let player: IDescisionMaker
    let playerState: PlayerState
    var enemies: [Enemy]
    
    init(player: IDescisionMaker, playerState: PlayerState, enemies: [Enemy]) {
        self.player = player
        self.playerState = playerState
        self.enemies = enemies
    }
    
    func outcome() -> BattleOutcome {
        if playerState.hp <= 0 {
            return .defeat
        } else if enemies.count == 0 {
            return .victory
        } else {
            return .ongoing
        }
    }
    
    func tick() -> Promise<BattleOutcome> {
        
        // Ask the player what they want to do
        
        player.chooseAction(state: self).then { (action) -> Promise<Void> in
            
            switch action {
                
            case .playCard(let card):
                print("\nPlayer wants to play \(card.name)\n")
                
                return card.play(state: self, descision: self.player).done { (_) in
                    self.enemies.removeAll { (enemy) -> Bool in
                        enemy.hp <= 0
                    }
                }
                
            case .pass:
                
                print("\nPlayer passes\n")
                
                // Player discards their hand
                self.playerState.discardHand()
                self.playerState.drawCardsIntoHand()
                
                let enemyPromises = self.enemies.map({ $0.takeTurn(state: self) })
                return when(fulfilled: enemyPromises)
                
            }
            
        }.then { (_) -> Promise<BattleOutcome> in
            return Promise<BattleOutcome>.value(self.outcome())
        }
        
    }
    
    var description: String {
        get {
            let playerDescription = self.playerState.description
            let enemies = self.enemies
                .map { (enem) -> String in enem.description }
                .joined(separator: "\n")
            return "---- PLAYER:\n\(playerDescription)\n---- ENEMIES:\n\(enemies)"
        }
        
    }
}
