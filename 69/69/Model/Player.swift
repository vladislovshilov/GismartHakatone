//
//  Player.swift
//  69
//
//  Created by Vlados iOS on 7/14/19.
//  Copyright © 2019 Vladislav Shilov. All rights reserved.
//

import UIKit

struct Player {
    var id = -1
    var iconImage = UIImage(named: "iconImagePlaceholder")
    var name = ""
    var level = 1
    var health = 100
    
    var location = Location(longitude: 0, latitude: 0)
}
