//
//  PostHeaderView.swift
//  V2Reeder
//
//  Created by Jiachen Chen on 1/10/22.
//

import SwiftUI

struct PostHeaderView: View {
    @EnvironmentObject var topic: Topic
    
    var body: some View {
        NavigationLink(destination: ProfileView()) {
            HStack(spacing: 12) {
//                AvatarView(url: topic.member.avatar)
//                    .frame(width: 48, height: 48)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(topic.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .lineLimit(1)
//                    Text("@\(topic.member.username) · \(topic.formattedDate())")
//                        .font(.subheadline)
//                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
        }
        .buttonStyle(.plain)
    }
}

struct PostHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        PostHeaderView()
    }
}
