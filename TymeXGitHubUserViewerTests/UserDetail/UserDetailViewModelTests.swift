//
//  UserDetailViewModelTests.swift
//  TymeXGitHubUserViewerTests
//
//  Created by LONGPHAN on 3/6/25.
//

import XCTest
@testable import TymeXGitHubUserViewer

final class UserDetailViewModelTests: XCTestCase {
    func testTransformReturnsCorrectUserDetail() {
        // Arrange
        let mockDetail = UserDetail(
            login: "longphan",
            name: "Long Phan",
            company: "Techcombank",
            location: "Hanoi",
            followers: 100,
            following: 50,
            avatar_url: "https://avatar.com/1.png",
            html_url: "https://github.com/longphan"
        )

        let viewModel = UserDetailViewModel(userDetail: mockDetail)

        // Act
        let output = viewModel.transform(input: .init())

        // Assert
        XCTAssertEqual(output.userDetail.name, "Long Phan")
        XCTAssertEqual(output.userDetail.login, "longphan")
        XCTAssertEqual(output.userDetail.followers, 100)
        XCTAssertEqual(output.userDetail.avatar_url, "https://avatar.com/1.png")
    }
}
