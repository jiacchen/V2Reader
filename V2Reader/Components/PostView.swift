//
//  PostCardView.swift
//  V2Reeder
//
//  Created by Jiachen Chen on 1/10/22.
//

import SwiftUI

struct PostView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var data: AppData
    @EnvironmentObject var topic: Topic
    @ObservedObject var topicDetailFetcher: TopicResponseFetcher
    @ObservedObject var topicCollectionResponseFetcher: TopicCollectionResponseFetcher
    @Binding var toProfile: Bool
    @Binding var member: Member?
    @Binding var toNode: Bool
    @Binding var node: Node?
    @State var usernameWithLink = AttributedString()
    @State var nodeTitleWithLink = AttributedString()
    var fullWidth = false
    
    var card: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 12) {
                if fullWidth {
                    Text(topic.title)
#if targetEnvironment(macCatalyst)
                        .font(.title2)
#else
                        .font(.title3)
#endif
                        .fontWeight(.medium)
                        .padding(.horizontal)
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
                        ForEach(0..<topic.content_rendered.count, id: \.self) { index in
                            if !topic.content[index].isEmpty {
                                Text(topic.content_rendered[index])
#if targetEnvironment(macCatalyst)
                                .font(.title3)
#else
                                .font(.body)
#endif
                                    .padding(.horizontal)
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
                                    case .failure:
                                        HStack {
                                            Spacer()
                                            Image(systemName: "photo")
                                            Spacer()
                                        }
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
#if targetEnvironment(macCatalyst)
                            .font(.body)
#else
                            .font(.callout)
#endif
                            .lineLimit(2)
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
                                        .cornerRadius(10)
                                case .failure:
                                    HStack {
                                        Spacer()
                                        Image(systemName: "photo")
                                        Spacer()
                                    }
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
                                    if path == topic.node!.name {
                                        toNode = true
                                        node = topic.node!
                                    }
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
                    .padding(.horizontal)
                }
                if fullWidth {
                    FooterView(fullWidth: true)
                        .padding(.horizontal)
                } else {
                    FooterView(fullWidth: false)
                }
            }
            .padding(.vertical)
        }
    }
    
    var body: some View {
        if fullWidth {
            card
        } else {
            NavigationLink(destination: TopicView(topicCollectionResponseFetcher: topicCollectionResponseFetcher, toProfile: toProfile).environmentObject(topic)) {
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
