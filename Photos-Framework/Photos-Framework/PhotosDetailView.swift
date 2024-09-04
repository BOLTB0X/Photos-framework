//
//  PhotosDetailView.swift
//  Photos-Framework
//
//  Created by KyungHeon Lee on 2024/09/04.
//

import SwiftUI

// MARK: - PhotosDetailView
struct PhotosDetailView: View {
    // MARK: Object
    @EnvironmentObject var environmentObj: PhotosImageViewmodel
    
    // MARK: State
    // 줌 관련 프로퍼티
    @State private var isZoom: Bool = false
    @State private var screenW = 0.0
    @State private var scale = 1.0
    @State private var lastScale = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @State private var zooming: Bool = false
    @State private var currentPhotoIndex: Int = 0
    
    // MARK: Binding
    // 메인 뷰와 바인딩되어 있는 프로퍼티
    @Binding var isShowingDetail: Bool
    @Binding var isAction: Bool
    
    let animation: Namespace.ID
    
    // MARK: - View
    var body: some View {
        GeometryReader { geometry in
            VStack {
                if let photo = environmentObj.selected {
                    Image(uiImage: photo.image)
                        .resizable()
                        .matchedGeometryEffect(id: photo.id, in: animation, anchor: .center)
                        .scaleEffect(scale)
                        .offset(offset)
                        .scaledToFill()
                        .aspectRatio(contentMode: isZoom ? .fill : .fit)
                        .frame(maxWidth: isZoom ? .infinity : geometry.size.width,
                               maxHeight: isZoom ? .infinity : geometry.size.height)
                    
                        .onTapGesture(count: 2) { location in
                            handleDoubleTap(location: location, geometry: geometry)
                        }
                    
                        .gesture(
                            magnificationGesture(geometry: geometry, photo: photo)
                        )
                    
                        .onAppear {
                            screenW = geometry.size.width
                            currentPhotoIndex = environmentObj.photosArr.firstIndex(where: { $0.id == photo.id }) ?? 0
                        }
                }
                
                if !zooming {
                    HorizontalScroll(
                        currentIndex: $currentPhotoIndex,
                        photosArr: $environmentObj.photosArr,
                        selected: $environmentObj.selected,
                        zooming: $zooming
                    )
                    .padding(.bottom)
                }
                
            } // VStack
            
            .onChange(of: environmentObj.photosArr) { photosArr in
                if photosArr.isEmpty {
                    isShowingDetail.toggle()
                }
            }
            
        } // GeometryReader
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                if let photo = environmentObj.selected {
                    VStack(alignment: .leading) {
                        Text(photo.creationDate?.formattedYMD() ?? "날짜 확인 불가")
                            .font(.headline)
                            .bold()
                        Text(photo.creationDate?.formattedHM() ?? "시간 확인 불가" )
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    Button(action: {
                        toggleFavorite(selected: environmentObj.selected)
                        environmentObj.selected?.isFavorite.toggle()
                    }, label: {
                        Image(systemName: (environmentObj.selected?.isFavorite == true ? "heart.fill" : "heart") )
                    })
                    
                    Button(action: {
                        withAnimation(.interactiveSpring(response: 0.6, dampingFraction: 0.85, blendDuration: 0.25)) {
                            isShowingDetail.toggle()
                        }
                    }, label: {
                        Image(systemName: "xmark.circle.fill")
                    })
                } // HStack
            }
            
            ToolbarItem(placement: .bottomBar) {
                HStack {
                    Rectangle()
                        .foregroundColor(.clear)
                    
                    Button(action: {
                        isAction = true
                    }, label: {
                        Image(systemName: "trash.circle.fill")
                    })
                }
            }
        }
        
    } // body
    
}

// MARK: - Extension Method
extension PhotosDetailView {
    
    // MARK: - magnificationGesture
    private func magnificationGesture(geometry: GeometryProxy, photo: PhotosImage) -> some Gesture {
        MagnificationGesture()
            .onChanged { value in
                zooming = true
                withAnimation(.interactiveSpring()) {
                    scale = max(lastScale * value, 1.0)
                }
            }
            .onEnded { value in
                zooming = false
                lastScale = scale
            }
            .simultaneously(
                with: DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        withAnimation(.interactiveSpring()) {
                            offset = CGSize(
                                width: value.translation.width + lastOffset.width,
                                height: value.translation.height + lastOffset.height
                            )
                        }
                    } // onChanged
                    .onEnded { value in
                        lastOffset = offset
                        if !zooming {
                            if abs(value.translation.height) > geometry.size.height / 3 {
                                withAnimation(.interactiveSpring(response: 0.6, dampingFraction: 0.85, blendDuration: 0.25)) {
                                    isShowingDetail.toggle()
                                }
                            } else {
                                withAnimation(.interactiveSpring()) {
                                    offset = .zero
                                }
                            }
                            
                            if value.translation.width > 50 { // r
                                if let currentIndex = environmentObj.photosArr.firstIndex(where: { $0.id == photo.id }), currentIndex > 0 {
                                    environmentObj.selected = environmentObj.photosArr[currentIndex - 1]
                                    currentPhotoIndex = currentIndex - 1
                                }
                            } else if value.translation.width < -50 { // l
                                if let currentIndex = environmentObj.photosArr.firstIndex(where: { $0.id == photo.id }), currentIndex < environmentObj.photosArr.count - 1 {
                                    environmentObj.selected = environmentObj.photosArr[currentIndex + 1]
                                    currentPhotoIndex = currentIndex + 1
                                }
                            }
                        }
                    } // onEnded
            )
    } // magnificationGesture
    
    // MARK: - Handle Double Tap
    private func handleDoubleTap(location: CGPoint, geometry: GeometryProxy) {
        let touchLocation = CGPoint(x: location.x, y: location.y)
        let centerX = geometry.size.width / 2
        let centerY = geometry.size.height / 2
        zooming.toggle()
        
        withAnimation {
            if scale == 1.0 {
                isZoom = true
                scale = 2.0
                offset = CGSize(
                    width: (centerX - touchLocation.x) * (scale - 1),
                    height: (centerY - touchLocation.y) * (scale - 1)
                )
            } else {
                isZoom = false
                scale = 1.0
                offset = .zero
            }
            lastScale = scale
        }
    } // handleDoubleTap
    
    // MARK: - toggleFavorite
    private func toggleFavorite(selected: PhotosImage?) {
        guard let photo = selected else {
            return
        }
        
        if let idx = environmentObj.photosArr.firstIndex(of: photo) {
            environmentObj.photosArr[idx].isFavorite.toggle()
        }
    }
}

extension Date {
    // MARK: - formattedYMD
    func formattedYMD() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월 d일"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: self)
    }
    
    // MARK: - formattedMD
    func formattedMD() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M월 d일"
        return dateFormatter.string(from: self)
    }
    
    // MARK: - formattedHM
    func formattedHM() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h시 m분"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: self)
    }
    
    // MARK: - formattedDay
    func formattedDay() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d일"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: self)
    }
}

//struct PhotosDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        PhotosDetailView()
//    }
//}
