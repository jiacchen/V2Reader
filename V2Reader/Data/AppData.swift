//
//  Data.swift
//  Social
//
//  Created by Jordan Singer on 12/27/21.
//

import Foundation
import OrderedCollections

enum KeychainError: Error {
    case noPassword
    case unexpectedPasswordData
    case unhandledError(status: OSStatus)
}

class AppData: ObservableObject {
    @Published var currentNode: String = UserDefaults.standard.string(forKey: "currentNode") ?? "home"
    @Published var pinnedNodes: [String] = UserDefaults.standard.stringArray(forKey: "pinnedNodes") ?? []
    @Published var homeNodes: [String] = UserDefaults.standard.stringArray(forKey: "homeNodes") ?? []
    @Published var allNodes: [String: String] = UserDefaults.standard.object(forKey: "allNodes") as? [String: String] ?? [:]
    @Published var fetching = false
    @Published var token: String?
    @Published var completedLoading = false
    
    func loadToken() throws {
        let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                    kSecAttrServer as String: "v2reader",
                                    kSecMatchLimit as String: kSecMatchLimitOne,
                                    kSecReturnAttributes as String: true,
                                    kSecReturnData as String: true]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status != errSecItemNotFound else {
            completedLoading = true
            return
        }
        guard status == errSecSuccess else {
            completedLoading = true
            throw KeychainError.unhandledError(status: status)
        }
        guard let existingItem = item as? [String : Any],
              let tokenData = existingItem[kSecValueData as String] as? Data
        else {
            completedLoading = true
            throw KeychainError.unexpectedPasswordData
        }
        token = String(data: tokenData, encoding: String.Encoding.utf8)
        completedLoading = true
    }
    
    func saveToken(token: String) throws {
        let tokenData = token.data(using: String.Encoding.utf8)!
        let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                    kSecAttrAccount as String: "default",
                                    kSecAttrServer as String: "v2reader",
                                    kSecValueData as String: tokenData]
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else { throw KeychainError.unhandledError(status: status) }
        self.token = token
    }
    
    func updateToken(token: String) throws {
        let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                    kSecAttrServer as String: "v2reader"]
        let tokenData = token.data(using: String.Encoding.utf8)!
        let attributes: [String: Any] = [kSecAttrAccount as String: "default",
                                         kSecValueData as String: tokenData]
        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        guard status != errSecItemNotFound else {
            try? saveToken(token: token)
            return
        }
        guard status == errSecSuccess else { throw KeychainError.unhandledError(status: status) }
        self.token = token
    }
    
    func deleteToken() throws {
        let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                    kSecAttrServer as String: "v2reader"]
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else { throw KeychainError.unhandledError(status: status) }
        self.token = nil
    }
    
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
