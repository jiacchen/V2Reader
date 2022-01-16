//
//  ContentView.swift
//  V2Reeder
//
//  Created by Jiachen Chen on 1/10/22.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var data: AppData
    @StateObject private var memberResponseFetcher = MemberResponseFetcher()
    @Binding var refresh: Bool
    @State var tokenEntered = ""
    @State var showNodeManagement = false
    @State var editMode = EditMode.inactive
    @State var edited = false
    @State var homeChanged = false
    @StateObject var tokenFetcher = TokenFetcher()
    @StateObject var nodeCollectionFetcher = NodeCollectionFetcher()
    
    var body: some View {
        if data.token == nil {
            ProgressView()
                .sheet(isPresented: $data.completedLoading) {
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
                                    Task {
                                        try? await tokenFetcher.fetchData(token: tokenEntered)
                                    }
                                }
                                .onChange(of: tokenFetcher.completed, perform: { completed in
                                    if completed && !tokenFetcher.tokenInvalid {
                                        tokenFetcher.completed = false
                                        try? data.updateToken(token: tokenEntered)
                                    }
                                })
                                .alert("Invalid token!\nPlease try again.", isPresented: $tokenFetcher.tokenInvalid) {
                                    Button("OK") {
                                        tokenFetcher.completed = false
                                        tokenFetcher.tokenInvalid = false
                                    }
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
            NavigationView {
                List {
                    HStack {
                        Spacer()
                        Image("Logo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 128)
                        Spacer()
                    }
                    .listRowBackground(Color.clear)
                    
                    NavigationLink {
                        FeedView(refresh: $refresh, nodeName: "home")
                            .toolbar {
                                ToolbarItem(placement: .principal) {
                                    Text("Home")
                                        .fontWeight(.semibold)
#if targetEnvironment(macCatalyst)
                                        .font(.title3)
#else
                                        .font(.headline)
#endif
                                }
                            }
#if targetEnvironment(macCatalyst)
                            .withHostingWindow { window in
                                if let titlebar = window?.windowScene?.titlebar {
                                    titlebar.titleVisibility = .hidden
                                    titlebar.toolbar = nil
                                }
                            }
#endif
                    } label: {
                        HStack {
                            AvatarView(url: "")
                                .frame(width: 48)
                            Text("Home")
#if targetEnvironment(macCatalyst)
                                .font(.title3)
                                .fontWeight(.medium)
#else
                                .font(.headline)
#endif
                                .padding()
                        }
#if targetEnvironment(macCatalyst)
                        .padding(.vertical)
#endif
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    
                    Section {
                        ForEach(nodeCollectionFetcher.nodeCollectionData.elements, id: \.0) { name, node in
                            if name != "home" {
                                NavigationLink {
                                    FeedView(refresh: $refresh, nodeName: name)
                                        .toolbar {
                                            ToolbarItem(placement: .principal) {
                                                Text(node.title)
                                                    .fontWeight(.semibold)
#if targetEnvironment(macCatalyst)
                                                    .font(.title3)
#else
                                                    .font(.headline)
#endif
                                            }
                                            ToolbarItem(placement: .navigationBarTrailing) {
                                                Link(destination: URL(string: "https://www.v2ex.com/write")!) {
                                                    Image(systemName: "plus")
                                                }
                                            }
                                        }
#if targetEnvironment(macCatalyst)
                                        .withHostingWindow { window in
                                            if let titlebar = window?.windowScene?.titlebar {
                                                titlebar.titleVisibility = .hidden
                                                titlebar.toolbar = nil
                                            }
                                        }
#endif
                                } label: {
                                    HStack {
                                        AvatarView(url: node.avatar)
                                            .frame(width: 48)
                                        Text(node.title)
#if targetEnvironment(macCatalyst)
                                            .font(.title3)
                                            .fontWeight(.medium)
#else
                                            .font(.headline)
#endif
                                            .padding()
                                    }
#if targetEnvironment(macCatalyst)
                                    .padding(.vertical, 12)
#endif
                                }
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                            }
                        }
                    } header: {
                        Text("Pinned")
                    }
                    
                    NavigationLink {
                        ProfileView()
                            .environmentObject(Member(id: memberResponseFetcher.memberData.result.id, username: memberResponseFetcher.memberData.result.username, url: memberResponseFetcher.memberData.result.url, website: memberResponseFetcher.memberData.result.website, github: memberResponseFetcher.memberData.result.github, bio: memberResponseFetcher.memberData.result.bio, avatar: memberResponseFetcher.memberData.result.avatar_xxxlarge ?? memberResponseFetcher.memberData.result.avatar_large, created: memberResponseFetcher.memberData.result.created))
                    } label: {
                        HStack {
                            AvatarView(url: memberResponseFetcher.memberData.result.avatar_xxxlarge ?? memberResponseFetcher.memberData.result.avatar_large)
                                .frame(width: 48)
                            Text(memberResponseFetcher.memberData.result.username)
#if targetEnvironment(macCatalyst)
                                .font(.title3)
                                .fontWeight(.medium)
#else
                                .font(.headline)
#endif
                                .padding()
                        }
#if targetEnvironment(macCatalyst)
                        .padding(.vertical)
#endif
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }
                .task {
                    if !nodeCollectionFetcher.completed {
                        try? await nodeCollectionFetcher.fetchData(token: data.token!, names: data.pinnedNodes)
                    }
                    if !memberResponseFetcher.completed {
                        try? await memberResponseFetcher.fetchData(token: data.token!)
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            showNodeManagement = true
                        } label: {
                            Image(systemName: "switch.2")
                        }

                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink {
                            ActivityView()
                        } label: {
                            Image(systemName: "bell")
                        }
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                FeedView(refresh: $refresh, nodeName: "home")
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                            Text("Home")
                                .fontWeight(.semibold)
#if targetEnvironment(macCatalyst)
                                .font(.title3)
#else
                                .font(.headline)
#endif
                        }
                    }
                Text("Nothing Selected")
#if targetEnvironment(macCatalyst)
                    .font(.title3)
                    .withHostingWindow { window in
                        if let titlebar = window?.windowScene?.titlebar {
                            titlebar.titleVisibility = .hidden
                            titlebar.toolbar = nil
                        }
                    }
#else
                    .font(.body)
#endif
                    .foregroundColor(.secondary)
            }
            .task {
                try? await tokenFetcher.fetchData(token: data.token!)
            }
            .onChange(of: tokenFetcher.completed, perform: { completed in
                if completed && tokenFetcher.tokenInvalid {
                    tokenFetcher.completed = false
                    try? data.deleteToken()
                }
            })
            .sheet(isPresented: $showNodeManagement, onDismiss: {
                editMode = EditMode.inactive
                if edited {
                    edited = false
                    nodeCollectionFetcher.completed = false
                    Task {
                        if !nodeCollectionFetcher.completed {
                            try? await nodeCollectionFetcher.fetchData(token: data.token!, names: data.pinnedNodes)
                        }
                    }
                }
            }, content: {
                SheetView(editMode: $editMode, homeChanged: $homeChanged, edited: $edited, showNodeManagement: $showNodeManagement, nodeCollectionFetcher: nodeCollectionFetcher).environmentObject(data)
            })
        }
    }
}

extension UISplitViewController {
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.preferredDisplayMode = DisplayMode.twoOverSecondary
#if targetEnvironment(macCatalyst)
        self.preferredSplitBehavior = SplitBehavior.displace
#else
        self.preferredSplitBehavior = SplitBehavior.automatic
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
