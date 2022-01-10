//
//  ContentView.swift
//  Social
//
//  Created by Jordan Singer on 12/25/21.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var data: AppData
    @StateObject private var memberResponseFetcher = MemberResponseFetcher()
    @State var tabSelection: TabSelection = .feed
    @Binding var refresh: Bool
    
    enum TabSelection: Hashable {
        case feed, activity, profile
    }
    
    var body: some View {
#if targetEnvironment(macCatalyst)
        FeedView(refresh: $refresh)
            .tabItem {
                Label("Feed", systemImage: "newspaper")
            }
            .withHostingWindow { window in
                if let titlebar = window?.windowScene?.titlebar {
                    titlebar.titleVisibility = .hidden
                    titlebar.toolbar = nil
                }
            }
#else
        TabView(selection: $tabSelection) {
            FeedView(refresh: $refresh)
                .tabItem {
                    Label("Feed", systemImage: "newspaper")
                }
                .tag(TabSelection.feed)
            
            ActivityView()
                .tabItem {
                    Label("Activity", systemImage: "bell")
                }
                .tag(TabSelection.activity)
            
            NavigationView {
                ProfileView()
                    .environmentObject(Member(id: memberResponseFetcher.memberData.result.id, username: memberResponseFetcher.memberData.result.username, url: memberResponseFetcher.memberData.result.url, website: memberResponseFetcher.memberData.result.website, github: memberResponseFetcher.memberData.result.github, bio: memberResponseFetcher.memberData.result.bio, avatar: memberResponseFetcher.memberData.result.avatar_xxxlarge ?? memberResponseFetcher.memberData.result.avatar_large, created: memberResponseFetcher.memberData.result.created))
            }
            .navigationViewStyle(.stack)
            .tabItem {
                Label("Profile", systemImage: "person")
            }
            .tag(TabSelection.profile)
        }
        .task {
            try? await memberResponseFetcher.fetchData()
        }
#endif
    }
}

extension View {
    fileprivate func withHostingWindow(_ callback: @escaping (UIWindow?) -> Void) -> some View {
        self.background(HostingWindowFinder(callback: callback))
    }
}

fileprivate struct HostingWindowFinder: UIViewRepresentable {
    var callback: (UIWindow?) -> ()
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        DispatchQueue.main.async { [weak view] in
            self.callback(view?.window)
        }
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(refresh: .constant(false))
    }
}
