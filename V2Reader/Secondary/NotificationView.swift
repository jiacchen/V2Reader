//
//  ActivityView.swift
//  V2Reeder
//
//  Created by Jiachen Chen on 1/10/22.
//

import SwiftUI

struct NotificationView: View {
    @EnvironmentObject var data: AppData
    
    var body: some View {
        ScrollView {
            EmptyView()
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
    }
}
