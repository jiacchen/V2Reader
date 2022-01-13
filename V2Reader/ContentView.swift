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
    @Binding var refresh: Bool
    @State var tokenEntered = ""
    
    var body: some View {
        if !data.hasToken {
            ProgressView()
                .sheet(isPresented: .constant(true)) {
                    NavigationView {
                        VStack(alignment: .leading) {
                            Text("A **Personal Access Token** is required to access the V2EX API 2.0 Beta.")
                                .padding()
                            Text("Please follow the instruction on the [website](https://www.v2ex.com/help/personal-access-token) to create a token and enter it in the field below.")
                                .padding()
                            Text("The token you entered will be stored securely in the keychain.")
                                .padding()
                            HStack {
                                SecureField(text: $tokenEntered) {
                                    Text("Token...")
                                }
                                .submitLabel(.done)
                                .onSubmit {
                                    try? data.updateToken(token: tokenEntered)
                                }
                            }
                            .padding()
                            Spacer()
                        }
                        .padding()
                        .navigationTitle("Token")
                    }
                    .interactiveDismissDisabled()
                }
        } else {
            FeedView(refresh: $refresh)
                .tabItem {
                    Label("Feed", systemImage: "newspaper")
                }
#if targetEnvironment(macCatalyst)
                .withHostingWindow { window in
                    if let titlebar = window?.windowScene?.titlebar {
                        titlebar.titleVisibility = .hidden
                        titlebar.toolbar = nil
                    }
                }
//#else
//        TabView() {
//            FeedView(refresh: $refresh)
//                .tabItem {
//                    Label("Feed", systemImage: "newspaper")
//                }
            
//            ActivityView()
//                .tabItem {
//                    Label("Activity", systemImage: "bell")
//                }
//
//            NavigationView {
//                ProfileView()
//                    .environmentObject(Member(id: memberResponseFetcher.memberData.result.id, username: memberResponseFetcher.memberData.result.username, url: memberResponseFetcher.memberData.result.url, website: memberResponseFetcher.memberData.result.website, github: memberResponseFetcher.memberData.result.github, bio: memberResponseFetcher.memberData.result.bio, avatar: memberResponseFetcher.memberData.result.avatar_xxxlarge ?? memberResponseFetcher.memberData.result.avatar_large, created: memberResponseFetcher.memberData.result.created))
//            }
//            .navigationViewStyle(.stack)
//            .tabItem {
//                Label("Profile", systemImage: "person")
//            }
//        }
//        .task {
//            try? await memberResponseFetcher.fetchData(token: data.token!)
//        }
#endif
        }
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
