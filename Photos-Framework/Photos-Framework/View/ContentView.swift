//
//  ContentView.swift
//  Photos-Framework
//
//  Created by KyungHeon Lee on 2024/09/04.
//

import SwiftUI

enum Tab {
    case year, total
}

struct ContentView: View {
    @StateObject private var viewmodel = PhotosImageViewmodel()
    
    @State private var selectedTab: Tab = .total

    var body: some View {
        TabView(selection: $selectedTab) {
            
            PhotosYearsView(selectedTab: $selectedTab)
                .environmentObject(viewmodel)
                .tabItem {
                  Image(systemName: "calendar")
                  Text("년")
                }
                .tag(Tab.year)
            
            PhotosImageView()
                .environmentObject(viewmodel)
                .tabItem {
                  Image(systemName: "photo.stack")
                  Text("전체")
                }
                .tag(Tab.total)

            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
