//
//  UserDetailViewModel.swift
//  TymeXGitHubUserViewer
//
//  Created by LONGPHAN on 3/6/25.
//

import Foundation

/// ViewModel responsible for providing user detail data to the view.
final class UserDetailViewModel: ViewModelType {
    
    // MARK: - Variables

    /// The detailed information of a selected user.
    private let userDetail: UserDetail

    /// Initializes the ViewModel with user detail.
    /// - Parameter userDetail: The detailed user object to present.
    init(userDetail: UserDetail) {
        self.userDetail = userDetail
    }
}

extension UserDetailViewModel {
    
    // MARK: - Input / Output

    /// Represents input signals from the view (currently unused).
    struct Input {}

    /// Represents output data delivered to the view.
    struct Output {
        /// The detailed user information to display.
        let userDetail: UserDetail
    }

    // MARK: - Transform

    /// Transforms the input into output to expose data to the view.
    /// - Parameter input: The input provided by the view.
    /// - Returns: An output structure containing user detail.
    func transform(input: Input) -> Output {
        Output(userDetail: userDetail)
    }
}
