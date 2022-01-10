//
//  Member.swift
//  V2EX
//
//  Created by Jiachen Chen on 1/5/22.
//

import Foundation

class Member: ObservableObject {
    var id: Int
    var username: String
    var url: String
    var website: String?
    var github: String?
    var bio: String?
    var avatar: String
    var created: String
    
    init(id: Int, username: String, url: String, website: String?, github: String?, bio: String?, avatar: String, created: TimeInterval) {
        self.id = id
        self.username = username
        self.url = url
        self.website = website == "" ? nil : website
        self.github = github == "" ? nil : github
        self.bio = bio == "" ? nil : bio
        self.avatar = avatar
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        self.created = dateFormatter.string(from: Date(timeIntervalSince1970: created))
    }
    
    func loadData(id: Int, username: String, url: String, website: String?, github: String?, bio: String?, avatar: String, created: TimeInterval) {
        self.id = id
        self.username = username
        self.url = url
        self.website = website == "" ? nil : website
        self.github = github == "" ? nil : github
        self.bio = bio == "" ? nil : bio
        self.avatar = avatar
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        self.created = dateFormatter.string(from: Date(timeIntervalSince1970: created))
    }
}

struct MemberResponse: Codable {
    struct Result: Codable {
        var id: Int
        var username: String
        var url: String
        var website: String
        var twitter: String
        var psn: String
        var github: String
        var btc: String
        var location: String
        var tagline: String
        var bio: String
        var avatar_mini: String
        var avatar_normal: String
        var avatar_large: String
        var avatar_xlarge: String?
        var avatar_xxlarge: String?
        var avatar_xxxlarge: String?
        var created: TimeInterval
        var last_modified: TimeInterval
        
        static let defaultResult = Result(id: 0, username: "", url: "", website: "", twitter: "", psn: "", github: "", btc: "", location: "", tagline: "", bio: "", avatar_mini: "", avatar_normal: "", avatar_large: "", created: 0, last_modified: 0)
    }
    
    var success: Bool
    var result: Result
    
    static let defaultMember = MemberResponse(success: false, result: Result.defaultResult)
}

@MainActor
class MemberResponseFetcher: ObservableObject {
    @Published var memberData = MemberResponse.defaultMember
    
    enum FetchError: Error {
        case badRequest
        case badJSON
    }
    
    func fetchData() async throws {
        print("myself")
        let url = URL(string:"https://www.v2ex.com/api/v2/member")!
        let token = "ec8a1394-93a0-4a7e-b513-f5c129226796"
        var request = URLRequest(url: url)
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        let (data, response) = try await URLSession.shared.data(for: request)
//        print(String(data: data, encoding: .utf8) ?? "Invalid JSON")
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw FetchError.badRequest }
        memberData = try JSONDecoder().decode(MemberResponse.self, from: data)
    }
}
