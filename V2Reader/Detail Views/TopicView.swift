//
//  PostDetailView.swift
//  V2Reeder
//
//  Created by Jiachen Chen on 1/10/22.
//

import SwiftUI

struct TopicView: View {
    @EnvironmentObject var data: AppData
    @EnvironmentObject var topic: Topic
    @StateObject private var topicDetailFetcher = TopicResponseFetcher()
    @StateObject private var replyResponseFetcher = ReplyResponseFetcher()
    @ObservedObject var topicCollectionResponseFetcher: TopicCollectionResponseFetcher
    @State var toProfile = false
    @State var member: Member?
    @State var showReturnButton = false
    @State var returnTo = 0
    @State var node: Node?
    @State var toNode = false
    
    var body: some View {
        ScrollViewReader { proxy in
            ZStack {
                List {
                    Section {
                        PostView(topicDetailFetcher: topicDetailFetcher, topicCollectionResponseFetcher: topicCollectionResponseFetcher, toProfile: $toProfile, member: $member, toNode: $toNode, node: $node, fullWidth: true)
                            .environmentObject(topic)
                            .listRowInsets(EdgeInsets())
                        ForEach(topic.supplements, id: \.id) { supplement in
                            SupplementView().environmentObject(supplement)
                                .listRowInsets(EdgeInsets())
                        }
                    }
                    Section {
                        ForEach(replyResponseFetcher.replyCollection.elements, id: \.0) { id, reply in
                            ReplyView(toProfile: $toProfile, member: $member)
                                .environmentObject(reply)
                                .listRowInsets(EdgeInsets())
                                .task {
                                    await replyResponseFetcher.fetchMoreIfNeeded(token: data.token!, id: id, topicId: topic.id)
                                }
                                .id(reply.num)
                                .onAppear {
                                    if reply.num == returnTo {
                                        returnTo = 0
                                        showReturnButton = false
                                    }
                                }
                        }
                        if !replyResponseFetcher.fullyFetched {
                            HStack {
                                Spacer()
                                ProgressView()
                                Spacer()
                            }
                            .listRowInsets(EdgeInsets())
                        }
                    }
                }
                .onOpenURL(perform: { url in
                    print(url)
                    let host = url.host
                    let path = url.path
                    if host == "reply" {
                        let jumpTo = Int(path.split(separator: "/")[0])
                        let jumpFrom = Int(path.split(separator: "/")[2])
                        withAnimation {
                            proxy.scrollTo(jumpTo, anchor: .top)
                        }
                        showReturnButton = true
                        returnTo = jumpFrom!
                    }
                })
                .listStyle(.grouped)
                .background {
                    NavigationLink(destination: ProfileView().environmentObject(member ?? Member(id: 0, username: "", url: "", website: nil, github: nil, bio: nil, avatar: "", created: 0)), isActive: $toProfile) {
                        EmptyView()
                    }
                    .hidden()
                }
                .background {
                    NavigationLink(isActive: $toNode) {
                        TopicCollectionView(refresh: .constant(false), nodeName: node?.name ?? "")
                            .toolbar {
                                ToolbarItem(placement: .principal) {
                                    Text(node?.title ?? "")
                                        .fontWeight(.semibold)
#if targetEnvironment(macCatalyst)
                                        .font(.title3)
#else
                                        .font(.headline)
#endif
                                }
                            }
                    } label: {
                        EmptyView()
                    }
                    .hidden()
                }
                .navigationBarTitleDisplayMode(.inline)
                .task {
                    if !topic.detailsAdded {
                        try? await topicDetailFetcher.fetchData(token: data.token!, id: topic.id)
                        var supplements: [Supplement] = []
                        for supplement in topicDetailFetcher.topicData.result.supplements {
                            supplements.append(Supplement(id: supplement.id, content: supplement.content, content_rendered: supplement.content_rendered, syntax: supplement.syntax, created: supplement.created))
                        }
                        topic.addDetails(member: Member(id: topicDetailFetcher.topicData.result.member.id, username: topicDetailFetcher.topicData.result.member.username, url: topicDetailFetcher.topicData.result.member.url, website: topicDetailFetcher.topicData.result.member.website, github: topicDetailFetcher.topicData.result.member.github, bio: topicDetailFetcher.topicData.result.member.bio, avatar: topicDetailFetcher.topicData.result.member.avatar, created: topicDetailFetcher.topicData.result.member.created), node: Node(id: topicDetailFetcher.topicData.result.node.id, url: topicDetailFetcher.topicData.result.node.url, name: topicDetailFetcher.topicData.result.node.name, title: topicDetailFetcher.topicData.result.node.title, header: topicDetailFetcher.topicData.result.node.header, footer: topicDetailFetcher.topicData.result.node.footer, avatar: topicDetailFetcher.topicData.result.node.avatar, topics: topicDetailFetcher.topicData.result.node.topics, created: topicDetailFetcher.topicData.result.node.created, last_modified: topicDetailFetcher.topicData.result.node.last_modified), supplements: supplements)
                    }
                    if replyResponseFetcher.replyCollectionData.result.isEmpty {
                        try? await replyResponseFetcher.fetchData(token: data.token!, id: topic.id)
                    }
                }
#if !targetEnvironment(macCatalyst)
                .refreshable {
                    try? await replyResponseFetcher.fetchData(token: data.token!, id: topic.id)
                }
#endif
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text(topic.replies == 1 ? "1 Reply" : "\(topic.replies) Replies")
                            .fontWeight(.semibold)
#if targetEnvironment(macCatalyst)
                            .font(.title3)
#else
                            .font(.headline)
#endif
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Link(destination: URL(string: topic.url)!) {
                            Image(systemName: "arrowshape.turn.up.backward")
                        }
                    }
                }
                
                if showReturnButton {
                    VStack {
                        Spacer()
                        Button {
                            withAnimation {
                                proxy.scrollTo(returnTo, anchor: .top)
                            }
                            showReturnButton = false
                            returnTo = 0
                        } label: {
                            Image(systemName: "chevron.down")
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.accentColor)
                                .clipShape(Circle())
                        }
                        .padding()
                    }
                }
            }
        }
    }
}
