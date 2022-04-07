//
//  ReplyCardView.swift
//  V2Reeder
//
//  Created by Jiachen Chen on 1/10/22.
//

import SwiftUI

struct ReplyView: View {
    @EnvironmentObject var data: AppData
    @EnvironmentObject var reply: Reply
    @EnvironmentObject var topic: Topic
    @Binding var toProfile: Bool
    @Binding var member: Member?
    @State var usernameWithLink = AttributedString()
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 12) {
                HStack() {
                    Text(usernameWithLink)
#if targetEnvironment(macCatalyst)
                        .font(.body)
#else
                        .font(.callout)
#endif
                        .accentColor(.primary)
                        .onAppear {
                            usernameWithLink = AttributedString(reply.member.username)
                            usernameWithLink.link = URL(string: "v2reader://member/\(reply.member.username)")
                            usernameWithLink.inlinePresentationIntent = .stronglyEmphasized
                        }
                        .onOpenURL { url in
                            let host = url.host
                            var path = url.path
                            switch host {
                            case "member":
                                path.removeFirst()
                                if path == reply.member.username {
                                    toProfile = true
                                    member = reply.member
                                }
                            default:
                                break
                            }
                        }
                    if reply.member.username == topic.member?.username {
                        Text("OP")
                            .padding(2)
#if targetEnvironment(macCatalyst)
                            .font(.footnote)
#else
                            .font(.caption2)
#endif
                            .foregroundColor(.secondary)
                            .background(Color(.systemGray5))
                            .cornerRadius(3)
                    }
                    Text("#\(reply.num)")
#if targetEnvironment(macCatalyst)
                        .font(.body)
#else
                        .font(.subheadline)
#endif
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(reply.formattedDate())
#if targetEnvironment(macCatalyst)
                        .font(.body)
#else
                        .font(.subheadline)
#endif
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                ForEach(0..<reply.content_rendered.count, id: \.self) { index in
                    if !reply.content[index].isEmpty {
                        Text(reply.content_rendered[index])
#if targetEnvironment(macCatalyst)
                            .font(.title3)
#else
                            .font(.body)
#endif
                            .padding(.horizontal)
                    }
                    if index < reply.imageURL.count {
                        AsyncImage(url: URL(string: reply.imageURL[index]), scale: 2) { phase in
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
            }
        }
        .padding(.vertical)
        .contentShape(Rectangle())
    }
}
