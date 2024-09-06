//
//  LazyVGrid.swift
//  Photos-Framework
//
//  Created by KyungHeon Lee on 2024/09/04.
//

import SwiftUI

struct CustomLazyVGridView: View {
    // MARK: Object
    @EnvironmentObject var environmentObj: PhotosImageViewmodel
    
    // MARK: Binding
    @Binding var isShowDetail: Bool
    @Binding var isAction: Bool
    
    // MARK: Property
    let animation: Namespace.ID
    
    // MARK: AppStorage
    // 컬럼 유지를 위해
    @AppStorage("gridSize") private var size: Double = 100.0
    @AppStorage("currentZoomStageIndex") private var currentZoomStageIndex: Int = 2
    
    // MARK: State
    // ...
    // 제스처 관련 프로퍼티
    @State private var isPinching: Bool = false
    @State private var scale: CGFloat = 1.0
    @State private var scaleFactor: CGFloat = 1.0
    @State private var zoomFactor: CGFloat = 1.0
    @State private var isMagnifying = false
    @State private var previousZoomStageUpdateState: CGFloat = 0
    @State private var adjustedState: CGFloat = 0
    @State private var gridWidth: CGFloat = 0
    @State private var zooming: Bool = false
    
    // 편집 관련
    @State private var isEdit: Bool = false
    
    // MARK: - View
    var body: some View {
        ScrollViewReader { scrollProxy in
            ScrollView {
                let columns = [
                    GridItem(.adaptive(minimum: CGFloat(size)), spacing: 2)
                ]
                
                LazyVGrid(columns: columns, spacing: 2) {
                    forEachEmptyCell()
                    
                    forEachPhotoCell(photosArr: environmentObj.photosArr) { photo in
                        CompactCell(
                            selected: $environmentObj.selected,
                            isShowDetail: $isShowDetail,
                            isPinching: $isPinching,
                            isEdit: $isEdit,
                            photo: photo,
                            animation: animation,
                            itemSize: CGFloat(size),
                            action: { environmentObj.toggleSelectedPhoto(photo) }
                        )
                    }
                } // LazyVGrid
                .padding(.vertical, 10)
                .scrollDisabled(zooming)
                .scaleEffect(scale)
                .gesture(magnificationGesture)
                .background(
                    GeometryReader { proxy in
                        Color.clear
                            .onAppear {
                                gridWidth = proxy.frame(in: .local).width
                                calculateZoomFactor(at: currentZoomStageIndex)
                            }
                    }
                )
                .onChange(of: isEdit) { _ in
                    if !isEdit { environmentObj.clearSelectedPhto() }
                }
                
                .onChange(of: environmentObj.selected) { selectedPhoto in
                    moveScrollToSelectedPhoto(
                        photosArr: environmentObj.photosArr,
                        selected: selectedPhoto,
                        scrollProxy: scrollProxy,
                        action: { environmentObj.initializeSelectedPhotoInTotal() }
                    )
                }
                .onAppear {
                    moveScrollToSelectedPhoto(
                        photosArr: environmentObj.photosArr,
                        selected: environmentObj.selected,
                        scrollProxy: scrollProxy,
                        action: { environmentObj.initializeSelectedPhotoInTotal() }
                    )
                    //print("\(environmentObj.selected?.id ?? "없음")")
                }
            } // ScrollView
            
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("보관함")
                            .font(.title)
                            .bold()
                        Text("\(environmentObj.photosArr.count)장의 사진")
                            .font(.title2)
                            .bold()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        isEdit.toggle()
                        isPinching = false
                        
                    }, label: {
                        Text(isEdit ? "취소" : "선택")
                            .font(.subheadline)
                    })
                    .buttonStyle(.bordered)
                    .padding()
                }
                
                if isEdit {
                    ToolbarItem(placement: .bottomBar) {
                        HStack(alignment: .center, spacing: 0) {
                            Text("block")
                                .foregroundColor(.clear)
                            
                            Text(
                                environmentObj.selectedPhotos.count == 0 ?
                                "항목 선택" : "\(environmentObj.selectedPhotos.count)장의 사진이 선택 됨"
                            )
                            .font(.subheadline)
                            
                            Text("block")
                                .foregroundColor(.clear)
                            
                            Text("block")
                                .foregroundColor(.clear)
                            
                            Button(action: {
                                isAction = environmentObj.selectedPhotos.count > 0 ? true : false
                            }, label: {
                                Image(systemName: "trash.circle.fill")
                                    .foregroundColor(environmentObj.selectedPhotos.count > 0 ? .blue : .white)
                            })
                            
                        }
                    }
                } // if
            } // toolbar
        } // ScrollViewReader
        .onTapGesture {
            isPinching.toggle()
        }
    } // body
}

extension CustomLazyVGridView {
    // MARK: - forEachEmptyCell
    @ViewBuilder
    private func forEachEmptyCell() -> some View {
        let totalCells = calculateTotalCells()
        let emptyCellsCount = totalCells - environmentObj.photosArr.count
        
        ForEach(0..<emptyCellsCount, id: \.self) { _ in
            RoundedRectangle(cornerRadius: 8)
                .frame(height: size)
                .foregroundColor(.black)
            
        }
    } // forEachEmptyCell
    
