//
//  UserListViewController.swift
//  TymeXGitHubUserViewer
//
//  Created by LONGPHAN on 3/6/25.
//

import UIKit
import RxCocoa
import RxSwift

class UserListViewController: UIViewController {
    // MARK: - @IBOutlet
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Variables
    private let viewModel: UserListViewModel
    private let disposeBag = DisposeBag()
    private let cellIdentifier = "UserListTableViewCell"
    
    private let loadMoreRelay = PublishRelay<Int>()
    private let fetchDataRelay = PublishRelay<Void>()
    private let selectedUserRelay = PublishRelay<User>()
    private let reloadDataRelay = PublishRelay<Void>()
    private let clearCacheRelay = PublishRelay<Void>()
    
    // MARK: - Init
    init(viewModel: UserListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: UserListViewController.self), bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        bindData()
        fetchDataRelay.accept(())
    }
    
    // MARK: - Function
    private func bindData() {
        let input = UserListViewModel.Input(fetchDataSignal: fetchDataRelay.asSignal(),
                                            loadMoreSignalAtIndex: loadMoreRelay.asSignal(),
                                            selectedUserSignal: selectedUserRelay.asSignal(),
                                            reloadDataSignal: reloadDataRelay.asSignal(),
                                            clearCacheSignal: clearCacheRelay.asSignal())
        let output = viewModel.transform(input: input)
        
        output
            .users
            .drive(tableView.rx.items(
                cellIdentifier: cellIdentifier,
                cellType: UserListTableViewCell.self
            )) { _, user, cell in
                cell.configure(with: user)
            }
            .disposed(by: disposeBag)
        
        output
            .isLoading
            .drive(activityIndicator.rx.isAnimating)
            .disposed(by: disposeBag)
        
        output
            .errorMessage
            .drive { [weak self] in
                self?.showErrorAlert($0)
            }.disposed(by: disposeBag)
        
        output
            .toastMessage
            .drive { [weak self] in
                self?.showToast(message: $0)
            }.disposed(by: disposeBag)
    }
    
    private func configureViews() {
        configureTableView()
        title = "Github Users"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        activityIndicator.style = .large
        activityIndicator.hidesWhenStopped = true
        
        let clearButton = UIBarButtonItem(title: "Clear cache", style: .plain, target: self, action: #selector(didTapClear))
        let reloadButton = UIBarButtonItem(title: "Reload data", style: .plain, target: self, action: #selector(didTapReload))
        
        navigationItem.rightBarButtonItems = [reloadButton]
        navigationItem.leftBarButtonItem = clearButton
    }
    
    @objc private func didTapClear() {
        clearCacheRelay.accept(())
    }

    @objc private func didTapReload() {
        reloadDataRelay.accept(())
    }
    
    private func configureTableView() {
        tableView.separatorStyle = .none
        
        tableView.register(
            UINib(nibName: cellIdentifier, bundle: nil),
            forCellReuseIdentifier: cellIdentifier
        )
        
        tableView.rx.modelSelected(User.self)
            .asSignal(onErrorSignalWith: .empty())
            .emit(to: selectedUserRelay)
            .disposed(by: disposeBag)
        
        tableView.rx.willDisplayCell
            .map { $0.indexPath.row }
            .bind(to: loadMoreRelay)
            .disposed(by: disposeBag)
    }
}

