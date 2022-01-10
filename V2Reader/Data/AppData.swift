//
//  Data.swift
//  Social
//
//  Created by Jordan Singer on 12/27/21.
//

import Foundation

class AppData: ObservableObject {
    @Published var currentNode: String = UserDefaults.standard.string(forKey: "currentNode") ?? "home"
    @Published var pinnedNodes: [String] = UserDefaults.standard.stringArray(forKey: "pinnedNodes") ?? ["home"]
    
    func switchNode(newNode: String) {
        currentNode = newNode
        UserDefaults.standard.set(currentNode, forKey: "currentNode")
    }
    
    func addNode(name: String) {
        pinnedNodes.append(name)
        UserDefaults.standard.set(pinnedNodes, forKey: "pinnedNodes")
    }
}
