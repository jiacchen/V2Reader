//
//  PostReactionsBarView.swift
//  V2Reeder
//
//  Created by Jiachen Chen on 1/10/22.
//

import SwiftUI

struct FooterView: View {
    @EnvironmentObject var topic: Topic
    @State var liked = false
    var fullWidth = false
    
    var body: some View {
        HStack(spacing: 32) {
            HStack {
               Image(systemName: "bubble.right")
                Text("\(topic.replies)")
            }
            HStack {
                Image(systemName: "clock")
                Text(fullWidth ? topic.formattedCreatedDate() : topic.formattedDate())
            }
            Spacer()
        }
#if targetEnvironment(macCatalyst)
        .font(.body)
#else
        .font(.subheadline)
#endif
        .foregroundColor(.secondary)
        .padding(.top, 8)
    }
}
