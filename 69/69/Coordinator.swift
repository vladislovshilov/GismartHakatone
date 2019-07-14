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
        mapScene?.onGameStartHandler = {
            self.showGameScene()
        }
        
        window.rootViewController = mapScene
    }
    
    private func showGameScene() {
        let gameScene = GameViewController.instanceFromStoryboard(.main) as! GameViewController
        gameScene.gameConfiguration = gameConfigurations
        gameScene.onShotHandler = { configurations in
            gameScene.dismiss(animated: true, completion: nil)
            if let configurations = configurations {
                self.gameConfigurations = configurations
                self.mapScene?.gameConfiguration = configurations
            }
        }
        
        window.rootViewController?.present(gameScene, animated: true, completion: nil)
    }
}
