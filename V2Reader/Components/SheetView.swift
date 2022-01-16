//
//  SheetView.swift
//  V2Reeder
//
//  Created by Jiachen Chen on 1/10/22.
//

import SwiftUI

struct SheetView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var data: AppData
    @State var searchText = ""
    @State var showingAlert = false
    @Binding var editMode: EditMode
    @Binding var homeChanged: Bool
    @Binding var edited: Bool
    @Binding var showNodeManagement: Bool
    @ObservedObject var nodeCollectionFetcher: NodeCollectionFetcher
    
    var body: some View {
        NavigationView {
            if data.fetching {
                ProgressView()
            } else {
                List {
                    Section {
                        ForEach(homeResults, id: \.self) { name in
                            HStack {
                                Text(nodeCollectionFetcher.nodeCollectionData[name]?.title ?? data.allNodes[name]!)
                                Spacer()
                                Image(systemName: "star.fill")
                                    .foregroundColor(Color.accentColor)
                                    .onTapGesture {
                                        withAnimation {
                                            data.removeFromHome(name: name)
                                            homeChanged = true
                                        }
                                    }
                            }
                        }
                    } header: {
                        Text("Home")
                    }
                    Section {
                        ForEach(pinnedResults, id: \.self) { name in
                            HStack {
                                Text(nodeCollectionFetcher.nodeCollectionData[name]?.title ?? data.allNodes[name]!)
                                Spacer()
                                if data.homeNodes.contains(name) {
                                    Image(systemName: "star.fill")
                                        .foregroundColor(Color.accentColor)
                                        .onTapGesture {
                                            withAnimation {
                                                data.removeFromHome(name: name)
                                                homeChanged = true
                                            }
                                        }
                                } else {
                                    Image(systemName: "star.fill")
                                        .foregroundColor(Color(UIColor.systemFill))
                                        .onTapGesture {
                                            if data.homeNodes.count >= 5 {
                                                showingAlert = true
                                            } else {
                                                withAnimation {
                                                    data.addToHome(name: name)
                                                    homeChanged = true
                                                }
                                            }
                                        }
                                        .alert("You can select up to 5 nodes for the home feed.", isPresented: $showingAlert) {
                                            Button("OK", role: .cancel) {}
                                        }
                                }
                            }
                        }
                        .onDelete { offsets in
                            withAnimation {
                                data.removeNode(offsets: offsets)
                                edited = true
                            }
                        }
                        .onMove { offsets, dest in
                            withAnimation {
                                data.pinnedNodes.move(fromOffsets: offsets, toOffset: dest)
                                edited = true
                            }
                        }
                    } header: {
                        Text("Pinned")
                    }
                    
                    Section {
                        ForEach(allResults.sorted(by: { elem1, elem2 in
                            return elem1.key < elem2.key
                        }), id: \.0) { name, title in
                            if !data.pinnedNodes.contains(name) {
                                HStack {
                                    Text(title)
                                        .foregroundColor(Color.primary)
                                    Spacer()
                                    Image(systemName: "plus")
                                        .foregroundColor(Color.secondary)
                                        .onTapGesture {
                                            withAnimation {
                                                data.addNode(name: name)
                                                edited = true
                                            }
                                        }
                                }
                            }
                        }
                    } header: {
                        Text("All")
                    }
                }
                .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search")
                .task {
                    if !data.fetching {
                        try? await data.getAllNodes(refresh: false)
                    }
                }
                .navigationBarTitle(Text("Nodes"), displayMode: .inline)
                .navigationBarItems(trailing: Button(action: {
                    if editMode == EditMode.inactive {
                        showNodeManagement = false
                    }
                }, label: {
                    if editMode == EditMode.inactive {
                        Text("Done")
                            .fontWeight(.semibold)
                    }
                }))
                .navigationBarItems(leading: Button {
                    if editMode == EditMode.active {
                        editMode = EditMode.inactive
                    } else {
                        editMode = EditMode.active
                    }
                } label: {
                    if editMode == EditMode.active {
                        Text("Done")
                            .fontWeight(.semibold)
                    } else {
                        Text("Edit")
                    }
                })
                .environment(\.editMode, $editMode)
            }
        }
    }
    
    var homeResults: [String] {
        if searchText.isEmpty {
            return data.homeNodes
        } else {
            return data.homeNodes.filter { $0.localizedCaseInsensitiveContains(searchText) || data.allNodes[$0]!.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var pinnedResults: [String] {
        if searchText.isEmpty {
            return data.pinnedNodes
        } else {
            return data.pinnedNodes.filter { $0.localizedCaseInsensitiveContains(searchText) || data.allNodes[$0]!.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var allResults: [String: String] {
        if searchText.isEmpty {
            return data.allNodes
        } else {
            return data.allNodes.filter { $0.1.localizedCaseInsensitiveContains(searchText) || $0.0.localizedCaseInsensitiveContains(searchText) }
        }
    }
}

struct SheetView_Previews: PreviewProvider {
    static var previews: some View {
        SheetView(editMode: .constant(EditMode.inactive), homeChanged: .constant(false), edited: .constant(false), showNodeManagement: .constant(false), nodeCollectionFetcher: NodeCollectionFetcher())
    }
}