    // MARK: - forEachPhotoCell
    @ViewBuilder
    private func forEachPhotoCell<Content: View>(
        photosArr: [PhotosImage],
        @ViewBuilder content: @escaping (PhotosImage) -> Content
    ) -> some View {
        ForEach(photosArr.indices, id: \.self) { idx in
            let photo = photosArr[idx]
            content(photo)
                .frame(width: CGFloat(size), height: CGFloat(size))
                .aspectRatio(contentMode: .fit)
                .padding(.horizontal, 2)
                .id(idx)
        }
    } // forEachPhotoCell
}

extension CustomLazyVGridView {
    // MARK: - magnificationGesture
    private var magnificationGesture: some Gesture {
        MagnificationGesture()
            .onChanged { state in
                var adjustedState = state - previousZoomStageUpdateState
                
                zooming = true
                
                if scale <= 1, adjustedState < 1 { // in
                    isMagnifying = false
                    if currentZoomStageIndex > PhotosImage.zoomStages.count - 1 {
                        if adjustedState > 0.95 {
                            scale = scaleFactor - (1 - adjustedState)
                        } else {
                            adjustedState = 0.95
                        }
                    } else {
                        let updatedSize = calculateUpdatedSize(index: currentZoomStageIndex + 1)
                        
                        previousZoomStageUpdateState = state - 1
                        
                        zoomFactor = updatedSize / size
                        scaleFactor = size / updatedSize
                        scale = scaleFactor
                        size = updatedSize
                        currentZoomStageIndex += 1
                    }
                } else if scale >= zoomFactor, adjustedState > 1 { // out
                    isMagnifying = true
                    if currentZoomStageIndex == 0 {
                        if adjustedState < 1.1 {
                            scale = 1 - (1 - adjustedState)
                        } else {
                            adjustedState = 1.1
                        }
                    } else {
                        currentZoomStageIndex -= 1
                        previousZoomStageUpdateState = state - 1
                        
                        calculateZoomFactor(at: currentZoomStageIndex)
                        scaleFactor = 1
                        scale = 1
                    }
                } else {
                    if isMagnifying {
                        scale = 1 - (1 - adjustedState)
                    } else {
                        scale = scaleFactor - (1 - adjustedState)
                    }
                }
                
                adjustedState = adjustedState
            }
            .onEnded { _ in
                let shouldMagnify = adjustedState > 1
                let animationDuration = 0.25
                
                withAnimation(.linear(duration: animationDuration)) {
                    if shouldMagnify {
                        scale = zoomFactor
                    } else {
                        resetZoomVariables()
                    }
                    
                    //isPinching = false
                }
                
                if shouldMagnify {
                    DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
                        if currentZoomStageIndex > 0 {
                            currentZoomStageIndex -= 1
                        }
                        
                        resetZoomVariables()
                    }
                }
            }
    } // magnificationGesture
}

// MARK: - Extension Methods
extension CustomLazyVGridView {
    // MARK: - resetZoomVariables
    private func resetZoomVariables() {
        calculateZoomFactor(at: currentZoomStageIndex)
        zooming = false
        scale = 1
        scaleFactor = 1
        previousZoomStageUpdateState = 0
        adjustedState = 0
    }
    
    // MARK: - calculateZoomFactor
    private func calculateZoomFactor(at index: Int) {
        let currentSize = calculateUpdatedSize(index: index)
        let magnifiedSize = calculateUpdatedSize(index: index - 1)
        
        zoomFactor = magnifiedSize / currentSize
        size = currentSize
    } // calculateZoomFactor
    
    // MARK: - calculateZoomFactor
    private func calculateUpdatedSize(index: Int) -> CGFloat {
        let zoomStages = PhotosImage.getZoomStage(at: index)
        let availableSpace = gridWidth - (2 * CGFloat(zoomStages))
        return availableSpace / CGFloat(zoomStages)
    } // calculateZoomFactor
    
    // MARK: - moveScrollToSelectedPhoto
    // 스크롤 이동 메서드
    private func moveScrollToSelectedPhoto(photosArr: [PhotosImage], selected: PhotosImage?, scrollProxy: ScrollViewProxy, action: @escaping () -> Void) {
        if let selectedPhoto = selected,
           let idx = photosArr.firstIndex(where: { $0.id == selectedPhoto.id }) {
            
            withAnimation {
                let photosPerRow = currentZoomStageIndex <= PhotosImage.getMaxZoomStageIndex() ? PhotosImage.zoomStages[currentZoomStageIndex] : PhotosImage.zoomStages.last!
                
                let totalRows = (photosArr.count + photosPerRow - 1) / photosPerRow
                
                let isLastRow = (idx / photosPerRow) == (totalRows - 1)
                
                scrollProxy.scrollTo(idx, anchor: isLastRow ? .bottom : .center)
            }
        } else {
            action()
        }
    } // moveScrollToSelectedPhoto
    
    // MARK: - calculateTotalCells
    private func calculateTotalCells() -> Int {
        let zoomStages = PhotosImage.getZoomStage(at: currentZoomStageIndex)
        let totalCells = (environmentObj.photosArr.count + zoomStages - 1) / zoomStages * zoomStages
        return totalCells
    } // calculateTotalCells
}
