//
//  PostReactionsBarView.swift
//  Social
//
//  Created by Jordan Singer on 12/26/21.
//

import SwiftUI

struct PostReactionsBarView: View {
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
            
//            if fullWidth {
//                Button(action: share) {
//                    HStack {
//                       Image(systemName: "square.and.arrow.up")
//                    }
//                }
//            }
        }
        .font(.subheadline)
        .foregroundColor(.secondary)
        .padding(.top, 8)
    }
    
    func share() {
        let activityVC = UIActivityViewController(activityItems: [topic.title, URL(string: topic.url)!], applicationActivities: nil)
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        windowScene.keyWindow?.rootViewController?.present(activityVC, animated: true, completion: nil)
   }
}

struct PostReactionsBarView_Previews: PreviewProvider {
    static var previews: some View {
        PostReactionsBarView()
    }
}
