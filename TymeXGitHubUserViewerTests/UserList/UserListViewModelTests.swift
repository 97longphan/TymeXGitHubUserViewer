//
//  UserListViewModelTests.swift
//  TymeXGitHubUserViewerTests
//
//  Created by LONGPHAN on 3/6/25.
//

import XCTest
import RxSwift
import RxTest
import RxBlocking

@testable import TymeXGitHubUserViewer

final class UserListViewModelTests: XCTestCase {
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
    
    func testFetchFromCache() {
        cacheService.cache = [User(id: 1, login: "tester", avatar_url: "", url: "")]
        let scheduler = TestScheduler(initialClock: 0)
        let fetchTrigger = scheduler.createColdObservable([.next(10, ())]).asSignal(onErrorJustReturn: ())
        
        let input = UserListViewModel.Input(
            fetchDataSignal: fetchTrigger,
            loadMoreSignalAtIndex: .empty(),
            selectedUserSignal: .empty(),
            reloadDataSignal: .empty(),
            clearCacheSignal: .empty()
        )
        
        let output = viewModel.transform(input: input)
        
        let observer = scheduler.createObserver([User].self)
        output.users.drive(observer).disposed(by: disposeBag)
        
        scheduler.start()
        
        let users = observer.events.compactMap { $0.value.element }.flatMap { $0 }
        XCTAssertEqual(users.count, 1)
        XCTAssertEqual(users[0].login, "tester")
    }
    
    func testFetchUserDetailTriggersRouter() {
        let scheduler = TestScheduler(initialClock: 0)
        let selectedUser = User(id: 99, login: "tester", avatar_url: "", url: "")
        let userSelectTrigger = scheduler.createColdObservable([.next(10, selectedUser)]).asSignal(onErrorJustReturn: selectedUser)
        
        let detail = UserDetail(
            login: "tester",
            name: "Long Phan",
            company: "Techcombank",
            location: "Hanoi",
            followers: 100,
            following: 50,
            avatar_url: "https://avatar.com/1.png",
            html_url: "https://github.com/tester"
        )
        apiService.userDetail = detail
        
        let input = UserListViewModel.Input(
            fetchDataSignal: .empty(),
            loadMoreSignalAtIndex: .empty(),
            selectedUserSignal: userSelectTrigger,
            reloadDataSignal: .empty(),
            clearCacheSignal: .empty()
        )
        
        _ = viewModel.transform(input: input)
        
        scheduler.start()
        XCTAssertTrue(router.didNavigateToDetail)
    }
    
    func testClearCacheEmitsToast() {
        let scheduler = TestScheduler(initialClock: 0)
        let clearCacheTrigger = scheduler.createColdObservable([.next(10, ())]).asSignal(onErrorJustReturn: ())
        
        let input = UserListViewModel.Input(
            fetchDataSignal: .empty(),
            loadMoreSignalAtIndex: .empty(),
            selectedUserSignal: .empty(),
            reloadDataSignal: .empty(),
            clearCacheSignal: clearCacheTrigger
        )
        
        let output = viewModel.transform(input: input)
        let observer = scheduler.createObserver(String.self)
        output.toastMessage.drive(observer).disposed(by: disposeBag)
        
        scheduler.start()
        
        let messages = observer.events.compactMap { $0.value.element }
        XCTAssertTrue(messages.contains("Deleted cache"))
    }
    
    func testReloadDataSignalLoadsFromRemote() {
        // Arrange
        apiService.dummyUsers = [
            User(id: 100, login: "longphan", avatar_url: "", url: "")
        ]
        
        let scheduler = TestScheduler(initialClock: 0)
        let reloadTrigger = scheduler.createColdObservable([.next(10, ())]).asSignal(onErrorJustReturn: ())
        
        let input = UserListViewModel.Input(
            fetchDataSignal: .empty(),
            loadMoreSignalAtIndex: .empty(),
            selectedUserSignal: .empty(),
            reloadDataSignal: reloadTrigger,
            clearCacheSignal: .empty()
        )
        
        let output = viewModel.transform(input: input)
        let usersObserver = scheduler.createObserver([User].self)
        
        output.users
            .drive(usersObserver)
            .disposed(by: disposeBag)
        
        scheduler.start()
        
        let events = usersObserver.events
        let emittedUsers = events
            .compactMap { $0.value.element }
            .flatMap { $0 }
        
        XCTAssertEqual(emittedUsers.count, 1)
        XCTAssertEqual(emittedUsers[0].id, 100)
        XCTAssertEqual(emittedUsers[0].login, "longphan")
    }
    
    func testFetchDataSignal_whenCacheIsEmpty_loadsFromRemoteAndShowToast() {
        cacheService.cache = []
        apiService.dummyUsers = [
            User(id: 200, login: "no-cache", avatar_url: "", url: "")
        ]
        
        let scheduler = TestScheduler(initialClock: 0)
        let fetchTrigger = scheduler.createColdObservable([.next(5, ())]).asSignal(onErrorJustReturn: ())
        
        let input = UserListViewModel.Input(
            fetchDataSignal: fetchTrigger,
            loadMoreSignalAtIndex: .empty(),
            selectedUserSignal: .empty(),
            reloadDataSignal: .empty(),
            clearCacheSignal: .empty()
        )
        
        let output = viewModel.transform(input: input)
        
        let usersObserver = scheduler.createObserver([User].self)
        let toastObserver = scheduler.createObserver(String.self)
        
        output.users
            .drive(usersObserver)
            .disposed(by: disposeBag)
        
        output.toastMessage
            .drive(toastObserver)
            .disposed(by: disposeBag)
        
        scheduler.start()
        
        let emittedUsers = usersObserver.events
            .compactMap { $0.value.element }
            .flatMap { $0 }
        
        XCTAssertEqual(emittedUsers.count, 1)
        XCTAssertEqual(emittedUsers[0].login, "no-cache")
        
        let toastMessages = toastObserver.events.compactMap { $0.value.element }
        XCTAssertTrue(toastMessages.contains("List loaded from remote"))
    }
    
