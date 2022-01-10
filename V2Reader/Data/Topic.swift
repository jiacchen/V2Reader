//
//  Topic.swift
//  V2EX
//
//  Created by Jiachen Chen on 1/5/22.
//

import Foundation
import OrderedCollections

class Topic: ObservableObject {
    var id: Int
    var title: String
    var content: [String]
    var content_rendered: [AttributedString]
    var syntax: Int
    var url: String
    var replies: Int
    var last_reply_by: String
    var created: TimeInterval
    var last_modified: TimeInterval
    var last_touched: TimeInterval
    var member: Member?
    var node: Node?
    var imageURL: [String]
    var supplements: [Supplement]
    var detailsAdded = false
    
    init(id: Int, title: String, content: String, content_rendered: String, syntax: Int, url: String, replies: Int, last_reply_by: String, created: TimeInterval, last_modified: TimeInterval, last_touched: TimeInterval) {
        self.id = id
        self.title = title
        self.content = []
        self.content_rendered = []
        self.syntax = syntax
        self.url = url
        self.replies = replies
        self.last_reply_by = last_reply_by
        self.created = created
        self.last_modified = last_modified
        self.last_touched = last_touched
        self.imageURL = []
        self.supplements = []
        
        var index = content.startIndex
        if syntax == 0 {
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
        } else {
            let regex = try! NSRegularExpression(pattern: #"!\[(.*)\]\((.+)\)"#)
            let matches = regex.matches(in: content, options: [], range: NSRange(location: 0, length: content.utf16.count))
            
            for match in matches {
                guard let range = Range(match.range, in: content) else { continue }
                let markdown = content[range]
                var text = String(content[index..<range.lowerBound])
                if text.last == "[" {
                    text.removeLast()
                }
                self.content.append(text)
                index = range.upperBound
                let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
                let urlMatches = detector.matches(in: String(markdown), options: [], range: NSRange(location: 0, length: markdown.utf16.count))
                for urlMatch in urlMatches {
                    guard let urlRange = Range(urlMatch.range, in: markdown) else { continue }
                    let url = markdown[urlRange]
                    self.imageURL.append(String(url).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
                }
            }
        }
        if index < content.endIndex {
            self.content.append(String(content[index..<content.endIndex]))
        }
        for text in self.content {
            self.content_rendered.append(try! AttributedString(markdown: text, options: AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace)))
        }
    }
    
    func addDetails(member: Member, node: Node, supplements: [Supplement]) {
        self.member = member
        self.node = node
        self.supplements = supplements
//        for imageUrl in imageURL {
//            let data = try? Data(contentsOf: URL(string: imageUrl)!)
//            if data != nil {
//                let image = UIImage(data: data!)
//                if image != nil {
//                    self.image.append(image!)
//                }
//            }
//        }
        detailsAdded = true
    }
    
    func formattedCreatedDate() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: Date(timeIntervalSince1970: self.created), relativeTo: Date()).replacingOccurrences(of: ".", with: "").replacingOccurrences(of: "ago", with: "")
    }
    
    func formattedDate() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: Date(timeIntervalSince1970: self.last_touched), relativeTo: Date()).replacingOccurrences(of: ".", with: "").replacingOccurrences(of: "ago", with: "")
    }
}

class Supplement: ObservableObject {
    var id: Int
    var content: [String]
    var content_rendered: [AttributedString]
    var syntax: Int
    var created: TimeInterval
    var imageURL: [String]
    
    init(id: Int, content: String, content_rendered: String, syntax: Int, created: TimeInterval) {
        self.id = id
        self.content = []
        self.content_rendered = []
        self.syntax = syntax
        self.created = created
        self.imageURL = []
        
        var index = content.startIndex
        if syntax == 0 {
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
        } else {
            let regex = try! NSRegularExpression(pattern: #"!\[(.*)\]\((.+)\)"#)
            let matches = regex.matches(in: content, options: [], range: NSRange(location: 0, length: content.utf16.count))
            
            for match in matches {
                guard let range = Range(match.range, in: content) else { continue }
                let markdown = content[range]
                var text = String(content[index..<range.lowerBound])
                if text.last == "[" {
                    text.removeLast()
                }
                self.content.append(text)
                index = range.upperBound
                let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
                let urlMatches = detector.matches(in: String(markdown), options: [], range: NSRange(location: 0, length: markdown.utf16.count))
                for urlMatch in urlMatches {
                    guard let urlRange = Range(urlMatch.range, in: markdown) else { continue }
                    let url = markdown[urlRange]
                    self.imageURL.append(String(url).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
                }
            }
        }
        if index < content.endIndex {
            self.content.append(String(content[index..<content.endIndex]))
        }
        for text in self.content {
            self.content_rendered.append(try! AttributedString(markdown: text, options: AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace)))
        }
    }
    
    func formattedDate() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: Date(timeIntervalSince1970: self.created), relativeTo: Date()).replacingOccurrences(of: ".", with: "").replacingOccurrences(of: "ago", with: "")
    }
}

