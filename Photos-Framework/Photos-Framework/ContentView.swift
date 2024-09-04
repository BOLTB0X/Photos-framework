//
//  ContentView.swift
//  Photos-Framework
//
//  Created by KyungHeon Lee on 2024/09/04.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewmodel = PhotosImageViewmodel()
    
    var body: some View {
        PhotosImageView()
            .environmentObject(viewmodel)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
