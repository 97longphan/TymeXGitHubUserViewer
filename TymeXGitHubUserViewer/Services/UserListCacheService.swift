//
//  UserListCacheService.swift
//  TymeXGitHubUserViewer
//
//  Created by LONGPHAN on 3/6/25.
//

import Foundation
import RxSwift

protocol UserListCacheServiceProtocol {
    func save(_ users: [User])
    func load() -> Observable<[User]>
    func clear()
}

final class UserListCacheService: UserListCacheServiceProtocol {
    private let defaults: UserDefaults
    private let key = "cachedUsers"
    
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }
    
    func save(_ users: [User]) {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(users) {
            defaults.set(data, forKey: key)
        }
    }
    
    func load() -> Observable<[User]> {
        return Observable.create { [weak self] observer in
            guard let self = self else {
                observer.onCompleted()
                return Disposables.create()
            }
            
            guard let data = self.defaults.data(forKey: self.key) else {
                observer.onNext([])
                observer.onCompleted()
                return Disposables.create()
            }
            
            let decoder = JSONDecoder()
            let users = (try? decoder.decode([User].self, from: data)) ?? []
            observer.onNext(users)
            observer.onCompleted()
            
            return Disposables.create()
        }
    }
    
    func clear() {
        defaults.removeObject(forKey: key)
    }
}
