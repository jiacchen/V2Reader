//
//  Node.swift
//  V2EX
//
//  Created by Jiachen Chen on 1/5/22.
//

import Foundation
import OrderedCollections

class Node: ObservableObject {
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
    
    init(id: Int, url: String, name: String, title: String, header: String, footer: String, avatar: String, topics: Int, created: TimeInterval, last_modified: TimeInterval) {
        self.id = id
        self.url = url
        self.name = name
        self.title = title
        self.header = header
        self.footer = footer
        self.avatar = avatar
        self.topics = topics
        self.created = created
        self.last_modified = last_modified
    }
}

struct NodeResponse: Codable {
    struct Result: Codable {
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
        
        static let defaultResult = Result(id: 0, url: "", name: "", title: "", header: "", footer: "", avatar: "", topics: 0, created: 0, last_modified: 0)
    }
    
    var success: Bool
    var message: String
    var result: Result
    
    static let defaultNodeResponse = NodeResponse(success: false, message: "", result: Result.defaultResult)
}

@MainActor
class NodeCollectionFetcher: ObservableObject {
    @Published var nodeCollectionData: OrderedDictionary<String, Node> = ["home": Node(id: 0, url: "", name: "home", title: "Home", header: "", footer: "", avatar: "", topics: 0, created: 0, last_modified: 0)]
    @Published var completed = false
    @Published var fetching = false
    var storedNodes: [String: Data] = UserDefaults.standard.object(forKey: "storedNodes") as? [String: Data] ?? [:]
    
    enum FetchError: Error {
        case badRequest
        case badJSON
    }
    
    func fetchData(names: [String]) async throws {
        fetching = true
        for name in names {
            if nodeCollectionData[name] == nil {
                if storedNodes[name] == nil {
                    print("nodecollection")
                    let url = URL(string:"https://www.v2ex.com/api/v2/nodes/\(name)")!
                    let token = "ec8a1394-93a0-4a7e-b513-f5c129226796"
                    var request = URLRequest(url: url)
                    request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                    request.httpMethod = "GET"
                    let (data, response) = try await URLSession.shared.data(for: request)
                    guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw FetchError.badRequest }
                    storedNodes[name] = data
                    UserDefaults.standard.set(storedNodes, forKey: "storedNodes")
                    let nodeResponse = try JSONDecoder().decode(NodeResponse.self, from: data)
                    nodeCollectionData[name] = Node(id: nodeResponse.result.id, url: nodeResponse.result.url, name: nodeResponse.result.name, title: nodeResponse.result.title, header: nodeResponse.result.header, footer: nodeResponse.result.footer, avatar: nodeResponse.result.avatar, topics: nodeResponse.result.topics, created: nodeResponse.result.created, last_modified: nodeResponse.result.last_modified)
                } else {
                    let data = storedNodes[name]!
                    let nodeResponse = try JSONDecoder().decode(NodeResponse.self, from: data)
                    nodeCollectionData[name] = Node(id: nodeResponse.result.id, url: nodeResponse.result.url, name: nodeResponse.result.name, title: nodeResponse.result.title, header: nodeResponse.result.header, footer: nodeResponse.result.footer, avatar: nodeResponse.result.avatar, topics: nodeResponse.result.topics, created: nodeResponse.result.created, last_modified: nodeResponse.result.last_modified)
                }
            }
        }
        fetching = false
        completed = true
    }
}
