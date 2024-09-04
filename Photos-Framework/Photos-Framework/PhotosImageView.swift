//
//  PhotosImageView.swift
//  Photos-Framework
//
//  Created by KyungHeon Lee on 2024/09/04.
//

import SwiftUI

struct PhotosImageView: View {
    // MARK: Object
    @EnvironmentObject var environmentObj: PhotosImageViewmodel
    
    // MARK: Property
    @State private var isShowDetail: Bool = false
    @Namespace var animation
    
    @State private var isAction = false
    
    // MARK: - View
    var body: some View {
        NavigationView {
            ZStack {
                if environmentObj.isLoading {
                    ProgressView()
                }
                
                if isShowDetail {
                    PhotosDetailView(
                        isShowingDetail: $isShowDetail,
                        isAction: $isAction,
                        animation: animation
                    )
                    .environmentObject(environmentObj)
                } else {
                    CustomLazyVGrid(
                        isShowDetail: $isShowDetail,
                        isAction: $isAction,
                        animation: animation
                    )
                    .environmentObject(environmentObj)
                } // if - else
                
            } // ZStack
            .actionSheet(isPresented: $isAction) {
                ActionSheet(
                    title: Text(""),
                    message: Text("이 사진이 모든 기기의 iCloud 사진에서 삭제됩니다. 해당 사진은 '최근 삭제된 항목'에 30일간 보관됩니다."),
                    buttons: [
                        .destructive(Text("사진 삭제")) {
                            environmentObj.deleteSelectedPhotos()
                        },
                        .cancel(Text("취소"))
                    ]
                )
            } // actionSheet
        } // NavigationView
    } // body
}

//struct PhotosImageView_Previews: PreviewProvider {
//    static var previews: some View {
//        PhotosImageView()
//    }
//}
