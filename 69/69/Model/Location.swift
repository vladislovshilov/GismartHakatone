//
//  Location.swift
//  69
//
//  Created by Vlados iOS on 7/14/19.
//  Copyright © 2019 Vladislav Shilov. All rights reserved.
//

import Foundation
import CoreLocation

struct Location {
    var longitude: Double
    var latitude: Double
    
    init(longitude: Double, latitude: Double) {
        self.longitude = longitude
        self.latitude = latitude
    }
    
    init(coordinates: CLLocationCoordinate2D) {
        self.longitude = coordinates.longitude
        self.latitude = coordinates.latitude
    }
    
    func toCoordinates() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
