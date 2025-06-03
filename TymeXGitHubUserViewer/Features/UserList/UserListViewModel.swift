//
//  UserListViewModel.swift
//  TymeXGitHubUserViewer
//
//  Created by LONGPHAN on 3/6/25.
//

import Foundation
import RxSwift
import RxCocoa

final class UserListViewModel: ViewModelType {
    // MARK: - Services
    private let apiService: APIServicesProtocol
    private let cacheService: UserListCacheServiceProtocol
    
    // MARK: - Router
    private let router: UserListRouterProtocol
    
    // MARK: - Variables
    private let usersRelay = BehaviorRelay<[User]>(value: [])
    private let errorRelay = PublishRelay<String>()
    private let loadingRelay = BehaviorRelay<Bool>(value: false)
    private let toastRelay = PublishRelay<String>()
    private let disposeBag = DisposeBag()
    
    private var since = 0 // cursor for pagination
    private let perPage = 20
    private var hasMore = true // stop fetching if no more data
    
    // MARK: - Init
    init(router: UserListRouterProtocol,
         apiService: APIServicesProtocol,
         cacheService: UserListCacheServiceProtocol) {
        self.router = router
        self.apiService = apiService
        self.cacheService = cacheService
    }
    
    private func fetchUsers(fromStart: Bool = false) {
        guard !loadingRelay.value else { return }
        loadingRelay.accept(true)
        
        if fromStart {
            since = 0
            hasMore = true
            usersRelay.accept([])
        }
        
        apiService.fetchUsers(since: since, perPage: perPage)
            .subscribe(
                onSuccess: { [weak self] newUsers in
                    guard let self = self else { return }
                    
                    var current = self.usersRelay.value
                    current.append(contentsOf: newUsers)
                    self.usersRelay.accept(current)
                    
                    // Save to cache
                    self.cacheService.save(current)
                    
                    // Update cursor
                    self.since = newUsers.last?.id ?? self.since
                    self.hasMore = !newUsers.isEmpty
                    self.loadingRelay.accept(false)
                },
                onFailure: { [weak self] error in
                    self?.errorRelay.accept(error.localizedDescription)
                    self?.loadingRelay.accept(false)
                }
            )
            .disposed(by: disposeBag)
    }
    
    private func fetchUserDetail(_ id: Int) {
        guard !loadingRelay.value else { return }
        loadingRelay.accept(true)
        
        apiService.fetchUserDetail(id: id)
            .observe(on: MainScheduler.instance)
            .subscribe(
                onSuccess: { [weak self] userDetail in
                    guard let self = self else { return }
                    self.loadingRelay.accept(false)
                    self.router.showUserDetail(user: userDetail)
                },
                onFailure: { [weak self] error in
                    self?.errorRelay.accept(error.localizedDescription)
                    self?.loadingRelay.accept(false)
                }
            )
            .disposed(by: disposeBag)
    }
    
}

extension UserListViewModel {
    // MARK: - Input / Output
    struct Input {
        let fetchDataSignal: Signal<Void>
        let loadMoreSignalAtIndex: Signal<Int>
        let selectedUserSignal: Signal<User>
        let reloadDataSignal: Signal<Void>
        let clearCacheSignal: Signal<Void>
    }
    
    struct Output {
        let users: Driver<[User]>
        let isLoading: Driver<Bool>
        let errorMessage: Driver<String>
        let toastMessage: Driver<String>
    }
    
    // MARK: - Transform
    func transform(input: Input) -> Output {
        let cacheObservable = input.fetchDataSignal
            .asObservable()
            .flatMapLatest { [weak self] _ -> Observable<[User]> in
                guard let self = self else { return .empty() }
                return self.cacheService.load()
            }
            .share(replay: 1, scope: .whileConnected)
        
        cacheObservable
            .filter { !$0.isEmpty }
            .subscribe(onNext: { [weak self] cachedUsers in
                guard let self = self else { return }
                self.usersRelay.accept(cachedUsers)
                self.since = cachedUsers.last?.id ?? 0
                self.toastRelay.accept("List loaded from cache")
            })
            .disposed(by: disposeBag)
        
        cacheObservable
            .filter { $0.isEmpty }
            .subscribe(onNext: { [weak self] _ in
                self?.fetchUsers()
                self?.toastRelay.accept("List loaded from remote")
            })
            .disposed(by: disposeBag)
        
        input.loadMoreSignalAtIndex
            .filter { [weak self] visibleRow in
                guard let self = self else { return false }
                
                let total = self.usersRelay.value.count
                let threshold = 5
                
                // Only allow if not loading, still has more data, and visible row is near the end
                return self.hasMore &&
                !self.loadingRelay.value &&
                total - visibleRow <= threshold
            }
            .emit(onNext: { [weak self] _ in
                self?.fetchUsers()
            })
            .disposed(by: disposeBag)
        
        input.selectedUserSignal
            .compactMap { $0.id }
            .emit { [weak self] in
                self?.fetchUserDetail($0)
            }
            .disposed(by: disposeBag)
        
        input.clearCacheSignal
            .emit { [weak self] _ in
                self?.cacheService.clear()
                self?.toastRelay.accept("Deleted cache")
            }.disposed(by: disposeBag)
        
        input.reloadDataSignal
            .emit { [weak self] _ in
                self?.fetchUsers(fromStart: true)
            }.disposed(by: disposeBag)
        
        return Output(users: usersRelay.asDriver(),
                      isLoading: loadingRelay.asDriver(onErrorJustReturn: false),
                      errorMessage: errorRelay.asDriver(onErrorDriveWith: .empty()),
                      toastMessage: toastRelay.asDriver(onErrorDriveWith: .empty())
        )
    }
}
