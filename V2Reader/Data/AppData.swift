//
//  Data.swift
//  Social
//
//  Created by Jordan Singer on 12/27/21.
//

import Foundation

let defaultNodes = ["apple", "create", "macos", "ios"]

class AppData: ObservableObject {
    @Published var nodes = defaultNodes
    @Published var currentNode = "apple"
    
    func switchNode(name: String) {
        currentNode = name
    }
    
    func addNode(name: String) {
        nodes.append(name)
        currentNode = name
    }
}
