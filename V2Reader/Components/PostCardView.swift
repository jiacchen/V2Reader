//
//  PostCardView.swift
//  V2Reeder
//
//  Created by Jiachen Chen on 1/10/22.
//

import SwiftUI

struct PostCardView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var data: AppData
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
#if targetEnvironment(macCatalyst)
                        .font(.title2)
#else
                        .font(.title3)
#endif
                        .fontWeight(.medium)
                } else {
                    Text(topic.title)
#if targetEnvironment(macCatalyst)
                        .font(.title3)
#else
                        .font(.body)
#endif
                        .fontWeight(.medium)
                }
                
                if !topic.content.isEmpty {
                    if fullWidth {
                        ForEach(0..<topic.content_rendered.count) { index in
                            if !topic.content[index].isEmpty {
                                Text(topic.content_rendered[index])
#if targetEnvironment(macCatalyst)
                                    .font(.title3)
#else
                                    .font(.body)
#endif
                            }
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
                        if !topic.content[0].isEmpty {
                            Text(topic.content_rendered[0])
#if targetEnvironment(macCatalyst)
                                .font(.body)
#else
                                .font(.callout)
#endif
                                .lineLimit(2)
                        }
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
#if targetEnvironment(macCatalyst)
                                .font(.body)
#else
                                .font(.callout)
#endif
                                .foregroundColor(.secondary)
                            Text(nodeTitleWithLink)
#if targetEnvironment(macCatalyst)
                                .font(.body)
#else
                                .font(.callout)
#endif
                                .accentColor(.secondary)
                                .onAppear {
                                    nodeTitleWithLink = AttributedString(topic.node!.title)
                                    nodeTitleWithLink.link = URL(string: "v2reader://go/\(topic.node!.name)")
                                    nodeTitleWithLink.inlinePresentationIntent = .stronglyEmphasized
                                }
                            Text(" by ")
#if targetEnvironment(macCatalyst)
                                .font(.body)
#else
                                .font(.callout)
#endif
                                .foregroundColor(.secondary)
                            Text(usernameWithLink)
#if targetEnvironment(macCatalyst)
                                .font(.body)
#else
                                .font(.callout)
#endif
                                .accentColor(.secondary)
                                .onAppear {
                                    usernameWithLink = AttributedString(topic.member!.username)
                                    usernameWithLink.link = URL(string: "v2reader://member/\(topic.member!.username)")
                                    usernameWithLink.inlinePresentationIntent = .stronglyEmphasized
                                }
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
                                            if topicCollectionResponseFetcher.topicCollection.isEmpty {
                                                try? await topicCollectionResponseFetcher.fetchData(token: data.token!, name: data.currentNode, home: data.homeNodes)
                                            }
                                        }
                                    }
                                    dismiss()
                                default:
                                    break
                                }
                            }
                        } else {
                            Text(" ")
#if targetEnvironment(macCatalyst)
                                .font(.body)
#else
                                .font(.callout)
#endif
                                .foregroundColor(.secondary)
                                .hidden()
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
            NavigationLink(destination: PostDetailView(topicCollectionResponseFetcher: topicCollectionResponseFetcher, toProfile: toProfile).environmentObject(topic)) {
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
