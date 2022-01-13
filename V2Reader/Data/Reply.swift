//
//  Reply.swift
//  V2Reeder
//
//  Created by Jiachen Chen on 1/10/22.
//

import Foundation
import OrderedCollections

class Reply: ObservableObject {
    var id: Int
    var content: [String]
    var content_rendered: [AttributedString]
    var created: TimeInterval
    var member: Member
    var imageURL: [String]
    var num: Int
    
    init(id: Int, content: String, content_rendered: String, created: TimeInterval, member: Member, num: Int, repliers: [String: [Int]]) {
        self.id = id
        self.content = []
        self.content_rendered = []
        self.created = created
        self.member = member
        self.imageURL = []
        self.num = num
        
        var index = content.startIndex
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let matches = detector.matches(in: content, options: [], range: NSRange(location: 0, length: content.utf16.count))
        
        for match in matches {
            guard let range = Range(match.range, in: content) else { continue }
            let url = content[range]
            
            if url.contains("imgur.com") || url.contains("i.v2ex.co") {
                self.imageURL.append(String(url).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
                self.content.append(String(content[index..<range.lowerBound]))
            } else {
                self.content.append(String(content[index..<range.lowerBound]) + "[\(url)](\(url))")
            }
            index = range.upperBound
        }
        if index < content.endIndex {
            self.content.append(String(content[index..<content.endIndex]))
        }
        
        for text in self.content {
            let regex = try! NSRegularExpression(pattern: #"(?![a-zA-Z0-9])@[a-zA-Z0-9]+ (#[1-9]+[0-9]* )?"#)
            let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count))
            var newContent = ""
            var index = text.startIndex
            
            for match in matches {
                guard let range = Range(match.range, in: text) else { continue }
                newContent.append(String(text[index..<range.lowerBound]))
                index = range.upperBound
                let part = text[range]
                var name = String(part.split(separator: "#")[0])
                name.removeFirst()
                name.removeLast()
                if repliers.keys.contains(name) {
                    let replyNums = repliers[name]!
                    if part.contains("#") {
                        var replyTo = part.split(separator: "#")[1]
                        replyTo.removeLast()
                        let replyNum = Int(replyTo) ?? 0
                        if replyNums.contains(replyNum) {
                            newContent.append("@**\(name)** [#\(replyNum)](v2reader://reply/\(replyNum)/from/\(num)) ")
                        } else {
                            newContent.append("@**\(name)** [#\(replyNums.last!)](v2reader://reply/\(replyNums.last!)/from/\(num)) #\(part.split(separator: "#")[1])")
                        }
                    } else {
                        let replyNum = replyNums.last!
                        newContent.append("@**\(name)** [#\(replyNum)](v2reader://reply/\(replyNum)/from/\(num)) ")
                    }
                } else {
                    newContent.append(String(part))
                }
            }
            if index < text.endIndex {
                newContent.append(String(text[index..<text.endIndex]))
            }
            self.content_rendered.append(try! AttributedString(markdown: newContent, options: AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace)))
        }
    }
    
    func formattedDate() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: Date(timeIntervalSince1970: self.created), relativeTo: Date()).replacingOccurrences(of: ".", with: "").replacingOccurrences(of: "ago", with: "")
    }
}

struct ReplyResponse: Codable {
    struct Result: Codable {
        struct Member: Codable {
            var id: Int
            var username: String
            var url: String
            var website: String?
            var github: String?
            var bio: String?
            var avatar: String
            var created: TimeInterval
            
            static let defaultMember = Member(id: 0, username: "", url: "", website: "", github: "", bio: "", avatar: "", created: 0)
        }
        
        var id: Int
        var content: String
        var content_rendered: String
        var created: TimeInterval
        var member: Member
        
        static let defaultResult = Result(id: 0, content: "", content_rendered: "", created: 0, member: Member.defaultMember)
    }
    
    var success: Bool
    var message: String
    var result: [Result]
    
    static let defaultTopicReplies = ReplyResponse(success: false, message: "", result: [])
}

@MainActor
class ReplyResponseFetcher: ObservableObject {
    var replyCollectionData = ReplyResponse.defaultTopicReplies
    @Published var replyCollection: OrderedDictionary<Int, Reply> = [:]
    @Published var fetching = false
    @Published var currentPage = 1
    @Published var fullyFetched = false
    var replyNum = 0
    var repliers: [String: [Int]] = [:]
    
    enum FetchError: Error {
        case badRequest
        case badJSON
    }
    
    func fetchData(token: String, id: Int) async throws {
        print("topicreplies")
        fetching = true
        let url = URL(string:"https://www.v2ex.com/api/v2/topics/\(id)/replies?p=\(currentPage)")!
        var request = URLRequest(url: url)
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        let (data, response) = try await URLSession.shared.data(for: request)
        //        print(String(data: data, encoding: .utf8) ?? "Invalid JSON")
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw FetchError.badRequest }
        replyCollectionData = try JSONDecoder().decode(ReplyResponse.self, from: data)
        fullyFetched = true
        for replyData in replyCollectionData.result {
            if replyCollection[replyData.id] == nil {
                fullyFetched = false
                replyNum += 1
                replyCollection[replyData.id] = Reply(id: replyData.id, content: replyData.content, content_rendered: replyData.content_rendered, created: replyData.created, member: Member(id: replyData.member.id, username: replyData.member.username, url: replyData.member.url, website: replyData.member.website ?? "", github: replyData.member.github ?? "", bio: replyData.member.bio ?? "", avatar: replyData.member.avatar, created: replyData.member.created), num: replyNum, repliers: repliers)
                if repliers[replyData.member.username] == nil {
                    repliers[replyData.member.username] = [replyNum]
                } else {
                    repliers[replyData.member.username]!.append(replyNum)
                }
            }
        }
        fetching = false
    }
    
    func fetchMoreIfNeeded(token: String, id: Int, topicId: Int) async {
        if !fullyFetched {
            if id == replyCollection.keys.last && !fetching {
                currentPage += 1
                try? await fetchData(token: token, id: topicId)
            }
        }
    }
}
