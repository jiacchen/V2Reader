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
                        PostCardView(topicDetailFetcher: TopicResponseFetcher(), toProfile: .constant(false), member: .constant(nil))
                            .environmentObject(nodeCollectionFetcher.nodeCollectionData[data.currentNode]!)
                            .environmentObject(topic)
                            .task {
                                await topicCollectionResponseFetcher.fetchMoreIfNeeded(id: id, nodeName: data.currentNode)
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
                .onChange(of: refresh) { newValue in
                    Task {
                        topicCollectionResponseFetcher.topicCollection = [:]
                        topicCollectionResponseFetcher.currentPage = 1
                        topicCollectionResponseFetcher.fullyFetched = false
                        try? await topicCollectionResponseFetcher.fetchData(name: data.currentNode)
                    }
                }
#if !targetEnvironment(macCatalyst)
                .refreshable {
                    topicCollectionResponseFetcher.topicCollection = [:]
                    topicCollectionResponseFetcher.currentPage = 1
                    topicCollectionResponseFetcher.fullyFetched = false
                    try? await topicCollectionResponseFetcher.fetchData(name: data.currentNode)
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
                                        try? await topicCollectionResponseFetcher.fetchData(name: data.currentNode)
                                    }
                                }
                            }
                    } else {
                        Button(action: {
                            showNodeSearch = true
                        }) {
                            HStack(spacing: 4) {
                                Text(nodeCollectionFetcher.nodeCollectionData[data.currentNode]?.title ?? "Feed")
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
                    Button(action: { showNewPostView = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.headline)
                    }
                    .sheet(isPresented: $showNewPostView) {
                        NewPostView()
                            .environmentObject(data)
                    }
                }
            }
            Text("Nothing Selected.")
                .foregroundColor(.secondary)
        }
        .task {
            if !nodeCollectionFetcher.completed && !nodeCollectionFetcher.fetching {
                try? await nodeCollectionFetcher.fetchData(names: data.pinnedNodes)
            }
            if topicCollectionResponseFetcher.topicCollection.isEmpty && !topicCollectionResponseFetcher.fetching {
                try? await topicCollectionResponseFetcher.fetchData(name: data.currentNode)
            }
        }
    }
}

struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        FeedView(refresh: .constant(false))
    }
}
