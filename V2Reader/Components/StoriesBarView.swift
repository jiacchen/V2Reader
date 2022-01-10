//
//  StoriesBarView.swift
//  Social
//
//  Created by Jordan Singer on 12/27/21.
//

import SwiftUI

struct StoriesBarView: View {
    @AppStorage("currentNode") var currentNode = "apple"
    @EnvironmentObject var data: AppData
    @ObservedObject var topicCollectionResponseFetcher: TopicCollectionResponseFetcher
    @ObservedObject var nodeCollectionFetcher: NodeCollectionFetcher
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 24) {
                if nodeCollectionFetcher.nodeCollectionData.isEmpty {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                } else {
                    ForEach(nodeCollectionFetcher.nodeCollectionData.elements, id: \.0) { name, node in
                        Button(action: {
                            currentNode = name
                            topicCollectionResponseFetcher.topicCollection = [:]
                            topicCollectionResponseFetcher.currentPage = 1
                            topicCollectionResponseFetcher.fullyFetched = false
                            Task {
                                if topicCollectionResponseFetcher.topicCollection.isEmpty && !topicCollectionResponseFetcher.fetching {
                                    try? await topicCollectionResponseFetcher.fetchData(name: currentNode)
                                }
                            }
                        }) {
                            VStack(spacing: 8) {
                                ZStack {
                                    AvatarView(url: node.avatar)
                                        .padding(4)
                                    if name == currentNode {
                                        Circle()
                                            .strokeBorder(Color.cyan, lineWidth: 2)
                                    }
                                }
                                Text(node.title)
                                    .font(.caption)
                                    .lineLimit(1)
                            }
                            .frame(width: 64)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .task {
                if !nodeCollectionFetcher.completed && !nodeCollectionFetcher.fetching {
                    try? await nodeCollectionFetcher.fetchData(names: data.pinnedNodes)
                }
            }
            .padding()
        }
    }
}

struct StoriesBarView_Previews: PreviewProvider {
    static var previews: some View {
        StoriesBarView(topicCollectionResponseFetcher: TopicCollectionResponseFetcher(), nodeCollectionFetcher: NodeCollectionFetcher())
    }
}
