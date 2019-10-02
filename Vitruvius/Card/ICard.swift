//
//  ICard.swift
//  Vitruvius
//
//  Created by Benjamin Frost on 1/10/19.
//  Copyright © 2019 Benjamin Frost. All rights reserved.
//

import Foundation


enum CardAttributes {
    case attack
    case spell
    case melee
    case ranged
    case buff
    case debuff
    case defence
    case heal
    case summons
}


protocol ICard {
    
    var uuid: UUID { get }
    var name: String { get }
    var requiresSingleTarget: Bool { get }
    var cost: Int { get set }
    
    func resolve(source: Actor, battleState: BattleState, target: Actor?) -> Void
    func onDrawn(source: Actor, battleState: BattleState) -> Void
    func onDiscarded(source: Actor, battleState: BattleState) -> Void
}


