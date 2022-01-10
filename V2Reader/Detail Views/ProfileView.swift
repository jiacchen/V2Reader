//
//  ProfileView.swift
//  Social
//
//  Created by Jordan Singer on 12/27/21.
//

import SwiftUI

struct ProfileView: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    @EnvironmentObject var data: AppData
    @EnvironmentObject var member: Member
    @State var following = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                VStack(spacing: 24) {
                    VStack(spacing: 16) {
                        AvatarView(url: member.avatar)
                            .frame(width: 120, height: 120)
                        
                        VStack(spacing: 4) {
                            Text(member.username)
                                .font(.title2)
                                .fontWeight(.semibold)
//                            Text("@\(user.username)")
//                                .foregroundColor(.secondary)
                        }
                    }
                    
//                    Button(action: { following = true }) {
//                        HStack {
//                            Spacer()
//                            Text("Follow")
//                                .font(.headline)
//                            Spacer()
//                        }
//                    }
//                    .buttonStyle(.borderedProminent)
//                    .disabled(following)
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 16) {
                            if sizeClass == .compact {
                                VStack(alignment: .leading, spacing: 16) {
                                    Text("V2EX 第 ")
                                        .foregroundColor(.secondary)
                                    + Text(String(member.id))
                                        .fontWeight(.semibold)
                                    + Text(" 号会员")
                                        .foregroundColor(.secondary)
                                    
                                    Text("加入于 ")
                                        .foregroundColor(.secondary)
                                    + Text(member.created)
                                        .fontWeight(.semibold)
                                }
                            } else {
                                HStack(spacing: 16) {
                                    Text("V2EX 第 ")
                                        .foregroundColor(.secondary)
                                    + Text(String(member.id))
                                        .fontWeight(.semibold)
                                    + Text(" 号会员")
                                        .foregroundColor(.secondary)
                                    
                                    Text("加入于 ")
                                        .foregroundColor(.secondary)
                                    + Text(member.created)
                                        .fontWeight(.semibold)
                                }
                            }
                            
                            if let bio = member.bio {
                                Text(bio)
                            }
                            
                            if member.website != nil || member.github != nil {
                                HStack(spacing: 24) {
                                    if let website = member.website {
                                        Link(destination: URL(string: website)!) {
                                            Label(website.replacingOccurrences(of: "https://", with: ""), systemImage: "safari.fill")
                                        }
                                    }
                                    
                                    if let github = member.github {
                                        Link(destination: URL(string: "https://github.com/" + github)!) {
                                            Label(github, systemImage: "chevron.left.forwardslash.chevron.right")
                                        }
                                    }
                                }
                            }
                        }
                        Spacer()
                    }
                    .font(.callout)
                    .padding(.vertical, 4)
                }
                .padding(.horizontal, sizeClass == .compact ? nil : 32)
                .padding(.top, 32)
                .padding(.bottom, 20)
            
                
//                Divider()
//                
//                VStack(spacing: 0) {
//                    ForEach(data.getPostsByUserID(user.id), id: \.id) { post in
//                        PostCardView()
//                            .environmentObject(post)
//                    }
//                }
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: share) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.headline)
                }
            }
        }
    }
    
    func share() {
        let activityVC = UIActivityViewController(activityItems: [member.username], applicationActivities: nil)
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        windowScene.keyWindow?.rootViewController?.present(activityVC, animated: true, completion: nil)
   }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
