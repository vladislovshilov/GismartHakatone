//
//  FloatiingPoint.swift
//  69
//
//  Created by Vlados iOS on 7/13/19.
//  Copyright © 2019 Vladislav Shilov. All rights reserved.
//

import Foundation

extension FloatingPoint {
    func toRadians() -> Self {
        return self * .pi / 180
    }
    
    func toDegrees() -> Self {
        return self * 180 / .pi
    }
}
