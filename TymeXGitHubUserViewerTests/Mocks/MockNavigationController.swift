//
//  MockNavigationController.swift
//  TymeXGitHubUserViewer
//
//  Created by LONGPHAN on 3/6/25.
//

import UIKit

final class MockNavigationController: UINavigationController {
    var pushedViewController: UIViewController?

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        pushedViewController = viewController
        super.pushViewController(viewController, animated: animated)
    }
}
