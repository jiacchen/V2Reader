//
//  PostDetailView.swift
//  Social
//
//  Created by Jordan Singer on 12/27/21.
//

import SwiftUI

struct PostDetailView: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    @EnvironmentObject var data: AppData
    @EnvironmentObject var node: Node
    @EnvironmentObject var topic: Topic
    @StateObject private var topicDetailFetcher = TopicResponseFetcher()
    @StateObject private var replyResponseFetcher = ReplyResponseFetcher()
    @State var toProfile: Bool = false
    @State var member: Member?
    
    var body: some View {
        List {
            PostCardView(topicDetailFetcher: topicDetailFetcher, toProfile: $toProfile, member: $member, fullWidth: true)
                .environmentObject(node)
                .environmentObject(topic)
            ForEach(replyResponseFetcher.replyCollection.elements, id: \.0) { id, reply in
                ReplyCardView(toProfile: $toProfile, member: $member)
                    .environmentObject(reply)
                    .task {
                        await replyResponseFetcher.fetchMoreIfNeeded(id: id, topicId: topic.id)
                    }
            }
            if !replyResponseFetcher.fullyFetched {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
            }
        }
        .background {
            if member != nil {
                NavigationLink(destination: ProfileView().environmentObject(member!), isActive: $toProfile) {
                    EmptyView()
                }.opacity(0)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
//        .textSelection(.enabled)
        .task {
            if replyResponseFetcher.replyCollectionData.result.isEmpty {
                try? await replyResponseFetcher.fetchData(id: topic.id)
            }
        }
#if !targetEnvironment(macCatalyst)
        .refreshable {
            try? await replyResponseFetcher.fetchData(id: topic.id)
        }
#endif
        .navigationBarTitle(topic.replies == 1 ? "1 Reply" : "\(topic.replies) Replies")
    }
}

struct PostDetailView_Previews: PreviewProvider {
    static var previews: some View {
        PostDetailView()
    }
}
