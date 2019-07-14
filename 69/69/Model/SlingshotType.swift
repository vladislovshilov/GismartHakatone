//
//  SlingshotType.swift
//  69
//
//  Created by Vlados iOS on 7/14/19.
//  Copyright © 2019 Vladislav Shilov. All rights reserved.
//

import Foundation

enum SlingshotType {
    case common, double
    
    var maxDistance: Double {
        switch self {
        case .common:
            return 20000
        case .double:
            return 40000
        }
    }
}
