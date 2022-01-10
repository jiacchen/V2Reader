//
//  NewPostView.swift
//  Social
//
//  Created by Jordan Singer on 12/27/21.
//

import SwiftUI

struct NewPostView: View {
    @EnvironmentObject var data: AppData
    @Environment(\.presentationMode) var presentationMode
    @State private var content = ""
    @FocusState private var focusedField: Field?
    enum Field: Hashable {
        case content
    }
    var isReply = false
    @State var loading = false
    
    var body: some View {
        NavigationView {
            VStack {
                HStack(alignment: .top) {
//                    AvatarView(url: data.currentUser.avatarURL)
//                        .frame(width: 48, height: 48)
                    
                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $content)
                            .focused($focusedField, equals: .content)
                            .padding(.top, 8)
                        
                        if content == "" {
                            Text("What's happening?")
                                .foregroundColor(.secondary)
                                .padding(.top, 16)
                                .padding(.leading, 4)
                        }
                    }
                }
            }
            .padding()
            .navigationTitle("New")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Text("Cancel")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { newPost() }) {
                        if loading {
                            ProgressView()
                        } else {
                            Text(isReply ? "Reply" : "Post")
                                .fontWeight(.semibold)
                        }
                    }
                    .disabled(content == "")
                }
            }
        }
        .task {
            autofocus()
        }
    }
    
    func autofocus() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.focusedField = .content
        }
    }
    
    func newPost() {
        self.loading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            presentationMode.wrappedValue.dismiss()
        }
    }
}

struct NewPostView_Previews: PreviewProvider {
    static var previews: some View {
        NewPostView()
    }
}
