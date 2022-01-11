//
//  FeedView.swift
//  Social
//
//  Created by Jordan Singer on 12/26/21.
//

import SwiftUI

struct FeedView: View {
    @EnvironmentObject var data: AppData
    @State var showNewPostView = false
    @State var showNodeSearch = false
    @State var showNodeManagement = false
    @State var editMode = EditMode.inactive
    @State var edited = false
    @FocusState private var searchFieldIsFocused: Bool
    @StateObject private var topicCollectionResponseFetcher = TopicCollectionResponseFetcher()
    @StateObject private var nodeCollectionFetcher = NodeCollectionFetcher()
    @State var newNode = ""
    @Binding var refresh: Bool
    
    var body: some View {
        NavigationView {
            ZStack {
                List {
                    StoriesBarView(topicCollectionResponseFetcher: topicCollectionResponseFetcher, nodeCollectionFetcher: nodeCollectionFetcher)
                        .listRowInsets(EdgeInsets())
                    ForEach(topicCollectionResponseFetcher.topicCollection.elements, id: \.0) { (id, topic) in
                        PostCardView(topicDetailFetcher: TopicResponseFetcher(), topicCollectionResponseFetcher: topicCollectionResponseFetcher, toProfile: .constant(false), member: .constant(nil))
                            .environmentObject(nodeCollectionFetcher.nodeCollectionData[data.currentNode]!)
                            .environmentObject(topic)
                            .task {
                                await topicCollectionResponseFetcher.fetchMoreIfNeeded(id: id, nodeName: data.currentNode, homeNodes: data.homeNodes)
                            }
                    }
                    if !topicCollectionResponseFetcher.fullyFetched {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .disabled(showNodeSearch)
#if targetEnvironment(macCatalyst)
                .onChange(of: refresh) { newValue in
                    Task {
                        topicCollectionResponseFetcher.topicCollection = [:]
                        topicCollectionResponseFetcher.currentPage = 1
                        topicCollectionResponseFetcher.fullyFetched = false
                        try? await topicCollectionResponseFetcher.fetchData(name: data.currentNode)
                    }
                }
#else
                .refreshable {
                    topicCollectionResponseFetcher.topicCollection = [:]
                    topicCollectionResponseFetcher.currentPage = 1
                    topicCollectionResponseFetcher.fullyFetched = false
                    try? await topicCollectionResponseFetcher.fetchData(name: data.currentNode, home: data.homeNodes)
                }
#endif
                if showNodeSearch {
                    Rectangle()
                        .foregroundColor(.clear)
                        .contentShape(Rectangle())
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .onTapGesture {
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                            showNodeSearch = false
                        }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    if showNodeSearch {
                        TextField("Node...", text: $newNode)
                            .fixedSize()
                            .focused($searchFieldIsFocused)
                            .task {
                                searchFieldIsFocused = true
                            }
                            .submitLabel(.search)
                            .onSubmit {
                                showNodeSearch = false
                                data.addNode(name: newNode)
                                data.switchNode(newNode: newNode)
                                nodeCollectionFetcher.completed = false
                                topicCollectionResponseFetcher.topicCollection = [:]
                                topicCollectionResponseFetcher.currentPage = 1
                                topicCollectionResponseFetcher.fullyFetched = false
                                searchFieldIsFocused = false
                                newNode = ""
                                Task {
                                    if !nodeCollectionFetcher.completed && !nodeCollectionFetcher.fetching {
                                        try? await nodeCollectionFetcher.fetchData(names: data.pinnedNodes)
                                    }
                                    if topicCollectionResponseFetcher.topicCollection.isEmpty && !topicCollectionResponseFetcher.fetching {
                                        try? await topicCollectionResponseFetcher.fetchData(name: data.currentNode, home: data.homeNodes)
                                    }
                                }
                            }
                    } else {
                        Button(action: {
                            showNodeSearch = true
                        }) {
                            HStack(spacing: 4) {
                                Text(nodeCollectionFetcher.nodeCollectionData[data.currentNode]?.title ?? "")
                                    .foregroundColor(.primary)
                                    .fontWeight(.semibold)
                                    .font(.headline)
                                Image(systemName: "chevron.down")
                                    .resizable()
                                    .frame(width: 11, height: 5)
                                    .foregroundColor(.primary)
                                    .font(.headline)
                                    .padding(.top, 2)
                            }
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if showNodeSearch {
                        Button("Cancel") {
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                            showNodeSearch = false
                        }
                    } else {
                        Button {
                            showNodeManagement = true
                        } label: {
                            Image(systemName: "gear")
                        }
                    }
                }
            }
            Text("Nothing Selected.")
                .foregroundColor(.secondary)
        }
        .sheet(isPresented: $showNodeManagement, onDismiss: {
            editMode = EditMode.inactive
            if edited {
                edited = false
                nodeCollectionFetcher.completed = false
                if !data.pinnedNodes.contains(data.currentNode) {
                    data.switchNode(newNode: "home")
                    topicCollectionResponseFetcher.topicCollection = [:]
                    topicCollectionResponseFetcher.currentPage = 1
                    topicCollectionResponseFetcher.fullyFetched = false
                    Task {
                        if topicCollectionResponseFetcher.topicCollection.isEmpty && !topicCollectionResponseFetcher.fetching {
                            try? await topicCollectionResponseFetcher.fetchData(name: data.currentNode, home: data.homeNodes)
                        }
                    }
                }
                Task {
                    if !nodeCollectionFetcher.completed && !nodeCollectionFetcher.fetching {
                        try? await nodeCollectionFetcher.fetchData(names: data.pinnedNodes)
                    }
                }
            }
        }, content: {
            NavigationView {
                List {
                    Section("Home") {
                        ForEach(data.homeNodes, id: \.self) { name in
                            Text(nodeCollectionFetcher.nodeCollectionData[name]!.title)
                        }
                    }
                    Section("Pinned") {
                        ForEach(data.pinnedNodes, id: \.self) { name in
                            if name != "home" {
                                HStack {
                                    Text(nodeCollectionFetcher.nodeCollectionData[name]!.title)
                                    Spacer()
                                    if data.homeNodes.contains(name) {
                                        Image(systemName: "star.fill")
                                            .foregroundColor(Color.accentColor)
                                            .onTapGesture {
                                                data.removeFromHome(name: name)
                                                edited = true
                                            }
                                    } else {
                                        Image(systemName: "star.fill")
                                            .foregroundColor(Color(UIColor.systemFill))
                                            .onTapGesture {
                                                data.addToHome(name: name)
                                                edited = true
                                            }
                                    }
                                }
                            }
                        }
                        .onDelete { offsets in
                            data.removeNode(offsets: offsets)
                            edited = true
                        }
                        .onMove { offsets, dest in
                            data.pinnedNodes.move(fromOffsets: offsets, toOffset: dest)
                            edited = true
                        }
                    }
                }
                .navigationBarTitle(Text("Nodes"), displayMode: .inline)
                .navigationBarItems(trailing: Button(action: {
                    if editMode == EditMode.active {
                        editMode = EditMode.inactive
                    } else {
                        showNodeManagement = false
                    }
                }, label: {
                    Text("Done")
                        .fontWeight(.semibold)
                }))
                .navigationBarItems(leading: Button("Edit", action: {
                    editMode = EditMode.active
                }))
                .environment(\.editMode, $editMode)
            }
        })
        .task {
            if !nodeCollectionFetcher.completed && !nodeCollectionFetcher.fetching {
                try? await nodeCollectionFetcher.fetchData(names: data.pinnedNodes)
            }
            if topicCollectionResponseFetcher.topicCollection.isEmpty && !topicCollectionResponseFetcher.fetching {
                try? await topicCollectionResponseFetcher.fetchData(name: data.currentNode, home: data.homeNodes)
            }
        }
    }
}

extension UISplitViewController {
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.preferredDisplayMode = DisplayMode.oneBesideSecondary
        self.preferredSplitBehavior = SplitBehavior.tile
    }
}

struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        FeedView(refresh: .constant(false))
    }
}
