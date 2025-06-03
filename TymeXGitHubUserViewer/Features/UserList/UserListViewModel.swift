//
//  UserListViewModel.swift
//  TymeXGitHubUserViewer
//
//  Created by LONGPHAN on 3/6/25.
//

import Foundation
import RxSwift
import RxCocoa

/// ViewModel responsible for managing the GitHub user list.
/// Handles fetching users from a remote API, caching them locally,
/// and navigating to user detail screens.
final class UserListViewModel: ViewModelType {
    // MARK: - Services
    
    /// API service for fetching user data.
    private let apiService: APIServicesProtocol
    
    /// Local cache service for storing and retrieving user data.
    private let cacheService: UserListCacheServiceProtocol
    
    // MARK: - Router
    
    /// Router to handle navigation to detail views.
    private let router: UserListRouterProtocol
    
    // MARK: - State Relays
    
    /// Holds the current list of users.
    private let usersRelay = BehaviorRelay<[User]>(value: [])
    
    /// Emits error messages for the view.
    private let errorRelay = PublishRelay<String>()
    
    /// Indicates whether a loading operation is in progress.
    private let loadingRelay = BehaviorRelay<Bool>(value: false)
    
    /// Emits toast messages for user feedback.
    private let toastRelay = PublishRelay<String>()
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Pagination
    
    /// Pagination cursor: ID of the last loaded user.
    private var since = 0
    
    /// Number of users to load per page.
    private let perPage = 20
    
    /// Indicates whether more data is available to fetch.
    private var hasMore = true
    
    // MARK: - Initialization
    
    /// Initializes the ViewModel with required dependencies.
    /// - Parameters:
    ///   - router: Router for handling navigation.
    ///   - apiService: Service for fetching user data.
    ///   - cacheService: Service for managing local cache.
    init(router: UserListRouterProtocol,
         apiService: APIServicesProtocol,
         cacheService: UserListCacheServiceProtocol) {
        self.router = router
        self.apiService = apiService
        self.cacheService = cacheService
    }
    
    /// Fetches a list of users from the API.
    /// - Parameter fromStart: If `true`, clears current data and fetches from the beginning.
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
                    
                    self.cacheService.save(current)
                    
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
    
    /// Fetches detail information of a user and navigates to the detail screen.
    /// - Parameter id: The user ID to fetch detail for.
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

// MARK: - Reactive Input/Output Mapping
extension UserListViewModel {
    
    /// Represents input signals from the view.
    struct Input {
        /// Trigger to load data from cache or remote.
        let fetchDataSignal: Signal<Void>
        
        /// Triggered when the view is about to reach the end of the list (for pagination).
        let loadMoreSignalAtIndex: Signal<Int>
        
        /// Emits the selected user to show details.
        let selectedUserSignal: Signal<User>
        
        /// Trigger to reload the entire user list.
        let reloadDataSignal: Signal<Void>
        
        /// Trigger to clear cached data.
        let clearCacheSignal: Signal<Void>
    }
    
    /// Represents output drivers to bind to the view.
    struct Output {
        /// Emits the current list of users.
        let users: Driver<[User]>
        
        /// Emits loading state.
        let isLoading: Driver<Bool>
        
        /// Emits error messages.
        let errorMessage: Driver<String>
        
        /// Emits toast messages.
        let toastMessage: Driver<String>
    }
    
    /// Transforms input signals into output drivers, binding UI logic to state and side effects.
    /// - Parameter input: Input signals from the view.
    /// - Returns: Output drivers for UI bindings.
    func transform(input: Input) -> Output {
        let cacheObservable = input.fetchDataSignal
            .asObservable()
            .flatMapLatest { [weak self] _ -> Observable<[User]> in
                guard let self = self else { return .empty() }
                return self.cacheService.load()
            }
            .share(replay: 1, scope: .whileConnected)
        
        // If cache is available, load it
        cacheObservable
            .filter { !$0.isEmpty }
            .subscribe(onNext: { [weak self] cachedUsers in
                guard let self = self else { return }
                self.usersRelay.accept(cachedUsers)
                self.since = cachedUsers.last?.id ?? 0
                self.toastRelay.accept("List loaded from cache")
            })
            .disposed(by: disposeBag)
        
        // If cache is empty, fetch from remote
        cacheObservable
            .filter { $0.isEmpty }
            .subscribe(onNext: { [weak self] _ in
                self?.fetchUsers()
                self?.toastRelay.accept("List loaded from remote")
            })
            .disposed(by: disposeBag)
        
        // Handle pagination
        input.loadMoreSignalAtIndex
            .filter { [weak self] visibleRow in
                guard let self = self else { return false }
                let total = self.usersRelay.value.count
                let threshold = 5
                return self.hasMore && !self.loadingRelay.value && total - visibleRow <= threshold
            }
            .emit(onNext: { [weak self] _ in
                self?.fetchUsers()
            })
            .disposed(by: disposeBag)
        
        // Handle user selection
        input.selectedUserSignal
            .compactMap { $0.id }
            .emit { [weak self] id in
                self?.fetchUserDetail(id)
            }
            .disposed(by: disposeBag)
        
        // Handle clearing cache
        input.clearCacheSignal
            .emit { [weak self] _ in
                self?.cacheService.clear()
                self?.toastRelay.accept("Deleted cache")
            }
            .disposed(by: disposeBag)
        
        // Handle manual reload
        input.reloadDataSignal
            .emit { [weak self] _ in
                self?.fetchUsers(fromStart: true)
            }
            .disposed(by: disposeBag)
        
        return Output(
            users: usersRelay.asDriver(),
            isLoading: loadingRelay.asDriver(onErrorJustReturn: false),
            errorMessage: errorRelay.asDriver(onErrorDriveWith: .empty()),
            toastMessage: toastRelay.asDriver(onErrorDriveWith: .empty())
        )
    }
}
