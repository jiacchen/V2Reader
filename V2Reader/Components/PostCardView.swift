//
//  PostCardView.swift
//  Social
//
//  Created by Jordan Singer on 12/26/21.
//

import SwiftUI

struct PostCardView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var data: AppData
    @EnvironmentObject var node: Node
    @EnvironmentObject var topic: Topic
    @ObservedObject var topicDetailFetcher: TopicResponseFetcher
    @ObservedObject var topicCollectionResponseFetcher: TopicCollectionResponseFetcher
    @Binding var toProfile: Bool
    @Binding var member: Member?
    @State var usernameWithLink = AttributedString()
    @State var nodeTitleWithLink = AttributedString()
    var fullWidth = false
    
    var card: some View {
        VStack(spacing: 0) {
//            PostHeaderView()
//                .environmentObject(topic)
            VStack(alignment: .leading, spacing: 12) {
                if fullWidth {
                    Text(topic.title)
                        .font(.title3)
                        .fontWeight(.medium)
                } else {
                    Text(topic.title)
                        .font(.body)
                        .fontWeight(.medium)
                }
                
                if !topic.content.isEmpty {
                    if fullWidth {
                        ForEach(0..<topic.content_rendered.count) { index in
                            Text(topic.content_rendered[index])
                            if index < topic.imageURL.count {
                                AsyncImage(url: URL(string: topic.imageURL[index]), scale: 2) { phase in
                                    switch phase {
                                    case .empty:
                                        HStack {
                                            Spacer()
                                            ProgressView()
                                            Spacer()
                                        }
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .cornerRadius(12)
                                    case .failure:
                                        Image(systemName: "photo")
                                    @unknown default:
                                        // Since the AsyncImagePhase enum isn't frozen,
                                        // we need to add this currently unused fallback
                                        // to handle any new cases that might be added
                                        // in the future:
                                        EmptyView()
                                    }
                                }
                            }
                        }
                    } else {
                        Text(topic.content_rendered[0])
                            .font(.callout)
                            .lineLimit(3)
                        if !topic.imageURL.isEmpty {
                            AsyncImage(url: URL(string: topic.imageURL[0]), scale: 2) { phase in
                                switch phase {
                                case .empty:
                                    HStack {
                                        Spacer()
                                        ProgressView()
                                        Spacer()
                                    }
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .cornerRadius(12)
                                case .failure:
                                    Image(systemName: "photo")
                                @unknown default:
                                    // Since the AsyncImagePhase enum isn't frozen,
                                    // we need to add this currently unused fallback
                                    // to handle any new cases that might be added
                                    // in the future:
                                    EmptyView()
                                }
                            }
                        }
                    }
                }
                
                if fullWidth {
                    HStack(spacing: 0) {
                        if topic.detailsAdded {
                            Text("in ")
                                .font(.callout)
                                .foregroundColor(.secondary)
                            Text(nodeTitleWithLink)
                                .font(.callout)
                                .accentColor(.secondary)
                                .onAppear {
                                    nodeTitleWithLink = AttributedString(topic.node!.title)
                                    nodeTitleWithLink.link = URL(string: "v2reader://go/\(topic.node!.name)")
                                    nodeTitleWithLink.inlinePresentationIntent = .stronglyEmphasized
                                }
                            Text(" by ")
                                .font(.callout)
                                .foregroundColor(.secondary)
                            Text(usernameWithLink)
                                .font(.callout)
                                .accentColor(.secondary)
                                .onAppear {
                                    usernameWithLink = AttributedString(topic.member!.username)
                                    usernameWithLink.link = URL(string: "v2reader://member/\(topic.member!.username)")
                                    usernameWithLink.inlinePresentationIntent = .stronglyEmphasized
                                }
//                            NavigationLink(destination: ProfileView().environmentObject(topic.member!), isActive: $toProfile) {
//                                Text(topic.member!.username)
//                                    .font(.callout)
//                                    .foregroundColor(.secondary)
//                                    .fontWeight(.medium)
//                            }
                            .onOpenURL { url in
                                let host = url.host
                                var path = url.path
                                switch host {
                                case "member":
                                    path.removeFirst()
                                    if path == topic.member!.username {
                                        toProfile = true
                                        member = topic.member!
                                    }
                                case "go":
                                    path.removeFirst()
                                    if data.currentNode != path {
                                        data.switchNode(newNode: path)
                                        topicCollectionResponseFetcher.topicCollection = [:]
                                        topicCollectionResponseFetcher.currentPage = 1
                                        topicCollectionResponseFetcher.fullyFetched = false
                                        Task {
                                            if topicCollectionResponseFetcher.topicCollection.isEmpty && !topicCollectionResponseFetcher.fetching {
                                                try? await topicCollectionResponseFetcher.fetchData(name: data.currentNode, home: data.homeNodes)
                                            }
                                        }
                                    }
                                    dismiss()
                                default:
                                    break
                                }
                            }
                        }
                    }
                    .task {
                        if !topic.detailsAdded && !topicDetailFetcher.fetching {
                            try? await topicDetailFetcher.fetchData(id: topic.id)
                            var supplements: [Supplement] = []
                            for supplement in topicDetailFetcher.topicData.result.supplements {
                                supplements.append(Supplement(id: supplement.id, content: supplement.content, content_rendered: supplement.content_rendered, syntax: supplement.syntax, created: supplement.created))
                            }
                            topic.addDetails(member: Member(id: topicDetailFetcher.topicData.result.member.id, username: topicDetailFetcher.topicData.result.member.username, url: topicDetailFetcher.topicData.result.member.url, website: topicDetailFetcher.topicData.result.member.website, github: topicDetailFetcher.topicData.result.member.github, bio: topicDetailFetcher.topicData.result.member.bio, avatar: topicDetailFetcher.topicData.result.member.avatar, created: topicDetailFetcher.topicData.result.member.created), node: Node(id: topicDetailFetcher.topicData.result.node.id, url: topicDetailFetcher.topicData.result.node.url, name: topicDetailFetcher.topicData.result.node.name, title: topicDetailFetcher.topicData.result.node.title, header: topicDetailFetcher.topicData.result.node.header, footer: topicDetailFetcher.topicData.result.node.footer, avatar: topicDetailFetcher.topicData.result.node.avatar, topics: topicDetailFetcher.topicData.result.node.topics, created: topicDetailFetcher.topicData.result.node.created, last_modified: topicDetailFetcher.topicData.result.node.last_modified), supplements: supplements)
                        }
                    }
                }
                    
                PostReactionsBarView(fullWidth: fullWidth)
            }
            .padding(.vertical)
        }
    }
    
    var body: some View {
        if fullWidth {
            card
        } else {
            NavigationLink(destination: PostDetailView(topicCollectionResponseFetcher: topicCollectionResponseFetcher, toProfile: toProfile).environmentObject(node).environmentObject(topic)) {
                card
            }
        }
    }
}

struct CustomButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}

struct PostCardView_Previews: PreviewProvider {
    static var previews: some View {
        PostCardView(topicDetailFetcher: TopicResponseFetcher(), topicCollectionResponseFetcher: TopicCollectionResponseFetcher(), toProfile: .constant(false), member: .constant(nil))
    }
}
