//
//  SocialApp.swift
//  Social
//
//  Created by Jordan Singer on 12/25/21.
//

import SwiftUI

@main
struct V2ReaderApp: App {
    var data = AppData()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(data)
        }
    }
}
