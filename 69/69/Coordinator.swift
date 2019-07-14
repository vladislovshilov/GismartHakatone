//
//  Coordinator.swift
//  69
//
//  Created by Vlados iOS on 7/14/19.
//  Copyright © 2019 Vladislav Shilov. All rights reserved.
//

import UIKit

protocol Coordinatable {
    func start()
}

final class Coordinator {
    // MARK: - Properties
    private let window: UIWindow
    private var mapScene: MapViewController?
    private var gameScene: GameViewController?
    
    private var gameConfigurations = GameConfiguration()
    
    init(window: UIWindow) {
        self.window = window
    }
}

// MARK: - Coordinatable

extension Coordinator: Coordinatable {
    func start() {
        showMapScene()
    }
    
    private func showMapScene() {
        mapScene = MapViewController.instanceFromStoryboard(.main) as! MapViewController
        mapScene?.gameConfiguration = gameConfigurations
        mapScene?.players = createPlayers()
        
        mapScene?.onGameStartHandler = { player in
            self.showGameScene(with: player)
        }
        mapScene?.onGameContinueHandler = {
            guard let gameScene = self.gameScene else { return }
            self.showGameScene(gameScene)
        }
        
        window.rootViewController = mapScene
    }
    
    private func showGameScene(with enemyPlayer: Player) {
        gameScene = createGameScene(with: enemyPlayer)
        guard let scene = gameScene else { return }
        showGameScene(scene)
    }
    
    private func showGameScene(_ scene: UIViewController) {
        window.rootViewController?.present(scene, animated: true, completion: nil)
    }
    
    private func createGameScene(with enemyPlayer: Player) -> GameViewController {
        let gameScene = GameViewController.instanceFromStoryboard(.main) as! GameViewController
        gameScene.gameConfiguration = gameConfigurations
        gameScene.enemyPlayer = enemyPlayer
        
        gameScene.onShotHandler = { configurations in
            gameScene.dismiss(animated: true, completion: nil)
            if let configurations = configurations {
                self.gameConfigurations = configurations
                self.mapScene?.gameConfiguration = configurations
                self.mapScene?.showProjectileAnimation()
            }
        }
        
        return gameScene
    }
    
    private func createPlayers() -> [Player] {
        var players = [1, 2, 3].map({ index -> Player in
            let longitude = Double.random(in: 27.65...27.71)
            let latitude = Double.random(in: 53.82...53.85)
            let location = Location(longitude: longitude,
                                    latitude: latitude)
            
            return Player(id: index,
                          iconImage: UIImage(named: "iconImagePlaceholder"),
                          name: "Jane",
                          level: index + 1,
                          health: 100,
                          location: location)
        })
        
        let location = Location(longitude: 27.696686,
                                latitude: 53.846243)
        players.append(Player(id: 5,
                              iconImage: UIImage(named: "iconImagePlaceholder"),
                              name: "Ne Jane",
                              level: 5,
                              health: 100,
                              location: location))
        
        return players
    }
}
