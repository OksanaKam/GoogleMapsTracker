//
//  User.swift
//  GoogleMapsTracker
//
//  Created by Оксана Каменчук on 21.02.2023.
//

import Foundation
import RealmSwift

class User: Object {
    
    @objc dynamic var login = ""
    @objc dynamic var password = ""
    
    class override func primaryKey() -> String? {
        return "login"
    }
}
