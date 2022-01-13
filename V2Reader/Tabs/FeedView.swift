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
    @State var showNodeManagement = false
    @State var editMode = EditMode.inactive
    @State var edited = false
    @State var homeChanged = false
    @FocusState private var searchFieldIsFocused: Bool
    @StateObject private var topicCollectionResponseFetcher = TopicCollectionResponseFetcher()
    @StateObject private var nodeCollectionFetcher = NodeCollectionFetcher()
    @Binding var refresh: Bool
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    StoriesBarView(topicCollectionResponseFetcher: topicCollectionResponseFetcher, nodeCollectionFetcher: nodeCollectionFetcher)
                        .listRowInsets(EdgeInsets())
                }
                ForEach(topicCollectionResponseFetcher.topicCollection.elements, id: \.0) { (id, topic) in
                    PostCardView(topicDetailFetcher: TopicResponseFetcher(), topicCollectionResponseFetcher: topicCollectionResponseFetcher, toProfile: .constant(false), member: .constant(nil))
                        .environmentObject(nodeCollectionFetcher.nodeCollectionData[data.currentNode]!)
                        .environmentObject(topic)
                        .task {
                            await topicCollectionResponseFetcher.fetchMoreIfNeeded(token: data.token!, id: id, nodeName: data.currentNode, homeNodes: data.homeNodes)
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
#if targetEnvironment(macCatalyst)
            .onChange(of: refresh) { newValue in
                Task {
                    topicCollectionResponseFetcher.topicCollection = [:]
                    topicCollectionResponseFetcher.currentPage = 1
                    topicCollectionResponseFetcher.fullyFetched = false
                    try? await topicCollectionResponseFetcher.fetchData(token: data.token!, name: data.currentNode, home: data.homeNodes)
                }
            }
#else
            .refreshable {
                topicCollectionResponseFetcher.topicCollection = [:]
                topicCollectionResponseFetcher.currentPage = 1
                topicCollectionResponseFetcher.fullyFetched = false
                try? await topicCollectionResponseFetcher.fetchData(token: data.token!, name: data.currentNode, home: data.homeNodes)
            }
#endif
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Button(action: {
                        showNodeManagement = true
                    }) {
                        HStack(spacing: 4) {
                            if nodeCollectionFetcher.nodeCollectionData[data.currentNode] != nil {
                                Text(nodeCollectionFetcher.nodeCollectionData[data.currentNode]!.title)
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
            }
            Text("Nothing Selected.")
                .foregroundColor(.secondary)
        }
        .sheet(isPresented: $showNodeManagement, onDismiss: {
            editMode = EditMode.inactive
            if edited {
                edited = false
                nodeCollectionFetcher.completed = false
                if data.currentNode != "home" && !data.pinnedNodes.contains(data.currentNode) {
                    data.switchNode(newNode: "home")
                    topicCollectionResponseFetcher.topicCollection = [:]
                    topicCollectionResponseFetcher.currentPage = 1
                    topicCollectionResponseFetcher.fullyFetched = false
                    Task {
                        if topicCollectionResponseFetcher.topicCollection.isEmpty && !topicCollectionResponseFetcher.fetching {
                            try? await topicCollectionResponseFetcher.fetchData(token: data.token!, name: data.currentNode, home: data.homeNodes)
                        }
                    }
                }
                Task {
                    if !nodeCollectionFetcher.completed && !nodeCollectionFetcher.fetching {
                        try? await nodeCollectionFetcher.fetchData(token: data.token!, names: data.pinnedNodes)
                    }
                }
            }
            if homeChanged && data.currentNode == "home" {
                homeChanged = false
                topicCollectionResponseFetcher.topicCollection = [:]
                topicCollectionResponseFetcher.currentPage = 1
                topicCollectionResponseFetcher.fullyFetched = false
                Task {
                    if topicCollectionResponseFetcher.topicCollection.isEmpty && !topicCollectionResponseFetcher.fetching {
                        try? await topicCollectionResponseFetcher.fetchData(token: data.token!, name: data.currentNode, home: data.homeNodes)
                    }
                }
            }
        }, content: {
            SheetView(editMode: $editMode, homeChanged: $homeChanged, edited: $edited, showNodeManagement: $showNodeManagement, nodeCollectionFetcher: nodeCollectionFetcher, topicCollectionResponseFetcher: topicCollectionResponseFetcher).environmentObject(data)
        })
        .task {
            if !nodeCollectionFetcher.completed && !nodeCollectionFetcher.fetching {
                try? await nodeCollectionFetcher.fetchData(token: data.token!, names: data.pinnedNodes)
            }
            if topicCollectionResponseFetcher.topicCollection.isEmpty && !topicCollectionResponseFetcher.fetching {
                try? await topicCollectionResponseFetcher.fetchData(token: data.token!, name: data.currentNode, home: data.homeNodes)
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
