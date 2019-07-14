//
//  GameConfiguration.swift
//  69
//
//  Created by Vlados iOS on 7/14/19.
//  Copyright © 2019 Vladislav Shilov. All rights reserved.
//

import Foundation

protocol IGameConfiguration {
    var isGameStarted: Bool { get set }
    var slingshotType: SlingshotType { get set }
    var distanceToEnemy: Double { get set }
    
    var power: Int { get set }
    var angle: Int { get set }
}

final class GameConfiguration: IGameConfiguration {
    var isGameStarted = false
    var slingshotType = SlingshotType.common
    var distanceToEnemy = Double()
    
    var power = Int()
    var angle = Int()
}
