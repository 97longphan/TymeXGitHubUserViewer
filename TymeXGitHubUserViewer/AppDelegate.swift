//
//  AppDelegate.swift
//  TymeXGitHubUserViewer
//
//  Created by LONGPHAN on 3/6/25.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        let navigationController = UINavigationController()
        let userListRouter = UserListRouter(navigationController: navigationController)
        let apiService = APIServices()
        let cacheService = UserListCacheService()
        let userListViewModel = UserListViewModel(router: userListRouter,
                                                  apiService: apiService,
                                                  cacheService: cacheService)
        let userListViewController = UserListViewController(viewModel: userListViewModel)
        navigationController.viewControllers = [userListViewController]
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        return true
    }
}

