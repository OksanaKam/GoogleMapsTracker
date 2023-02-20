//
//  Coordinate.swift
//  GoogleMapsTracker
//
//  Created by Оксана Каменчук on 16.02.2023.
//

import Foundation
import CoreLocation
import Realm
import RealmSwift

class Coordinate: Object {

    @objc dynamic var latitude: Double = 0.0
    @objc dynamic var longitude: Double = 0.0
   
}
