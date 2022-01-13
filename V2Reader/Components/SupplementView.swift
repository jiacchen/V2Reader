//
//  SupplementView.swift
//  V2Reeder
//
//  Created by Jiachen Chen on 1/10/22.
//

import SwiftUI

struct SupplementView: View {
    @EnvironmentObject var topic: Topic
    @EnvironmentObject var supplement: Supplement
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(0..<supplement.content_rendered.count) { index in
                    Text(supplement.content_rendered[index])
                    if index < supplement.imageURL.count {
                        AsyncImage(url: URL(string: supplement.imageURL[index]), scale: 2) { phase in
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
                
                HStack(spacing: 32) {
                    HStack {
                        Image(systemName: "clock")
                        Text(supplement.formattedDate())
                    }
                    Spacer()
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.top, 8)
            }
        }
        .padding(.vertical)
        .contentShape(Rectangle())
    }
}

struct SupplementView_Previews: PreviewProvider {
    static var previews: some View {
        SupplementView()
    }
}
