//
//  UserListRouter.swift
//  TymeXGitHubUserViewer
//
//  Created by LONGPHAN on 3/6/25.
//

import UIKit

protocol UserListRouterProtocol {
    func showUserDetail(user: UserDetail)
}

final class UserListRouter: UserListRouterProtocol {
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func showUserDetail(user: UserDetail)  {
        let userDetailViewModel = UserDetailViewModel(userDetail: user)
        let userDetailViewController = UserDetailViewController(viewModel: userDetailViewModel)
        navigationController.pushViewController(userDetailViewController, animated: true)
    }
}
