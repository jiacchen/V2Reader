//
//  AvatarView.swift
//  V2Reeder
//
//  Created by Jiachen Chen on 1/10/22.
//

import SwiftUI

struct AvatarView: View {
    var url: String?
    
    var body: some View {
        if let avatarURL = url {
            if avatarURL == "" {
                Image(systemName: "star.square.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.accentColor)
            } else {
                AsyncImage(url: URL(string: avatarURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .cornerRadius(10)
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
