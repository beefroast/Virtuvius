//
//  ICard.swift
//  Vitruvius
//
//  Created by Benjamin Frost on 1/10/19.
//  Copyright © 2019 Benjamin Frost. All rights reserved.
//

import Foundation


protocol ICard {
    var uuid: UUID { get }
    var name: String { get }
    var requiresSingleTarget: Bool { get }
    var cost: Int { get set }
    
    func resolve(source: Actor, handler: EventHandler, target: Actor?) -> Void
    func onDrawn(source: Actor, handler: EventHandler) -> Void
    func onDiscarded(source: Actor, handler: EventHandler) -> Void
}


