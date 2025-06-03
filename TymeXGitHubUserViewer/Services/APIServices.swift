//
//  APIServices.swift
//  TymeXGitHubUserViewer
//
//  Created by LONGPHAN on 3/6/25.
//

import Foundation
import RxSwift

/// Protocol defining methods for interacting with GitHub API.
protocol APIServicesProtocol {
    func fetchUsers(since: Int, perPage: Int) -> Single<[User]>
    func fetchUserDetail(id: Int) -> Single<UserDetail>
}

/// Enum representing API-level errors.
enum APIError: Error {
    case invalidURL         /// URL is invalid or malformed.
    case decodingFailed     /// Failed to decode the response data.
    case unknown            /// An unknown error occurred.
}

/// Implementation of `APIServicesProtocol` using `URLSession` and RxSwift.
final class APIServices: APIServicesProtocol {
    /// URLSession instance used to perform network requests.
    private let session: URLSession

    /// Initializes the API service.
    /// - Parameter session: A custom or shared URLSession instance. Defaults to `.shared`.
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    /// Fetches a list of GitHub users using pagination.
    /// - Parameters:
    ///   - since: The user ID to start fetching from.
    ///   - perPage: Number of users per page.
    /// - Returns: A `Single` emitting a list of `User` or an error.
    func fetchUsers(since: Int, perPage: Int) -> Single<[User]> {
        guard let url = URL(string: "https://api.github.com/users?since=\(since)&per_page=\(perPage)") else {
            return .error(APIError.invalidURL)
        }

        let request = URLRequest(url: url)
        
        return Single.create { single in
            let task = self.session.dataTask(with: request) { data, _, error in
                if let error = error {
                    single(.failure(error))
                } else if let data = data {
                    do {
                        let decoded = try JSONDecoder().decode([User].self, from: data)
                        single(.success(decoded))
                    } catch {
                        single(.failure(APIError.decodingFailed))
                    }
                } else {
                    single(.failure(APIError.unknown))
                }
            }
            task.resume()
            return Disposables.create { task.cancel() }
        }
    }

    /// Fetches detailed information about a specific user from GitHub.
    /// - Parameter id: The user's unique identifier.
    /// - Returns: A `Single` emitting a `UserDetail` or an error.
    func fetchUserDetail(id: Int) -> Single<UserDetail> {
        guard let url = URL(string: "https://api.github.com/user/\(id)") else {
            return .error(APIError.invalidURL)
        }

        let request = URLRequest(url: url)

        return Single.create { single in
            let task = self.session.dataTask(with: request) { data, _, error in
                if let error = error {
                    single(.failure(error))
                } else if let data = data {
                    do {
                        let decoded = try JSONDecoder().decode(UserDetail.self, from: data)
                        single(.success(decoded))
                    } catch {
                        single(.failure(APIError.decodingFailed))
                    }
                } else {
                    single(.failure(APIError.unknown))
                }
            }
            task.resume()
            return Disposables.create { task.cancel() }
        }
    }
}
