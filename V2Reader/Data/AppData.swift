//
//  Data.swift
//  Social
//
//  Created by Jordan Singer on 12/27/21.
//

import Foundation

class AppData: ObservableObject {
    @Published var pinnedNodes: [String] = UserDefaults.standard.stringArray(forKey: "pinnedNodes") ?? ["apple"]
    
    func addNode(name: String) {
        pinnedNodes.append(name)
        UserDefaults.standard.set(pinnedNodes, forKey: "pinnedNodes")
    }
}
