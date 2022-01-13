//
//  ActivityView.swift
//  V2Reeder
//
//  Created by Jiachen Chen on 1/10/22.
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
