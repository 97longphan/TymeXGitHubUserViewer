//
//  UserListCacheService.swift
//  TymeXGitHubUserViewer
//
//  Created by LONGPHAN on 3/6/25.
//

import Foundation
import RxSwift

/// Protocol defining methods for caching and retrieving user list data.
protocol UserListCacheServiceProtocol {
    /// Saves a list of users to cache.
    /// - Parameter users: The array of `User` objects to be cached.
    func save(_ users: [User])

    /// Loads the list of users from cache.
    /// - Returns: An `Observable` emitting the cached user array.
    func load() -> Observable<[User]>

    /// Clears all cached user data.
    func clear()
}

/// Concrete implementation of `UserListCacheServiceProtocol` using `UserDefaults`.
final class UserListCacheService: UserListCacheServiceProtocol {

    /// The underlying `UserDefaults` instance used for persistence.
    private let defaults: UserDefaults

    /// The key under which user data is stored.
    private let key = "cachedUsers"

    /// Initializes the service with a given `UserDefaults` instance.
    /// - Parameter defaults: Defaults to `.standard`.
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    /// Saves the provided list of users into UserDefaults.
    /// - Parameter users: An array of `User` to save.
    func save(_ users: [User]) {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(users) {
            defaults.set(data, forKey: key)
        }
    }

    /// Loads users from UserDefaults.
    /// - Returns: An observable emitting an array of `User` objects.
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

    /// Clears the cached user list from UserDefaults.
    func clear() {
        defaults.removeObject(forKey: key)
    }
}
