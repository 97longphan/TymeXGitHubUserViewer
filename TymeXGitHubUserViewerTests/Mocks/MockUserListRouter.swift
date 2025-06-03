//
//  MockUserListRouter.swift
//  TymeXGitHubUserViewerTests
//
//  Created by LONGPHAN on 3/6/25.
//

import Foundation
@testable import TymeXGitHubUserViewer

final class MockRouter: UserListRouterProtocol {
    var didNavigateToDetail = false
    func showUserDetail(user: UserDetail) {
        didNavigateToDetail = true
    }
}
