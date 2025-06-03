//
//  UserListViewModelNonRxTests.swift
//  TymeXGitHubUserViewerTests
//
//  Created by LONGPHAN on 3/6/25.
//

import Foundation
import XCTest
import RxSwift
import RxCocoa

@testable import TymeXGitHubUserViewer

final class UserListViewModelNonRxTests: XCTestCase {
    var viewModel: UserListViewModel!
    var apiService: MockAPIService!
    var cacheService: MockCacheService!
    var router: MockRouter!
    var disposeBag: DisposeBag!

    override func setUp() {
        super.setUp()
        apiService = MockAPIService()
        cacheService = MockCacheService()
        router = MockRouter()
        viewModel = UserListViewModel(router: router,
                                      apiService: apiService,
                                      cacheService: cacheService)
        disposeBag = DisposeBag()
    }

    func testFetchUserDetailTriggersRouter_nonRx() {
        let selectedUserTrigger = PublishRelay<User>()
        let dummyUser = User(id: 123, login: "tester", avatar_url: "", url: "")
        apiService.userDetail = UserDetail(name: "Test User")

        let input = UserListViewModel.Input(
            fetchDataSignal: .empty(),
            loadMoreSignalAtIndex: .empty(),
            selectedUserSignal: selectedUserTrigger.asSignal(),
            reloadDataSignal: .empty(),
            clearCacheSignal: .empty()
        )

        _ = viewModel.transform(input: input)

        let expect = expectation(description: "Router called")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertTrue(self.router.didNavigateToDetail)
            expect.fulfill()
        }

        selectedUserTrigger.accept(dummyUser)
        wait(for: [expect], timeout: 1.0)
    }

    func testClearCacheEmitsToast_nonRx() {
        let clearTrigger = PublishRelay<Void>()
        let input = UserListViewModel.Input(
            fetchDataSignal: .empty(),
            loadMoreSignalAtIndex: .empty(),
            selectedUserSignal: .empty(),
            reloadDataSignal: .empty(),
            clearCacheSignal: clearTrigger.asSignal()
        )

        let output = viewModel.transform(input: input)

        var toast: String?
        let expect = expectation(description: "Toast emitted")
        output.toastMessage.drive(onNext: {
            toast = $0
            expect.fulfill()
        }).disposed(by: disposeBag)

        clearTrigger.accept(())
        wait(for: [expect], timeout: 1.0)

        XCTAssertEqual(toast, "Deleted cache")
    }

    func testFetchDataSignal_whenCacheIsEmpty_loadsRemoteAndToast_nonRx() {
        cacheService.cache = []
        apiService.dummyUsers = [User(id: 200, login: "no-cache", avatar_url: "", url: "")]
        let fetchTrigger = PublishRelay<Void>()

        let input = UserListViewModel.Input(
            fetchDataSignal: fetchTrigger.asSignal(),
            loadMoreSignalAtIndex: .empty(),
            selectedUserSignal: .empty(),
            reloadDataSignal: .empty(),
            clearCacheSignal: .empty()
        )

        let output = viewModel.transform(input: input)

        var users: [User] = []
        var toast: String?
        let expect = expectation(description: "Load remote + toast")
        output.users.drive(onNext: { users = $0 }).disposed(by: disposeBag)
        output.toastMessage.drive(onNext: {
            toast = $0
            expect.fulfill()
        }).disposed(by: disposeBag)

        fetchTrigger.accept(())
        wait(for: [expect], timeout: 1.0)

        XCTAssertEqual(users.count, 1)
        XCTAssertEqual(toast, "List loaded from remote")
    }

    func testFetchUsers_onFailure_emitsErrorAndStopsLoading_nonRx() {
        apiService.shouldFail = true
        let fetchTrigger = PublishRelay<Void>()

        let input = UserListViewModel.Input(
            fetchDataSignal: fetchTrigger.asSignal(),
            loadMoreSignalAtIndex: .empty(),
            selectedUserSignal: .empty(),
            reloadDataSignal: .empty(),
            clearCacheSignal: .empty()
        )

        let output = viewModel.transform(input: input)

        var errorMessage: String?
        var loadingStates: [Bool] = []
        let expect = expectation(description: "Error and loading states")
        output.errorMessage.drive(onNext: { errorMessage = $0 }).disposed(by: disposeBag)
        output.isLoading.drive(onNext: {
            loadingStates.append($0)
            if loadingStates.count >= 3 { expect.fulfill() }
        }).disposed(by: disposeBag)

        fetchTrigger.accept(())
        wait(for: [expect], timeout: 1.0)

        XCTAssertEqual(errorMessage, "The operation couldn’t be completed. (Test error 0.)")
        XCTAssertEqual(loadingStates.suffix(3), [false,true, false])
    }

    func testSelectedUserSignal_emitsErrorOnFailure_nonRx() {
        apiService.shouldFailUserDetail = true
        let selectedUserTrigger = PublishRelay<User>()
        let dummyUser = User(id: 404, login: "notfound", avatar_url: "", url: "")

        let input = UserListViewModel.Input(
            fetchDataSignal: .empty(),
            loadMoreSignalAtIndex: .empty(),
            selectedUserSignal: selectedUserTrigger.asSignal(),
            reloadDataSignal: .empty(),
            clearCacheSignal: .empty()
        )

        let output = viewModel.transform(input: input)

        var errorMessage: String?
        let expect = expectation(description: "User detail fail")
        output.errorMessage.drive(onNext: {
            errorMessage = $0
            expect.fulfill()
        }).disposed(by: disposeBag)

        selectedUserTrigger.accept(dummyUser)
        wait(for: [expect], timeout: 1.0)

        XCTAssertNotNil(errorMessage)
    }
}
