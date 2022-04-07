//
//  Topic.swift
//  V2Reeder
//
//  Created by Jiachen Chen on 1/10/22.
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
            var prevTexts: [String] = []
            
            for match in matches {
                guard let range = Range(match.range, in: content) else { continue }
                let url = content[range]
                
                if url.contains("i.v2ex.co") || url[url.index(url.startIndex, offsetBy: url.count - 4)..<url.endIndex] == ".jpg" || url[url.index(url.startIndex, offsetBy: url.count - 4)..<url.endIndex] == ".png" || url[url.index(url.startIndex, offsetBy: url.count - 5)..<url.endIndex] == ".jpeg" {
                    var tempText = ""
                    for prevText in prevTexts {
                        tempText.append(prevText)
                    }
                    prevTexts.removeAll()
                    self.imageURL.append(String(url).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
                    self.content.append(tempText + String(content[index..<range.lowerBound]))
                } else {
                    prevTexts.append(String(content[index..<range.lowerBound]) + "[\(url)](\(url))")
                }
                index = range.upperBound
            }
            var tempText = ""
            for prevText in prevTexts {
                tempText.append(prevText)
            }
            prevTexts.removeAll()
            self.content.append(tempText + String(content[index..<content.endIndex]))
            
        } else {
            let regex = try! NSRegularExpression(pattern: #"!\[(.*)\]\((.+)\)"#)
            let matches = regex.matches(in: content, options: [], range: NSRange(location: 0, length: content.utf16.count))
            var prevTexts: [String] = []
            for match in matches {
                guard let range = Range(match.range, in: content) else { continue }
                let markdown = content[range]
                var text = String(content[index..<range.lowerBound])
                if text.last == "[" {
                    text.removeLast()
                }
                index = range.upperBound
                let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
                let urlMatches = detector.matches(in: String(markdown), options: [], range: NSRange(location: 0, length: markdown.utf16.count))
                for urlMatch in urlMatches {
                    guard let urlRange = Range(urlMatch.range, in: markdown) else { continue }
                    let url = String(markdown[urlRange])
                    if url[url.startIndex..<url.index(url.startIndex, offsetBy: 5)] == "http:" {
                        var httpImage = String(markdown)
                        httpImage.removeFirst()
                        prevTexts.append(text + httpImage)
                    } else {
                        var tempText = ""
                        for prevText in prevTexts {
                            tempText.append(prevText)
                        }
                        prevTexts.removeAll()
                        self.content.append(tempText + text)
                        self.imageURL.append(url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
                    }
                }
            }
            var tempText = ""
            for prevText in prevTexts {
                tempText.append(prevText)
            }
            prevTexts.removeAll()
            self.content.append(tempText + String(content[index..<content.endIndex]))
            self.content.append(content)
        }
        for text in self.content {
            self.content_rendered.append(try! AttributedString(markdown: text, options: AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace)))
        }
    }
    
    func addDetails(member: Member, node: Node, supplements: [Supplement]) {
        self.member = member
        self.node = node
        self.supplements = supplements
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
            var prevTexts: [String] = []
            
            for match in matches {
                guard let range = Range(match.range, in: content) else { continue }
                let url = content[range]
                
                if url.contains("i.v2ex.co") || url[url.index(url.startIndex, offsetBy: url.count - 4)..<url.endIndex] == ".jpg" || url[url.index(url.startIndex, offsetBy: url.count - 4)..<url.endIndex] == ".png" || url[url.index(url.startIndex, offsetBy: url.count - 5)..<url.endIndex] == ".jpeg" {
                    var tempText = ""
                    for prevText in prevTexts {
                        tempText.append(prevText)
                    }
                    prevTexts.removeAll()
                    self.imageURL.append(String(url).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
                    self.content.append(tempText + String(content[index..<range.lowerBound]))
                } else {
                    prevTexts.append(String(content[index..<range.lowerBound]) + "[\(url)](\(url))")
                }
                index = range.upperBound
            }
            var tempText = ""
            for prevText in prevTexts {
                tempText.append(prevText)
            }
            prevTexts.removeAll()
            self.content.append(tempText + String(content[index..<content.endIndex]))
            
        } else {
            let regex = try! NSRegularExpression(pattern: #"!\[(.*)\]\((.+)\)"#)
            let matches = regex.matches(in: content, options: [], range: NSRange(location: 0, length: content.utf16.count))
            var prevTexts: [String] = []
            
            for match in matches {
                guard let range = Range(match.range, in: content) else { continue }
                let markdown = content[range]
                var text = String(content[index..<range.lowerBound])
                if text.last == "[" {
                    text.removeLast()
                }
                index = range.upperBound
                let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
                let urlMatches = detector.matches(in: String(markdown), options: [], range: NSRange(location: 0, length: markdown.utf16.count))
                for urlMatch in urlMatches {
                    guard let urlRange = Range(urlMatch.range, in: markdown) else { continue }
                    let url = String(markdown[urlRange])
                    if url[url.startIndex..<url.index(url.startIndex, offsetBy: 5)] == "http:" {
                        var httpImage = String(markdown)
                        httpImage.removeFirst()
                        prevTexts.append(text + httpImage)
                    } else {
                        var tempText = ""
                        for prevText in prevTexts {
                            tempText.append(prevText)
                        }
                        prevTexts.removeAll()
                        self.content.append(tempText + text)
                        self.imageURL.append(url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
                    }
                }
            }
            var tempText = ""
            for prevText in prevTexts {
                tempText.append(prevText)
            }
            prevTexts.removeAll()
            self.content.append(tempText + String(content[index..<content.endIndex]))
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

class TopicCollectionResponseFetcher: ObservableObject {
    @MainActor var topicCollectionData = TopicCollectionResponse.defaultTopicResponse
    @Published var topicCollection: OrderedDictionary<Int, Topic> = [:]
    @Published var fetching = false
    @Published var currentPage = 1
    @Published var fullyFetched = false
    
    enum FetchError: Error {
        case badRequest
        case badJSON
    }
    
    @MainActor func fetchData(token: String, name: String, home: [String]) async throws {
        fetching = true
        if name == "home" {
            var tempTopicCollection: OrderedDictionary<Int, Topic> = [:]
            for homeNode in home {
                print("nodetopic")
                let url = URL(string:"https://www.v2ex.com/api/v2/nodes/\(homeNode)/topics?p=\(currentPage)")!
                var request = URLRequest(url: url)
                request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                request.httpMethod = "GET"
                let (data, response) = try await URLSession.shared.data(for: request)
                guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw FetchError.badRequest }
                topicCollectionData = try JSONDecoder().decode(TopicCollectionResponse.self, from: data)
                for topicData in topicCollectionData.result {
                    tempTopicCollection[topicData.id] = Topic(id: topicData.id, title: topicData.title, content: topicData.content, content_rendered: topicData.content_rendered, syntax: topicData.syntax, url: topicData.url, replies: topicData.replies, last_reply_by: topicData.last_reply_by, created: topicData.created, last_modified: topicData.last_modified, last_touched: topicData.last_touched)
                }
            }
            tempTopicCollection.sort { elem1, elem2 in
                return elem1.value.last_touched > elem2.value.last_touched
            }
            topicCollection = tempTopicCollection
            fullyFetched = true
        } else {
            print("nodetopic")
            let url = URL(string:"https://www.v2ex.com/api/v2/nodes/\(name)/topics?p=\(currentPage)")!
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
            currentPage += 1
        }
        fetching = false
    }
    
    func fetchMoreIfNeeded(token: String, id: Int, nodeName: String, homeNodes: [String]) async {
        if !fullyFetched {
            if id == topicCollection.keys.last {
                try? await fetchData(token: token, name: nodeName, home: homeNodes)
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
        
        static let defaultResult = Result(id: 0, title: "", content: "", content_rendered: "", syntax: 0, url: "", replies: 0, last_reply_by: "", created: 0, last_modified: 0, last_touched: 0, member: Member.defaultMember, node: Node.defaultNode, supplements: [])
    }
    
    var success: Bool
    var message: String
    var result: Result
    
    static let defaultTopicDetail = TopicResponse(success: false, message: "", result: Result.defaultResult)
}

class TopicResponseFetcher: ObservableObject {
    @MainActor var topicData = TopicResponse.defaultTopicDetail
    @Published var fetching = false
    
    enum FetchError: Error {
        case badRequest
        case badJSON
    }
    
    @MainActor func fetchData(token: String, id: Int) async throws {
        print("topicdetail")
        fetching = true
        let url = URL(string:"https://www.v2ex.com/api/v2/topics/\(id)")!
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
