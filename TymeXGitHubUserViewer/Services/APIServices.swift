//
//  APIServices.swift
//  TymeXGitHubUserViewer
//
//  Created by LONGPHAN on 3/6/25.
//

import Foundation
import RxSwift

protocol APIServicesProtocol {
    func fetchUsers(since: Int, perPage: Int) -> Single<[User]>
    func fetchUserDetail(id: Int) -> Single<UserDetail>
}

enum APIError: Error {
    case invalidURL
    case decodingFailed
    case unknown
}

final class APIServices: APIServicesProtocol {
    
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    
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
                        single(.failure(error))
                    }
                }
            }
            task.resume()
            return Disposables.create { task.cancel() }
        }
    }
    
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
                        single(.failure(error))
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
