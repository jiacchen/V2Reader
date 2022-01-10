//
//  ReplyCardView.swift
//  V2EX
//
//  Created by Jiachen Chen on 1/4/22.
//

import SwiftUI

struct ReplyCardView: View {
    @Environment(\.horizontalSizeClass) var sizeClass
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
                        .font(.callout)
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
                    Text("#\(reply.num)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(reply.formattedDate())
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                ForEach(0..<reply.content_rendered.count) { index in
                    Text(reply.content_rendered[index])
                    if index < reply.imageURL.count {
                        AsyncImage(url: URL(string: reply.imageURL[index]), scale: 2) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
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
        }
        .padding(.vertical)
//        .padding(.horizontal, sizeClass == .compact ? nil : 32)
        .contentShape(Rectangle())
    }
    
    func share() {
        let activityVC = UIActivityViewController(activityItems: [reply.content, URL(string: "\(topic.url)#reply\(reply.num)")!], applicationActivities: nil)
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        windowScene.keyWindow?.rootViewController?.present(activityVC, animated: true, completion: nil)
    }
}

struct ReplyCardView_Previews: PreviewProvider {
    static var previews: some View {
        ReplyCardView(toProfile: .constant(false), member: .constant(nil))
    }
}
