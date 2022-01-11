//
//  Data.swift
//  Social
//
//  Created by Jordan Singer on 12/27/21.
//

import Foundation

class AppData: ObservableObject {
    @Published var currentNode: String = UserDefaults.standard.string(forKey: "currentNode") ?? "home"
    @Published var pinnedNodes: [String] = UserDefaults.standard.stringArray(forKey: "pinnedNodes") ?? []
    @Published var homeNodes: [String] = UserDefaults.standard.stringArray(forKey: "homeNodes") ?? []
    
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
}
