//
//  PhotosCell.swift
//  Photos-Framework
//
//  Created by KyungHeon Lee on 2024/09/06.
//

import SwiftUI

struct PhotosCell: View {
    let photo: PhotosImage
    let width: CGFloat
    let height: CGFloat
    let type: Int
    
    // MARK: - View
    var body: some View {
        ZStack {
            Image(uiImage: photo.image)
                .resizable()
                .frame(width: width, height: height)
                .aspectRatio(contentMode: .fit)
                .cornerRadius(15)
            
            
            if let creationDate = photo.creationDate {
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Text("\(type == 0 ? creationDate.formattedMD() : creationDate.formattedDay())")
                            .foregroundColor(.white)
                            .font(.system(size: 18, weight: .bold))
                            .lineLimit(1)
                        Spacer()
                    }
                    .padding(5)
                    Spacer()
                    
                }
                .frame(width: width, height: height)
            }
        } // ZStack
        .padding(.horizontal, 5)
    } // body
}
