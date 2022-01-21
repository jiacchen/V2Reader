//
//  TokenView.swift
//  V2Reader
//
//  Created by Jiachen Chen on 1/20/22.
//

import SwiftUI

struct TokenView: View {
    @EnvironmentObject var data: AppData
    @State var tokenEntered = ""
    @ObservedObject var tokenFetcher: TokenFetcher
    
    var body: some View {
        ProgressView()
            .sheet(isPresented: $data.completedLoading) {
                NavigationView {
                    VStack(alignment: .leading) {
                        Text("A **Personal Access Token** is required to access the V2EX API 2.0 Beta.")
                            .padding()
                        Text("Please follow the instruction on the [website](https://www.v2ex.com/help/personal-access-token) to create a token and enter it in the field below.")
                            .padding()
                        Text("The token you entered will be stored securely in the keychain.")
                            .padding()
                        HStack {
                            SecureField(text: $tokenEntered) {
                                Text("Token...")
                            }
                            .submitLabel(.done)
                            .onSubmit {
                                Task {
                                    try? await tokenFetcher.fetchData(token: tokenEntered)
                                }
                            }
                            .onChange(of: tokenFetcher.completed, perform: { completed in
                                if completed && !tokenFetcher.tokenInvalid {
                                    tokenFetcher.completed = false
                                    try? data.updateToken(token: tokenEntered)
                                }
                            })
                            .alert("Invalid token!\nPlease try again.", isPresented: $tokenFetcher.tokenInvalid) {
                                Button("OK") {
                                    tokenFetcher.completed = false
                                    tokenFetcher.tokenInvalid = false
                                }
                            }
                        }
                        .padding()
                        Spacer()
                    }
                    .padding()
                    .navigationTitle("Token")
                }
                .interactiveDismissDisabled()
            }
    }
}
