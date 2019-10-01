//
//  ICardPlayer.swift
//  Vitruvius
//
//  Created by Benjamin Frost on 1/10/19.
//  Copyright © 2019 Benjamin Frost. All rights reserved.
//

import Foundation


protocol ICardPlayer {
    var cardZones: CardZones { get set }
}

class CardZones {
    
    let hand: Hand
    let drawPile: DrawPile
    let discard: DiscardPile
    
    init(hand: Hand, drawPile: DrawPile, discard: DiscardPile) {
        self.hand = hand
        self.drawPile = drawPile
        self.discard = discard
    }
}

class Hand {
    var cards: [ICard]
    init(cards: [ICard] = []) {
        self.cards = cards
    }
}

enum CardDraw {
    case specific(ICard)
    case random
}


class DrawPile {
    
    var randomPool: [ICard]
    var draws: [CardDraw]
    
    init(cards: [ICard]) {
        self.randomPool = cards
        self.draws = self.randomPool.map({ _ in return .random })
    }
    
    func drawACard(discardPile: DiscardPile) -> ICard? {
        
        guard draws.count > 0 else {
            
            // Shuffle the discard pile into the draw pile
            self.randomPool = discardPile.asArray()
            
            // If there's no cards to draw after the discard pile has
            // been shuffled in, don't do anything
            if self.randomPool.count == 0 {
                return nil
            }
            
            // Set the draws up with a bunch of random draws
            self.draws = self.randomPool.map({ _ in return .random })
            
            return self.drawACard(discardPile: discardPile)
        }
        
        let draw = self.draws.remove(at: 0)
        
        switch draw {
        
        case .specific(let card):
            return card
            
        case .random:
            let i = (0...self.randomPool.count-1).randomElement()!
            return self.randomPool.remove(at: i)
        }
    }

}

class DiscardPile : Stack<ICard> {
    
    
}
