//
//  HorizontalScroll.swift
//  Photos-Framework
//
//  Created by KyungHeon Lee on 2024/09/04.
//

import SwiftUI

// MARK: - HorizontalScroll
struct HorizontalScroll: View {
    // MARK: Binding
    @Binding var currentIndex: Int
    @Binding var photosArr: [PhotosImage]
    @Binding var selected: PhotosImage?
    @Binding var zooming: Bool
    
    // MARK: - View
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 3) {
                    ForEach(0..<photosArr.count, id: \.self) { idx in
                        Image(uiImage: photosArr[idx].image)
                            .resizable()
                            .frame(width: currentIndex == idx ? 50 : 40, height: currentIndex == idx ? 80 : 60)
                            .scaleEffect(currentIndex == idx ? 1.2 : 1.0)
                            .aspectRatio(contentMode: .fit)
                            .onTapGesture {
                                currentIndex = idx
                                withAnimation {
                                    proxy.scrollTo(idx, anchor: .center)
                                }
                                selected = photosArr[currentIndex]
                            }
                            .id(idx)
                    }
                } // HStack
            } // ScrollView
            
            .onChange(of: currentIndex) { newValue in
                withAnimation {
                    proxy.scrollTo(newValue, anchor: .center)
                }
            }
        } // ScrollViewReader
    } // body
}
