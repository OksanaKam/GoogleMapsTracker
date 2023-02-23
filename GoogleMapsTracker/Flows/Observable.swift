//
//  Observable.swift
//  GoogleMapsTracker
//
//  Created by Оксана Каменчук on 22.02.2023.
//

import Foundation
import RxSwift

extension Observable {
    
    func unwrap<T>() -> Observable<T> where Element == T? {
        self
            .filter{ $0 != nil }
            .map{ $0! }
    }
}
