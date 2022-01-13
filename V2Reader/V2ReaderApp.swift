//
//  SocialApp.swift
//  Social
//
//  Created by Jordan Singer on 12/25/21.
//

import SwiftUI

@main
struct V2ReaderApp: App {
    @State var refresh = false
    var data = AppData()
    
    var body: some Scene {
        WindowGroup {
            ContentView(refresh: $refresh)
                .environmentObject(data)
                .onAppear {
                    try? data.loadToken()
                }
        }
        .commands {
            CommandGroup(after: .sidebar) {
                Button("Refresh") {
                    refresh.toggle()
                }
                .keyboardShortcut("R", modifiers: .command)
            }
        }
    }
}
