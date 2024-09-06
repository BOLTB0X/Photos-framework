//
//  CompactCell.swift
//  Photos-Framework
//
//  Created by KyungHeon Lee on 2024/09/04.
//

import SwiftUI

// MARK: - CompactCell
struct CompactCell: View {
    // MARK: Binding
    @Binding var selected: PhotosImage?
    @Binding var isShowDetail: Bool
    @Binding var isPinching: Bool
    @Binding var isEdit: Bool
    
    // MARK: Property
    let photo: PhotosImage
    let animation: Namespace.ID
    let itemSize: CGFloat
    
    var action: () -> Void
    
    var body: some View {
        stateImageByEdit()
    } // body
}

extension CompactCell {
    // MARK: - cellImage
    @ViewBuilder
    private func cellImage() -> some View {
        Image(uiImage: photo.image)
            .resizable()
            .matchedGeometryEffect(id: photo.id, in: animation)
            .aspectRatio(contentMode: .fill)
            .frame(width: itemSize, height: itemSize)
            .clipped()
            .cornerRadius(8)
    } // cellImage
    
    // MARK: - stateImageByPinch
    @ViewBuilder
    private func stateImageByPinch() -> some View {
        if isPinching {
            cellImage()
        } else {
            Button(action: {
                withAnimation(.interactiveSpring(response: 0.6, dampingFraction: 0.85, blendDuration: 0.25)) {
                    selected = photo
                    isShowDetail.toggle()
                }
            }, label: {
                cellImage()
            })
        } // if - else
    } // stateImageByPinch
    
    // MARK: - stateImageByEdit
    @ViewBuilder
    private func stateImageByEdit() -> some View {
        if isEdit {
            Button(action: {
                action()
            }, label: {
                ZStack {
                    cellImage()
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            if photo.isSelected {
                                Image(systemName: "checkmark.circle")
                            }
                        }
                    }
                } // ZStack
            })
            
        } else {
            stateImageByPinch()
        } // if - else
    } // stateImageByEdit
    
}

