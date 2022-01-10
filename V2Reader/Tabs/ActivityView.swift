//
//  ActivityView.swift
//  Social
//
//  Created by Jordan Singer on 12/26/21.
//

import SwiftUI

struct ActivityView: View {
    @EnvironmentObject var data: AppData
    
    var body: some View {
        NavigationView {
            ScrollView {
                EmptyView()
            }
            .navigationTitle("Activity")
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(.stack)
    }
}

struct ActivityView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityView()
    }
}
