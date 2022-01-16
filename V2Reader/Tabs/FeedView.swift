//
//  FeedView.swift
//  V2Reeder
//
//  Created by Jiachen Chen on 1/10/22.
//

import SwiftUI

struct FeedView: View {
    @EnvironmentObject var data: AppData
    var nodeName: String
    @State var showNewPostView = false
    @StateObject var topicCollectionResponseFetcher = TopicCollectionResponseFetcher()
    @Binding var refresh: Bool
    
    var body: some View {
        List {
            ForEach(topicCollectionResponseFetcher.topicCollection.elements, id: \.0) { (id, topic) in
                PostCardView(topicDetailFetcher: TopicResponseFetcher(), topicCollectionResponseFetcher: topicCollectionResponseFetcher, toProfile: .constant(false), member: .constant(nil), toNode: .constant(false), node: .constant(nil))
                    .listRowSeparator(.hidden)
                    .environmentObject(topic)
                    .task {
                        await topicCollectionResponseFetcher.fetchMoreIfNeeded(token: data.token!, id: id, nodeName: nodeName, homeNodes: data.homeNodes)
                    }
            }
            if !topicCollectionResponseFetcher.fullyFetched {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .listRowSeparator(.hidden)
            }
        }
        .task {
            if topicCollectionResponseFetcher.topicCollection.isEmpty {
                try? await topicCollectionResponseFetcher.fetchData(token: data.token!, name: nodeName, home: data.homeNodes)
            }
        }
        .listStyle(.plain)
#if targetEnvironment(macCatalyst)
        .onChange(of: refresh) { newValue in
            Task {
                topicCollectionResponseFetcher.topicCollection = [:]
                topicCollectionResponseFetcher.currentPage = 1
                topicCollectionResponseFetcher.fullyFetched = false
                try? await topicCollectionResponseFetcher.fetchData(token: data.token!, name: nodeName, home: data.homeNodes)
            }
        }
#else
        .refreshable {
            topicCollectionResponseFetcher.topicCollection = [:]
            topicCollectionResponseFetcher.currentPage = 1
            topicCollectionResponseFetcher.fullyFetched = false
            try? await topicCollectionResponseFetcher.fetchData(token: data.token!, name: nodeName, home: data.homeNodes)
        }
#endif
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        FeedView(nodeName: "home", refresh: .constant(false))
    }
}
