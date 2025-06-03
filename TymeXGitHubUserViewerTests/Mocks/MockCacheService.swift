//
//  MockCacheService.swift
//  TymeXGitHubUserViewerTests
//
//  Created by LONGPHAN on 3/6/25.
//

import RxSwift
import RxCocoa
import Foundation

@testable import TymeXGitHubUserViewer

final class MockCacheService: UserListCacheServiceProtocol {
    var cache: [User] = []
    func load() -> Observable<[User]> {
        .just(cache)
    }
    func save(_ users: [User]) {
        cache = users
    }
    func clear() {
        cache.removeAll()
    }
}
