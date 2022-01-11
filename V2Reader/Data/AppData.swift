//
//  Data.swift
//  Social
//
//  Created by Jordan Singer on 12/27/21.
//

import Foundation
import OrderedCollections

class AppData: ObservableObject {
    @Published var currentNode: String = UserDefaults.standard.string(forKey: "currentNode") ?? "home"
    @Published var pinnedNodes: [String] = UserDefaults.standard.stringArray(forKey: "pinnedNodes") ?? []
    @Published var homeNodes: [String] = UserDefaults.standard.stringArray(forKey: "homeNodes") ?? []
    @Published var allNodes: [String: String] = UserDefaults.standard.object(forKey: "allNodes") as? [String: String] ?? [:]
    @Published var fetching = false
    
    func switchNode(newNode: String) {
        currentNode = newNode
        UserDefaults.standard.set(currentNode, forKey: "currentNode")
    }
    
    func addNode(name: String) {
        if !pinnedNodes.contains(name) {
            pinnedNodes.append(name)
            UserDefaults.standard.set(pinnedNodes, forKey: "pinnedNodes")
        }
    }
    
    func removeNode(offsets: IndexSet) {
        pinnedNodes.remove(atOffsets: offsets)
        UserDefaults.standard.set(pinnedNodes, forKey: "pinnedNodes")
    }
    
    func addToHome(name: String) {
        if !homeNodes.contains(name) {
            homeNodes.append(name)
            homeNodes.sort()
            UserDefaults.standard.set(homeNodes, forKey: "homeNodes")
        }
    }
    
    func removeFromHome(offsets: IndexSet) {
        homeNodes.remove(atOffsets: offsets)
        UserDefaults.standard.set(homeNodes, forKey: "homeNodes")
    }
    
    func removeFromHome(name: String) {
        homeNodes.remove(at: homeNodes.firstIndex(of: name)!)
        UserDefaults.standard.set(homeNodes, forKey: "homeNodes")
    }
    
    func fetchAllNodes() async throws {
        fetching = true
        if let url = URL(string:"https://www.v2ex.com/planes") {
            do {
                let content = try String(contentsOf: url)
                let regex = try! NSRegularExpression(pattern: #"<a href="/go/[a-z0-9]+" class="item_node">.+</a>"#)
                let matches = regex.matches(in: content, options: [], range: NSRange(location: 0, length: content.utf16.count))
                for match in matches {
                    guard let range = Range(match.range, in: content) else { continue }
                    let line = content[range]
                    let parts = line.split(separator: "/")
                    let name = String(parts[2].split(separator: "\"")[0])
                    var title = String(parts[2].split(separator: ">")[1])
                    title.removeLast()
                    allNodes[name] = title
                }
            } catch {
                throw error
            }
        }
        UserDefaults.standard.set(allNodes, forKey: "allNodes")
        fetching = false
    }
    
    func getAllNodes(refresh: Bool) async throws {
        if refresh || allNodes.count <= 1 {
            try await fetchAllNodes()
        }
    }
}
