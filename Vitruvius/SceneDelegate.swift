//
//  SceneDelegate.swift
//  Vitruvius
//
//  Created by Benjamin Frost on 27/9/19.
//  Copyright © 2019 Benjamin Frost. All rights reserved.
//

import UIKit
import SwiftUI
import PromiseKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).

        // Create the SwiftUI view that provides the window contents.
        let contentView = ContentView()
        
        
        
        
        let handler = EventHandler(eventStack: StackQueue<Event>(), effectList: [])
        
        let dummy = Actor(
            uuid: UUID(),
            name: "Player",
            faction: .player,
            body: Body(block: 0, hp: 70, maxHp: 70),
            cardZones: CardZones(
                hand: Hand(cards: []),
                drawPile: DrawPile(cards: [
                    CardStrike(),
                    CardDefend(),
                    CardFireball(),
                    CardDefend(),
                    CardStrike(),
                    CardDefend(),
                    CardStrike(),
                    CardDefend(),
                    CardStrike(),
                    CardDefend(),
                ]),
                discard: DiscardPile()
            )
        )
        
        let enemy = Enemy(
            uuid: UUID(),
            name: "Goomba",
            faction: .enemies,
            body: Body(block: 0, hp: 40, maxHp: 40),
            cardZones: CardZones(
                hand: Hand(),
                drawPile: DrawPile(cards: []),
                discard: DiscardPile()
            ),
            preBattleCards: []
        )
        
        
        let koopa = Enemy(
            uuid: UUID(),
            name: "Koopa",
            faction: .enemies,
            body: Body(block: 0, hp: 40, maxHp: 40),
            cardZones: CardZones(
                hand: Hand(),
                drawPile: DrawPile(cards: []),
                discard: DiscardPile()
            ),
            preBattleCards: []
        )
        
        let bowser = Enemy(
            uuid: UUID(),
            name: "Bowser",
            faction: .enemies,
            body: Body(block: 0, hp: 40, maxHp: 40),
            cardZones: CardZones(
                hand: Hand(),
                drawPile: DrawPile(cards: []),
                discard: DiscardPile()
            ),
            preBattleCards: []
        )
        
        let battleState = BattleState(
            player: dummy,
            allies: [],
            enemies: [enemy, koopa, bowser],
            eventHandler: handler
        )
        
        // Set up the end of turn draw amount triggers
        handler.effectList.append(
            DiscardThenDrawAtEndOfTurnEffect(
                uuid: UUID(),
                ownerUuid: dummy.uuid,
                name: "Player discard then draw.",
                cardsDrawn: 5
            )
        )
                
        handler.push(event: Event.onBattleBegan)
        handler.flushEvents(battleState: battleState)
        
        var target = battleState.enemies.first
        
        while target != nil && dummy.body.hp > 0 {
            
            var nextCard = dummy.cardZones.hand.cards.first
        
            while nextCard != nil && target != nil && dummy.body.hp > 0 {
                handler.push(event: Event.playCard(
                    CardEvent.init(cardOwner: dummy, card: dummy.cardZones.hand.cards.first!, target: target)
                ))
                handler.flushEvents(battleState: battleState)
                                
                target = battleState.enemies.first
                nextCard = dummy.cardZones.hand.cards.first
            }
            
            if target != nil && dummy.body.hp > 0 {
                handler.push(event: Event.onTurnEnded(PlayerEvent(actor: dummy)))
                handler.flushEvents(battleState: battleState)
            }
            
            target = battleState.enemies.first
        }
        
        print("\nSimulation Done!")
        
            
//
//        handler.push(event: Event.playCard(CardEvent.init(cardOwner: enemy, card: EventStrikeCard(), target: dummy)))
//
//        handler.push(
//            event: Event.playCard(
//                CardEvent.init(cardOwner: dummy, card: EventStrikeCard(), target: enemy)
//            )
//        )
//
//        handler.push(
//            event: Event.playCard(
//                CardEvent.init(cardOwner: dummy, card: EventStrikeCard(), target: enemy)
//            )
//        )
//
//        handler.push(
//            event: Event.playCard(
//                CardEvent.init(cardOwner: dummy, card: EventSandwichCard())
//            )
//        )
//
//
//        handler.push(event: Event.playCard(CardEvent.init(cardOwner: dummy, card: EventDefendCard())))
//
//        handler.push(event: Event.playCard(CardEvent.init(cardOwner: enemy, card: EventDefendCard())))
//
//        handler.push(event: Event.playCard(CardEvent.init(cardOwner: dummy, card: CardDrain(), target: enemy)))
//        handler.push(event: Event.playCard(CardEvent.init(cardOwner: dummy, card: CardDrain(), target: enemy)))
//        handler.push(event: Event.playCard(CardEvent.init(cardOwner: dummy, card: CardDrain(), target: enemy)))
//
//        handler.push(event: Event.playCard(CardEvent.init(cardOwner: enemy, card: CardMistForm())))
        
//
//        print("Beginning")
//
//        var performNext: Bool = true
//        while performNext {
//            performNext = handler.popAndHandle()
//        }
//
//
//
//
//        print("Ending")
        
        
        
        
//        let game = GameSimulator()
//
//        game.simulateGame().done { (outcome) in
//            print("yay")
//        }
//
//
//        // Test some costs
//        let testCosts = ["0", "1", "8", "G", "3GGG", "GM", "8GM", "2CGMFS"]
//
//        let results = testCosts.map { (s) -> (String, Cost) in
//            return (s, Cost.from(string: s))
//        }.map { (tuple) -> String in
//            return "\(tuple.0) -> \(tuple.1.toString())"
//        }.joined(separator: "\n")
//
//        print(results)
        
        
        
        

        // Use a UIHostingController as window root view controller.
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: contentView)
            self.window = window
            window.makeKeyAndVisible()
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}



//class GameSimulator {
//
//
//    func simulateGame() -> Promise<BattleOutcome> {
//
//        let state = PlayerState(withCards: [
//            CardStrike.newInstance(),
//            CardStrike.newInstance(),
//            CardStrike.newInstance(),
//            CardDrain.newInstance(),
//            CardMistForm.newInstance(),
//            CardDefend.newInstance(),
//            CardDefend.newInstance(),
//            CardDefend.newInstance(),
//        ])
//
//        let battleState = BattleState(player: DummyPlayer(), playerState: state, enemies: [
//            EnemyGoomba.newInstance(),
//            EnemyGoomba.newInstance(),
//            EnemyGoomba.newInstance(),
//        ])
//
//        battleState.playerState.drawCardsIntoHand()
//        battleState.playerState.onTurnBegins()
//
//        return tick(battleState: battleState)
//    }
//
//    func tick(battleState: BattleState) -> Promise<BattleOutcome> {
//
//        return battleState.tick().then { (outcome) -> Promise<BattleOutcome> in
//
//            print(battleState.description)
//
//            switch outcome {
//            case .defeat:
//                print("PLAYER DEFEATED!")
//                return Promise<BattleOutcome>.value(outcome)
//
//            case .victory:
//                print("PLAYER VICTORIOUS")
//                return Promise<BattleOutcome>.value(outcome)
//
//            case .ongoing:
//                return self.tick(battleState: battleState)
//            }
//
//
//        }
//
//    }
//
//}
