//
//  UserListCacheServiceTests.swift
//  TymeXGitHubUserViewerTests
//
//  Created by LONGPHAN on 3/6/25.
//

import Foundation
import XCTest
import RxSwift
import RxBlocking

@testable import TymeXGitHubUserViewer

final class UserListCacheServiceTests: XCTestCase {
    var cacheService: UserListCacheService!
    var defaults: UserDefaults!

    override func setUp() {
        super.setUp()
        defaults = UserDefaults(suiteName: "TestDefaults")
        defaults.removePersistentDomain(forName: "TestDefaults")
        cacheService = UserListCacheService(defaults: defaults)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: "TestDefaults")
        super.tearDown()
    }

    func testSaveAndLoadUsers_success() throws {
        let users = [User(id: 1, login: "tester", avatar_url: "https://avatar.com", url: "https://github.com/tester")]
        cacheService.save(users)

        let loaded = try cacheService.load().toBlocking().first()
        XCTAssertEqual(loaded?.count, 1)
        XCTAssertEqual(loaded?.first?.login, "tester")
    }

    func testLoad_whenNoData_returnsEmptyArray() throws {
        let loaded = try cacheService.load().toBlocking().first()
        XCTAssertEqual(loaded?.count, 0)
    }

    func testClear_removesData() throws {
        let users = [User(id: 1, login: "tester", avatar_url: "", url: "")]
        cacheService.save(users)
        cacheService.clear()

        let loaded = try cacheService.load().toBlocking().first()
        XCTAssertEqual(loaded?.count, 0)
    }
}
