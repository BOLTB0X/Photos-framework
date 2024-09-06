//
//  PhotosYearsView.swift
//  Photos-Framework
//
//  Created by KyungHeon Lee on 2024/09/06.
//

import SwiftUI

// MARK: - PhotosYearsView
struct PhotosYearsView: View {
    // MARK: Object
    @EnvironmentObject var environmentObj: PhotosImageViewmodel
    
    // MARK: Binding
    @Binding var selectedTab: Tab
    
    // MARK: - View
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    ForEach(environmentObj.getSortedYears(), id: \.self) { year in
                        HStack {
                            Text("\(year)년")
                                .font(.largeTitle)
                                .bold()
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        displayYearsDicts(yearsDicts: environmentObj.yearsDicts, year: year)
                    }
                }
                .padding(.vertical)
            } // ScrollView
            .onAppear {
                if let lastYear = environmentObj.getSortedYears().last {
                    withAnimation {
                        proxy.scrollTo(lastYear, anchor: .bottom)
                    }
                }
            } // ScrollViewReader
        }
    } // body
}

// MARK: - Extension View Builder
extension PhotosYearsView {
    @ViewBuilder
    private func displayYearsDicts(yearsDicts: [Int: [PhotosImage]], year: Int) -> some View {
        if let photos = yearsDicts[year], !photos.isEmpty {
            if photos.count == 1 {
                PhotosCell(photo: photos.first!, width: 280, height: 200, type: 0)
                    .onTapGesture {
                        environmentObj.selected = photos.first
                        selectedTab = .total
                        
                    }
                    .padding(.horizontal)
                
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .center, spacing: 5) {
                        ForEach(photos, id: \.id) { photo in
                            PhotosCell(photo: photo, width: 140, height: 200, type: 0)
                                .onTapGesture {
                                    environmentObj.selected = photo
                                    selectedTab = .total
                                }
                        }
                    }
                }
                .padding(.horizontal)
                
            } // if - else
        } // if let
    } // displayYearsDicts
}
