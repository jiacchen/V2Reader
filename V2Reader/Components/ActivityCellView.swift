//
//  ActivityCellView.swift
//  Social
//
//  Created by Jordan Singer on 12/26/21.
//

import SwiftUI

struct ActivityCellView: View {
    @State var activity: Activity
    
    var body: some View {
        NavigationLink(destination: ProfileView().environmentObject(activity.user)) {
            HStack(spacing: 12) {
//                AvatarView(url: activity.user.avatarURL)
//                    .frame(width: 48, height: 48)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(activity.user.name) ")
                        .font(.callout)
                        .fontWeight(.semibold)
                    + Text(activity.type == .liked ? "liked your post" : "followed you")
                        .font(.callout)
                    
                    Text("2m")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
