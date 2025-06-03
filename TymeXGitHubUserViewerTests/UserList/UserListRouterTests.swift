//
//  UserListRouterTests.swift
//  TymeXGitHubUserViewer
//
//  Created by LONGPHAN on 3/6/25.
//


import XCTest
@testable import TymeXGitHubUserViewer

final class UserListRouterTests: XCTestCase {
    func testShowUserDetail_pushesUserDetailViewController_andDisplaysInfo() {
        let mockNav = MockNavigationController()
        let router = UserListRouter(navigationController: mockNav)

        let user = UserDetail(
            login: "tester",
            name: "Test User",
            company: "Test Inc",
            location: "Hanoi",
            followers: 123,
            following: 456,
            avatar_url: nil,
            html_url: nil
        )

        router.showUserDetail(user: user)

        guard let pushedVC = mockNav.pushedViewController as? UserDetailViewController else {
            return XCTFail("Expected UserDetailViewController to be pushed")
        }
        
        pushedVC.loadViewIfNeeded()

        XCTAssertEqual(pushedVC.nameLabel.text, "tester")
        XCTAssertEqual(pushedVC.followerCountLabel.text, "123")
    }

}
