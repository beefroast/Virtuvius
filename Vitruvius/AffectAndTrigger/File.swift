//
//  File.swift
//  Vitruvius
//
//  Created by Benjamin Frost on 29/9/19.
//  Copyright © 2019 Benjamin Frost. All rights reserved.
//

import Foundation


protocol IPlayer {
    
}

enum EventTypes {
    case onTurnBegan(PlayerEvent)
    case onTurnEnded(PlayerEvent)
    case drawCard(PlayerEvent)
    case reduceHp(ReduceHpEvent)
}

class PlayerEvent {
    var player: IPlayer
    init(player: IPlayer) {
        self.player = player
    }
}


class ReduceHpEvent {
    var body: IBody
    var amount: Int
    init(body: IBody, amount: Int) {
        self.body = body
        self.amount = amount
    }
}




class EventHandler {
    
    
    
    func handle(event: EventTypes) -> Void {
    
        switch event {
        
        case .onTurnBegan(let player):
            break
        
        case .onTurnEnded(let player):
            break
        
        case .drawCard(let player):
            break
            
        case .reduceHp(let event):
            event.body.loseHp(damage: event.amount)
            
        
            
        }
    }
    
    
}
