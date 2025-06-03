//
//  MockAPIService.swift
//  TymeXGitHubUserViewerTests
//
//  Created by LONGPHAN on 3/6/25.
//
import RxSwift
import RxCocoa
import Foundation

@testable import TymeXGitHubUserViewer

final class MockAPIService: APIServicesProtocol {
    var shouldFail = false
    var dummyUsers: [User] = []
    var userDetail: UserDetail?
    var shouldFailUserDetail = false

    func fetchUsers(since: Int, perPage: Int) -> Single<[User]> {
        if shouldFail {
            return .error(NSError(domain: "Test", code: 0, userInfo: nil))
        }
        return .just(dummyUsers)
    }

    func fetchUserDetail(id: Int) -> Single<UserDetail> {
        if shouldFailUserDetail {
            return .error(NSError(domain: "Test", code: -1))
        }
        return .just(userDetail!)
    }
}
