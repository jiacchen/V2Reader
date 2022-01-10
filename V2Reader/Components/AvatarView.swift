//
//  AvatarView.swift
//  Social
//
//  Created by Jordan Singer on 12/27/21.
//

import SwiftUI

struct AvatarView: View {
    var url: String?
    
    var body: some View {
        if let avatarURL = url {
            if avatarURL == "" {
                Image(systemName: "house.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.accentColor)
            } else {
                AsyncImage(url: URL(string: avatarURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .mask(Circle())
                } placeholder: {
                    Image(systemName: "circle")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(Color(UIColor.systemFill))
                }
            }
        } else {
            Image(systemName: "circle")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(Color(UIColor.systemFill))
        }
    }
}

struct AvatarView_Previews: PreviewProvider {
    static var previews: some View {
        AvatarView()
    }
}
