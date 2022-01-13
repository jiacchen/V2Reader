//
//  Token.swift
//  V2Reader
//
//  Created by Jiachen Chen on 1/12/22.
//

import Foundation

struct TokenResponse: Codable {
    struct Result: Codable {
        var token: String
        var scope: String
        var expiration: TimeInterval
        var good_for_days: Int
        var total_used: Int
        var last_used: TimeInterval
        var created: TimeInterval
        
        static let defaultResult = Result(token: "", scope: "", expiration: 0, good_for_days: 0, total_used: 0, last_used: 0, created: 0)
    }
    
    var success: Bool
    var message: String
    var result: Result?
    
    static let defaultTokenResponse = TokenResponse(success: false, message: "", result: Result.defaultResult)
}

@MainActor
class TokenFetcher: ObservableObject {
    @Published var tokenInvalid = false
    @Published var completed = false
    
    enum FetchError: Error {
        case badRequest
        case badJSON
    }
    
    func fetchData(token: String) async throws {
        let url = URL(string:"https://www.v2ex.com/api/v2/token")!
        var request = URLRequest(url: url)
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        let (_, response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            completed = true
            tokenInvalid = true
            return
        }
        tokenInvalid = false
        completed = true
    }
}