    func testFetchUsers_onFailure_emitsErrorAndStopsLoading() {
        apiService.shouldFail = true
        
        let scheduler = TestScheduler(initialClock: 0)
        let fetchTrigger = scheduler.createColdObservable([.next(5, ())]).asSignal(onErrorJustReturn: ())
        
        let input = UserListViewModel.Input(
            fetchDataSignal: fetchTrigger,
            loadMoreSignalAtIndex: .empty(),
            selectedUserSignal: .empty(),
            reloadDataSignal: .empty(),
            clearCacheSignal: .empty()
        )
        
        let output = viewModel.transform(input: input)
        
        let errorObserver = scheduler.createObserver(String.self)
        let loadingObserver = scheduler.createObserver(Bool.self)
        
        output.errorMessage
            .drive(errorObserver)
            .disposed(by: disposeBag)
        
        output.isLoading
            .drive(loadingObserver)
            .disposed(by: disposeBag)
        
        scheduler.start()
        
        let errorMessages = errorObserver.events.compactMap { $0.value.element }
        XCTAssertEqual(errorMessages.count, 1)
        XCTAssertTrue(errorMessages[0].contains("Test"))
        let loadingValues = loadingObserver.events.compactMap { $0.value.element }
        XCTAssertEqual(loadingValues, [false, true, false])
    }
    
    func testLoadMoreSignalAtIndex_appendsUsers_whenNearBottom() {
        let initialUsers = (1...20).map { User(id: $0, login: "user\($0 ?? 0)", avatar_url: "", url: "") }
        let moreUsers = (21...25).map { User(id: $0, login: "user\($0 ?? 0)", avatar_url: "", url: "") }
        
        cacheService.cache = []
        apiService.dummyUsers = initialUsers
        
        let scheduler = TestScheduler(initialClock: 0)
        
        let fetchTrigger = scheduler
            .createColdObservable([.next(5, ())])
            .asSignal(onErrorJustReturn: ())
        
        let loadMoreTrigger = scheduler
            .createColdObservable([.next(10, 18)])
            .asSignal(onErrorJustReturn: 0)
        
        let input = UserListViewModel.Input(
            fetchDataSignal: fetchTrigger,
            loadMoreSignalAtIndex: loadMoreTrigger,
            selectedUserSignal: .empty(),
            reloadDataSignal: .empty(),
            clearCacheSignal: .empty()
        )
        
        let output = viewModel.transform(input: input)
        
        let usersObserver = scheduler.createObserver([User].self)
        output.users.drive(usersObserver).disposed(by: disposeBag)
        
        scheduler.scheduleAt(8) {
            self.apiService.dummyUsers = moreUsers
        }
        
        scheduler.start()
        
        let userCounts = usersObserver.events
            .compactMap { $0.value.element?.count }
        
        XCTAssertTrue(userCounts.last ?? 0 >= 25)
        
        let allUsers = usersObserver.events
            .compactMap { $0.value.element }
            .last ?? []
        
        XCTAssertTrue(allUsers.contains(where: { $0.login == "user25" }))
    }
    
    func testSelectedUserSignal_emitsErrorOnFailure() {
        let dummyUser = User(id: 404, login: "notfound", avatar_url: "", url: "")
        apiService.shouldFailUserDetail = true // mô phỏng lỗi

        let scheduler = TestScheduler(initialClock: 0)
        let selectedUserTrigger = scheduler
            .createColdObservable([.next(5, dummyUser)])
            .asSignal(onErrorJustReturn: dummyUser)

        let input = UserListViewModel.Input(
            fetchDataSignal: .empty(),
            loadMoreSignalAtIndex: .empty(),
            selectedUserSignal: selectedUserTrigger,
            reloadDataSignal: .empty(),
            clearCacheSignal: .empty()
        )

        let output = viewModel.transform(input: input)

        let errorObserver = scheduler.createObserver(String.self)
        output.errorMessage
            .drive(errorObserver)
            .disposed(by: disposeBag)

        scheduler.start()

        let messages = errorObserver.events.compactMap { $0.value.element }
        XCTAssertEqual(messages.count, 1)
        XCTAssertTrue(messages[0].contains("Test")) // từ NSError mô phỏng
    }
    
    func testSelectedUserSignal_showsUserDetailOnSuccess() {
        let dummyUser = User(id: 999, login: "tester", avatar_url: "", url: "")
        
        let detail = UserDetail(
            login: "tester",
            name: "Long Phan",
            company: "Techcombank",
            location: "Hanoi",
            followers: 100,
            following: 50,
            avatar_url: "https://avatar.com/1.png",
            html_url: "https://github.com/tester"
        )
        apiService.userDetail = detail

        let scheduler = TestScheduler(initialClock: 0)
        let selectedUserTrigger = scheduler
            .createColdObservable([.next(10, dummyUser)])
            .asSignal(onErrorJustReturn: dummyUser)

        let input = UserListViewModel.Input(
            fetchDataSignal: .empty(),
            loadMoreSignalAtIndex: .empty(),
            selectedUserSignal: selectedUserTrigger,
            reloadDataSignal: .empty(),
            clearCacheSignal: .empty()
        )

        _ = viewModel.transform(input: input)

        scheduler.start()

        XCTAssertTrue(router.didNavigateToDetail)
    }



}
