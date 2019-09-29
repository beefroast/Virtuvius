//
//  PlayerState.swift
//  Vitruvius
//
//  Created by Benjamin Frost on 28/9/19.
//  Copyright © 2019 Benjamin Frost. All rights reserved.
//

import Foundation
import PromiseKit

class PlayerState: IDamagable {

    var body: IBody
    func set(body: IBody) {
        self.body = body
    }
    
    var currentMana: Cost
    var manaPerTurn: Cost
    let hand: Hand
    let drawPile: DrawPile
    let discard: DiscardPile
    
    init(withCards: [Card]) {
        self.body = DamagableBody(hp: 20, maxHp: 20, currentBlock: 0)
        self.currentMana = Cost.free()
        self.manaPerTurn = Cost.init(colorless: 0, charm: 0, guile: 0, might: 2, faith: 2, sharp: 0)
        self.hand = Hand(cards: [])
        self.drawPile = DrawPile(cards: withCards)
        self.discard = DiscardPile()
    }
    
    func addManaForTurn() {
        self.currentMana = Cost.add(a: self.currentMana, b: self.manaPerTurn)
    }
    
    func drawCardsIntoHand() -> Void {
        let drawnCards = (0...4)
            .map({ _ in drawPile.drawACard(discardPile: self.discard) })
            .compactMap({ $0 })
        self.hand.cards = drawnCards
    }
    
    func discard(card: Card) -> Void {
        self.discard.push(elt: card)
        self.hand.cards.removeAll { (c) -> Bool in
            c.uuid == card.uuid
        }
    }
    
    func discardHand() -> Void {
        for card in self.hand.cards {
            self.discard.push(elt: card)
        }
        self.hand.cards = []
    }
    
    func endTurn() -> Void {
        
        // Discard your hand
        self.discardHand()
        
        // Draw up
        self.drawCardsIntoHand()
        
    }
    
    func canPlay(card: Card) -> Bool {
        return self.currentMana.canSubtract(cost: card.cost)
    }
    
    func startTurn() -> Void {
        // Get some mana at the start of your turn...
        self.currentMana = Cost.add(a: self.currentMana, b: self.manaPerTurn)
    }
    
    var description: String {
        get {
            let lines = [
                "BODY: \(self.body.description)",
                "Mana: \(self.currentMana.toString())",
                "Hand: \(self.hand.cards.map({ $0.name }).joined(separator: ", "))",
                "Deck/Discard: \(self.drawPile.draws.count) \(self.discard.getCount())"
            ]
            return lines.joined(separator: "\n")
        }
    }
    
    // Turn hooks
    
    func onTurnBegins() {
        // Lose all your current block
        self.body.loseBlock(block: self.body.block)
        // Get mana
        self.addManaForTurn()
    }
    
    func onTurnEnds() {
        // Discard your hand
        self.discardHand()
        self.drawCardsIntoHand()
    }
    
}

class Hand {
    
    var cards: [Card]
    
    init(cards: [Card] = []) {
        self.cards = cards
    }
    
}




enum CardDraw {
    case specific(Card)
    case random
}


class DrawPile {
    
    var randomPool: [Card]
    var draws: [CardDraw]
    
    init(cards: [Card]) {
        self.randomPool = cards
        self.draws = self.randomPool.map({ _ in return .random })
    }
    
    func drawACard(discardPile: DiscardPile) -> Card? {
        
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

class DiscardPile : Stack<Card> {
    
    
}
