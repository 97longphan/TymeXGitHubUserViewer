//
//  APIServicesTests.swift
//  TymeXGitHubUserViewerTests
//
//  Created by LONGPHAN on 3/6/25.
//

import Foundation
import XCTest
import RxSwift
import RxBlocking
@testable import TymeXGitHubUserViewer

final class APIServicesTests: XCTestCase {
    var apiService: APIServices!
    var session: URLSession!

    override func setUp() {
        super.setUp()
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        session = URLSession(configuration: config)
        apiService = APIServices(session: session)
    }

    func testFetchUsers_success() throws {
        let mockUsers = [
            User(id: 1, login: "user1", avatar_url: "https://avatar.com/1", url: "https://github.com/user1")
        ]
        let mockData = try JSONEncoder().encode(mockUsers)
        MockURLProtocol.stubResponseData = mockData
        MockURLProtocol.stubError = nil

        let result = try apiService.fetchUsers(since: 0, perPage: 1).toBlocking().single()

        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].login, "user1")
    }

    func testFetchUserDetail_success() throws {
        let mockDetail = UserDetail(login: "user1", name: "User One", company: nil, location: nil, followers: 10, following: 5, avatar_url: nil, html_url: nil)
        let mockData = try JSONEncoder().encode(mockDetail)
        MockURLProtocol.stubResponseData = mockData
        MockURLProtocol.stubError = nil

        let result = try apiService.fetchUserDetail(id: 1).toBlocking().single()

        XCTAssertEqual(result.name, "User One")
        XCTAssertEqual(result.login, "user1")
    }

    func testFetchUsers_invalidJSON_returnsError() {
        MockURLProtocol.stubResponseData = "invalid".data(using: .utf8)
        MockURLProtocol.stubError = nil

        XCTAssertThrowsError(try apiService.fetchUsers(since: 0, perPage: 1).toBlocking().single())
    }

    func testFetchUsers_networkError() {
        MockURLProtocol.stubError = NSError(domain: "Test", code: 123)

        XCTAssertThrowsError(try apiService.fetchUsers(since: 0, perPage: 1).toBlocking().single())
    }
}
