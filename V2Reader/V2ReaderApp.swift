//
//  V2ReaderApp.swift
//  V2Reeder
//
//  Created by Jiachen Chen on 1/10/22.
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
