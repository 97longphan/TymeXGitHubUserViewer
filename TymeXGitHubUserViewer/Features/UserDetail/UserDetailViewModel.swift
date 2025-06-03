//
//  UserDetailViewModel.swift
//  TymeXGitHubUserViewer
//
//  Created by LONGPHAN on 3/6/25.
//

import Foundation

final class UserDetailViewModel: ViewModelType {
    // MARK: - Variables
    private let userDetail: UserDetail
    
    init(userDetail: UserDetail) {
        self.userDetail = userDetail
    }
}

extension UserDetailViewModel {
    // MARK: - Input / Output
    struct Input {}
    
    struct Output {
        let userDetail: UserDetail
    }
    
    // MARK: - Transform
    func transform(input: Input) -> Output {
        Output(userDetail: userDetail)
    }
}
