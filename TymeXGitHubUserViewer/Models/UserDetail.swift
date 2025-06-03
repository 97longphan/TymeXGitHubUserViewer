//
//  UserDetail.swift
//  TymeXGitHubUserViewer
//
//  Created by LONGPHAN on 3/6/25.
//

import Foundation

struct UserDetail: Codable {
    let login: String?
    let name: String?
    let company: String?
    let location: String?
    let followers: Int?
    let following: Int?
    let avatar_url: String?
    let html_url: String?

    init(
        login: String? = nil,
        name: String? = nil,
        company: String? = nil,
        location: String? = nil,
        followers: Int? = nil,
        following: Int? = nil,
        avatar_url: String? = nil,
        html_url: String? = nil
    ) {
        self.login = login
        self.name = name
        self.company = company
        self.location = location
        self.followers = followers
        self.following = following
        self.avatar_url = avatar_url
        self.html_url = html_url
    }
}
