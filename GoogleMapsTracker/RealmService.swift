//
//  RealmService.swift
//  GoogleMapsTracker
//
//  Created by Оксана Каменчук on 16.02.2023.
//

import Foundation
import GoogleMaps
import Realm
import RealmSwift

class RealmService {
    
    private let realm: Realm
  
    init() {
        do {
            let config = Realm.Configuration(schemaVersion: 1, deleteRealmIfMigrationNeeded: true)
            self.realm = try Realm(configuration: config)
            debugPrint(realm.configuration.fileURL as Any)
        } catch {
            debugPrint(error)
            fatalError("Error with Realm")
        }
    }
        
    func getRealm() -> Realm {
        return realm
    }
    
    func putCoordinate(coordinates: [CLLocationCoordinate2D]){

        do {
            for coordinate in coordinates {
                let coordinateModel = Coordinate()
                coordinateModel.latitude  = coordinate.latitude
                coordinateModel.longitude = coordinate.longitude
                try realm.write{
                    realm.add(coordinateModel)
                }
            }
        } catch {
            print(error)
        }
    }
        
    func getCoodinate() -> [CLLocationCoordinate2D]{
            
        var returnCoordinate = [CLLocationCoordinate2D]()
        for coordinate in realm.objects(Coordinate.self) {
            var locationCoordinate = CLLocationCoordinate2D()
            locationCoordinate.latitude  = coordinate.latitude
            locationCoordinate.longitude = coordinate.longitude
            returnCoordinate.append(locationCoordinate)
        }
        return returnCoordinate
    }
        
    func removeCoordinate(){
        
        do {
            try realm.write {
                realm.delete(realm.objects(Coordinate.self))
            }
        } catch {
            print(error)
        }
    }
    
    func register(user: User) -> User {
            
        guard let userData = realm.objects(User.self).filter("login == '\(user.login)'").first else {
            do {
                try realm.write{
                    realm.add(user)
                }
            } catch {
                print(error)
            }
            return user
        }
        do {
            try realm.write{
                realm.add(user, update: .modified)
            }
        } catch {
            print(error)
        }
        return userData
    }
        
    func login(user: User) -> Bool{
            
        guard let _ = realm.objects(User.self).filter("login == '\(user.login)' AND password == '\(user.password)'").first else {
            return false
        }
        return true
    }
}
