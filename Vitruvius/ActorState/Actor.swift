//
//  Actor.swift
//  Vitruvius
//
//  Created by Benjamin Frost on 1/10/19.
//  Copyright © 2019 Benjamin Frost. All rights reserved.
//

import Foundation


class Actor: IDamagable, ICardPlayer {
    
    let uuid: UUID
    let name: String
    var body: Body
    var cardZones: CardZones
    
    init(uuid: UUID, name: String, body: Body, cardZones: CardZones) {
        self.uuid = uuid
        self.name = name
        self.body = body
        self.cardZones = cardZones
    }
}