struct TopicCollectionResponse: Codable {
    struct Result: Codable {
        var id: Int
        var title: String
        var content: String
        var content_rendered: String
        var syntax: Int
        var url: String
        var replies: Int
        var last_reply_by: String
        var created: TimeInterval
        var last_modified: TimeInterval
        var last_touched: TimeInterval
        
        static let defaultResult = Result(id: 0, title: "", content: "", content_rendered: "", syntax: 0, url: "", replies: 0, last_reply_by: "", created: 0, last_modified: 0, last_touched: 0)
    }
    
    var success: Bool
    var message: String
    var result: [Result]
    
    static let defaultTopicResponse = TopicCollectionResponse(success: false, message: "", result: [])
}

@MainActor
class TopicCollectionResponseFetcher: ObservableObject {
    var topicCollectionData = TopicCollectionResponse.defaultTopicResponse
    @Published var topicCollection: OrderedDictionary<Int, Topic> = [:]
    @Published var fetching = false
    @Published var currentPage = 1
    @Published var fullyFetched = false
    
    enum FetchError: Error {
        case badRequest
        case badJSON
    }
    
    func fetchData(name: String) async throws {
        if name == "home" {
            fullyFetched = true
        } else {
            print("nodetopic")
            fetching = true
            let url = URL(string:"https://www.v2ex.com/api/v2/nodes/\(name)/topics?p=\(currentPage)")!
            let token = "ec8a1394-93a0-4a7e-b513-f5c129226796"
            var request = URLRequest(url: url)
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.httpMethod = "GET"
            let (data, response) = try await URLSession.shared.data(for: request)
            guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw FetchError.badRequest }
            topicCollectionData = try JSONDecoder().decode(TopicCollectionResponse.self, from: data)
            fullyFetched = true
            for topicData in topicCollectionData.result {
                if topicCollection[topicData.id] == nil {
                    fullyFetched = false
                    topicCollection[topicData.id] = Topic(id: topicData.id, title: topicData.title, content: topicData.content, content_rendered: topicData.content_rendered, syntax: topicData.syntax, url: topicData.url, replies: topicData.replies, last_reply_by: topicData.last_reply_by, created: topicData.created, last_modified: topicData.last_modified, last_touched: topicData.last_touched)
                }
            }
            fetching = false
        }
    }
    
    func fetchMoreIfNeeded(id: Int, nodeName: String) async {
        if !fullyFetched {
            if id == topicCollection.keys.last && !fetching {
                currentPage += 1
                try? await fetchData(name: nodeName)
            }
        }
    }
}

struct TopicResponse: Codable {
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
        
        struct Node: Codable {
            var id: Int
            var url: String
            var name: String
            var title: String
            var header: String
            var footer: String
            var avatar: String
            var topics: Int
            var created: TimeInterval
            var last_modified: TimeInterval
            
            static let defaultNode = Node(id: 0, url: "", name: "", title: "", header: "", footer: "", avatar: "", topics: 0, created: 0, last_modified: 0)
        }
        
        struct Supplement: Codable {
            var id: Int
            var content: String
            var content_rendered: String
            var syntax: Int
            var created: TimeInterval
            
            static let defaultSupplement = Supplement(id: 0, content: "", content_rendered: "", syntax: 0, created: 0)
        }
        
        var id: Int
        var title: String
        var content: String
        var content_rendered: String
        var syntax: Int
        var url: String
        var replies: Int
        var last_reply_by: String
        var created: TimeInterval
        var last_modified: TimeInterval
        var last_touched: TimeInterval
        var member: Member
        var node: Node
        var supplements: [Supplement]
        
        static let defaultResult = Result(id: 0, title: "", content: "", content_rendered: "", syntax: 0, url: "", replies: 0, last_reply_by: "", created: 0, last_modified: 0, last_touched: 0, member: Member.defaultMember, node: Node.defaultNode, supplements: [Supplement.defaultSupplement])
    }
    
    var success: Bool
    var message: String
    var result: Result
    
    static let defaultTopicDetail = TopicResponse(success: false, message: "", result: Result.defaultResult)
}

@MainActor
class TopicResponseFetcher: ObservableObject {
    @Published var topicData = TopicResponse.defaultTopicDetail
    @Published var fetching = false
    
    enum FetchError: Error {
        case badRequest
        case badJSON
    }
    
    func fetchData(id: Int) async throws {
        print("topicdetail")
        fetching = true
        let url = URL(string:"https://www.v2ex.com/api/v2/topics/\(id)")!
        let token = "ec8a1394-93a0-4a7e-b513-f5c129226796"
        var request = URLRequest(url: url)
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        let (data, response) = try await URLSession.shared.data(for: request)
        //        print(String(data: data, encoding: .utf8) ?? "Invalid JSON")
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw FetchError.badRequest }
        topicData = try JSONDecoder().decode(TopicResponse.self, from: data)
        fetching = false
    }
}
