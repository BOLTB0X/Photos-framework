# Photos-framework

![룰루랄라](https://i.pinimg.com/originals/3e/62/51/3e62512faa9cc1424574f3ce22e4c381.gif)

<div style="text-align: center;">
<img src="https://help.apple.com/assets/6716C1FA74E3CF66180BE0A1/6716C1FCC3B14F6AF705E7AC/ko_KR/b27be11281d58d9597fabdfcc67a3060.png" alt="Example Image" width="30%">

Apple 공식 **Photos** 앱 구현(SwiftUI, Photos)

</div>

## Gesture

<p align="center">
  <table style="width:100%; text-align:center; border-spacing:20px;">
    <tr>
      <td style="text-align:center; vertical-align:middle;">
        <p align="center">
        <img src="https://github.com/BOLTB0X/Photos-framework/blob/main/gif/%EB%8D%94%EB%B8%94%ED%83%AD.gif?raw=true" 
             alt="double tap gesture" 
             style="width:200px; height:400px; object-fit:contain;"/>
        </p>
      </td>
      <td style="text-align:center; vertical-align:middle;">
        <p align="center">
        <img src="https://github.com/BOLTB0X/Photos-framework/blob/main/gif/%EB%8D%94%EB%B8%94%ED%83%AD%ED%99%95%EB%8C%80%ED%9B%84%20%EB%93%9C%EB%9E%98%EA%B7%B8.gif?raw=true" 
             alt="Double tap & Drag" 
             style="width:200px; height:400px; object-fit:contain;"/>
        </p>
      </td>
      <td style="text-align:center; vertical-align:middle;">
        <p align="center">
        <img src="https://github.com/BOLTB0X/Photos-framework/blob/main/gif/%EB%8D%94%EB%B8%94%ED%95%80%EC%B9%98.gif?raw=true" 
             alt="Pinch to Zoom" 
             style="width:200px; height:400px; object-fit:contain;"/>
        </p>
      </td>
    </tr>
    <tr>
      <td style="text-align:center; font-size:14px; font-weight:bold;">
      <p align="center">
        Double Tap gestured
      </p>
      </td>
      <td style="text-align:center; font-size:14px; font-weight:bold;">
      <p align="center">
        Double tap & Drag
      </p>
      </td>
      <td style="text-align:center; font-size:14px; font-weight:bold;">
      <p align="center">
        Pinch to Zoom
      </p>
      </td>
    </tr>
  </table>
</p>

- [PhotosDetailView 코드 보기](https://github.com/BOLTB0X/Photos-framework/blob/main/Photos-Framework/Photos-Framework/View/PhotosDetailView.swift)

   <details>
   <summary> Image </summary>
   
   ```swift
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
                    
        .gesture(magnificationGesture(geometry: geometry, photo: photo))
                    
        .onAppear {
            screenW = geometry.size.width
            currentPhotoIndex = environmentObj.photosArr.firstIndex(where: { $0.id == photo.id }) ?? 0
        }
   ```

   </details>

   <details>
   <summary> magnificationGesture </summary>

  ```swift
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
  ```

   </details>

   <details>
   <summary> handleDoubleTap </summary>

  ```swift
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
  ```

   </details>

## Drag

<p align="center">
  <table style="width:100%; text-align:center; border-spacing:20px;">
    <tr>
      <td style="text-align:center; vertical-align:middle;">
        <p align="center">
        <img src="https://github.com/BOLTB0X/Photos-framework/blob/main/gif/%EB%93%9C%EB%9E%98%EA%B7%B8%EB%A1%9C%20%EC%9D%B4%EB%8F%99.gif?raw=true" 
             alt="Drag 스크롤" 
             style="width:200px; height:400px; object-fit:contain;"/>
        </p>
      </td>
      <td style="text-align:center; vertical-align:middle;">
        <p align="center">
        <img src="https://github.com/BOLTB0X/Photos-framework/blob/main/gif/%EB%93%9C%EB%9E%98%EA%B7%B8%EB%A1%9C%20%EB%90%98%EB%8F%8C%EC%95%84%EA%B0%80%EA%B8%B0.gif?raw=true" 
             alt="Double tap & Drag" 
             style="width:200px; height:400px; object-fit:contain;"/>
        </p>
      </td>
    </tr>
    <tr>
      <td style="text-align:center; font-size:14px; font-weight:bold;">
      <p align="center">
        Drag 스크롤
      </p>
      </td>
      <td style="text-align:center; font-size:14px; font-weight:bold;">
      <p align="center">
        Drag 로 되돌아가기
      </p>
      </td>
    </tr>
  </table>
</p>

- [HorizontalScroll 코드 보기](https://github.com/BOLTB0X/Photos-framework/blob/main/Photos-Framework/Photos-Framework/Components/HorizontalScroll.swift)

   <details>
   <summary> ScrollViewReader 이용 </summary>
   
   ```swift
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
   ```

   </details>

## Dynamic Zoom

<p align="center">
  <table style="width:100%; text-align:center; border-spacing:20px;">
    <tr>
      <td style="text-align:center; vertical-align:middle;">
        <p align="center">
        <img src="https://github.com/BOLTB0X/Photos-framework/blob/main/gif/Zoom.gif?raw=true" 
             alt="Zoom" 
             style="width:200px; height:400px; object-fit:contain;"/>
        </p>
      </td>
    </tr>
    <tr>
      <td style="text-align:center; font-size:14px; font-weight:bold;">
      <p align="center">
        Dynamic Zoom
      </p>
      </td>
    </tr>
  </table>
</p>

- [CustomLazyVGridView](https://github.com/BOLTB0X/Photos-framework/blob/main/Photos-Framework/Photos-Framework/View/CustomLazyVGridView.swift)

   <details>
   <summary> magnificationGesture </summary>
   
    ```swift
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
    ```

   </details>

   <details>
   <summary> Zoom 관련 메서드s </summary>

  ```swift
   // MARK: - resetZoomVariables
   private func resetZoomVariables() {
       calculateZoomFactor(at: currentZoomStageIndex)
       zooming = false
       scale = 1
       scaleFactor = 1
       previousZoomStageUpdateState = 0
       adjustedState = 0
  }
  ```

  ```swift
  // MARK: - calculateZoomFactor
  private func calculateZoomFactor(at index: Int) {
       let currentSize = calculateUpdatedSize(index: index)
       let magnifiedSize = calculateUpdatedSize(index: index - 1)

       zoomFactor = magnifiedSize / currentSize
       size = currentSize
  } // calculateZoomFactor
  ```

  ```swift
  // MARK: - calculateZoomFactor
  private func calculateUpdatedSize(index: Int) -> CGFloat {
       let zoomStages = PhotosImage.getZoomStage(at: index)
       let availableSpace = gridWidth - (2 * CGFloat(zoomStages))
       return availableSpace / CGFloat(zoomStages)
  } // calculateZoomFactor
  ```

  ```swift
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
  ```

   </detaiils>

## Update

<p align="center">
  <table style="width:100%; text-align:center; border-spacing:20px;">
    <tr>
      <td style="text-align:center; vertical-align:middle;">
        <p align="center">
        <img src="https://github.com/BOLTB0X/Photos-framework/blob/main/gif/%EC%97%85%EB%8D%B0%EC%9D%B4%ED%8A%B8.gif?raw=true" 
             alt="update" 
             style="width:200px; height:400px; object-fit:contain;"/>
        </p>
      </td>
    </tr>
    <tr>
      <td style="text-align:center; font-size:14px; font-weight:bold;">
      <p align="center">
        Photos 접근 및 업데이트
      </p>
      </td>
    </tr>
  </table>
</p>

- [PhotosImageViewmodel 코드 보기](https://github.com/BOLTB0X/Photos-framework/blob/main/Photos-Framework/Photos-Framework/Model/PhotosImageViewmodel.swift)

  <details>
  <summary> 포토 라이브러리 접근 </summary>

  ```swift
  class PhotosImageViewmodel: NSObject, ObservableObject, PHPhotoLibraryChangeObserver {
       // 생략
       // ...
       override init() {
           super.init()
           photoLibrary.register(self)
           Task {
               await requestPhotoModel()
           }
       }

       deinit {
           photoLibrary.unregisterChangeObserver(self)
       }

       // ...
  }
  ```

  </details>

  <details>
  <summary> 포토 라이브러리 요청 </summary>

  ```swift
  // ...
  // MARK: - requestPhotoModel
  func requestPhotoModel() async {
       let fetchOptions = PHFetchOptions()
       let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: true)
       fetchOptions.sortDescriptors = [sortDescriptor]

       let allPhotos = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: fetchOptions)

       self.isLoading = true

       totalPhotosCount = allPhotos.count

       allPhotos.enumerateObjects { (asset, _, _) in
           self.fetchImage(for: asset) { image in
               if let image = image {
                   let photo = PhotosImage(
                                           id: asset.localIdentifier,
                                           image: image,
                                           creationDate: asset.creationDate,
                                           location: asset.location,
                                           pixelWidth: CGFloat(asset.pixelWidth),
                                           pixelHeight: CGFloat(asset.pixelHeight),
                                           isFavorite: asset.isFavorite
                                           )

                   DispatchQueue.main.async {
                       if !self.photosArr.contains(where: { $0.id == photo.id }) {
                               self.photosArr.append(photo)
                       }

                       self.addPhotoForDic(photo)

                       self.processedPhotosCount += 1

                       if self.processedPhotosCount == self.totalPhotosCount {
                           self.initializeSelectedPhotoInTotal()
                           self.isLoading = false
                       }
                   }
               } else {
                    DispatchQueue.main.async {
                       self.processedPhotosCount += 1

                       if self.processedPhotosCount == self.totalPhotosCount {
                           self.initializeSelectedPhotoInTotal()
                           self.isLoading = false
                       }
                   } // DispatchQueue
               } // if - else
           }
       }

  } // requestPhotoModel

  ```

  </details>

  <details>

  <summary> 포토 라이브러리가 변경 감지 메서드 </summary>

  ```swift
  class PhotosImageViewmodel: NSObject, ObservableObject, PHPhotoLibraryChangeObserver {
     // 생략
     // ..
     @Published var isLoading: Bool = false
     // 생략
     // ...

     func photoLibraryDidChange(_ changeInstance: PHChange) {
         DispatchQueue.main.async {
             self.isLoading = true
             Task {
                 await self.requestPhotoModel()
             }
         }
     } // photoLibraryDidChange
  }
  ```

  </details>

## 참고

- [공식문서 - Photos](https://developer.apple.com/documentation/photos)

- [Photos 관련 - 블로그 참조1](https://jinnify.tistory.com/44)

- [Photos 관련 - 블로그 참조2](https://ios-development.tistory.com/1415)

- [DynamicZoom 관련 블로그 참조](https://stackoverflow.com/questions/73042355/how-to-dynamically-change-griditems-in-lazyvgrid-with-magnificationgesture-zoom)

- [MagnifyGesture 관련 블로그 참조](https://green1229.tistory.com/427)

- [ScrollOffset 관련 블로그 참조](https://green1229.tistory.com/463)

- [simultaneously 관련 블로그 참조](https://medium.com/@carlos.camyoh/zooming-and-dragging-simultaneously-on-an-image-using-swiftui-ios-15-6fbb0007ae2c)

- [animation 관련 블로그 참조](https://mobileappcircular.com/how-to-create-a-hero-animation-in-swiftui-154c6c6980ef)

- [zoom 관련 유튜브 참조](https://www.youtube.com/watch?v=Ab1FszXByGw)

- [Namespace 관련 블로그 참조](https://developer.apple.com/documentation/swiftui/namespace)
