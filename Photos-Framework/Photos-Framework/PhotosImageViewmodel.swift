//
//  PhotosViewmodel.swift
//  Photos-Framework
//
//  Created by KyungHeon Lee on 2024/09/04.
//

import Foundation
import Photos
import SwiftUI

// MARK: - PhotosImageViewmodel
class PhotosImageViewmodel: NSObject, ObservableObject, PHPhotoLibraryChangeObserver {
    // MARK: Published
    @Published var photosArr: [PhotosImage] = []
    @Published var yearsDicts: [Int: [PhotosImage]] = [:]
    @Published var monthDicts: [Int: [Int: [PhotosImage]]] = [:]
    @Published var selectedPhotos: [PhotosImage] = []
    
    @Published var selected: PhotosImage?
    @Published var isLoading: Bool = false
    
    // MARK: Property
    private var totalPhotosCount = 0
    private var processedPhotosCount = 0
    
    private var photoLibrary: PHPhotoLibrary = PHPhotoLibrary.shared()
    
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
}

// MARK: - Extension Methods
extension PhotosImageViewmodel {
    var countingChecked: Int {
        selectedPhotos.count
    }
    
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
    
    // MARK: - getSortedYears
    func getSortedYears() -> [Int] {
        return yearsDicts.keys.sorted()
    }
    
    // MARK: - initializeSelectedPhotoInTotal
    func initializeSelectedPhotoInTotal() {
        if let idx = photosArr.indices.last {
            if selected == nil {
                selected = photosArr[idx]
            }
        }
    } // initializeSelectedPhotoInTotal
    
    // MARK: - initializeSelectedPhotoYear
    func initializeSelectedPhotoYear() {
        let allPhotos = yearsDicts.values.flatMap { $0 }
        if let idx = allPhotos.indices.last {
            if selected == nil {
                selected = allPhotos[idx]
            }
        }
    } // initializeSelectedPhotoYear
    
    // MARK: - PhotoLibraryChangeObserver
    // 포토 라이브러리가 변경된 경우 호출되는 메서드
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        DispatchQueue.main.async {
            self.isLoading = true
            Task {
                await self.requestPhotoModel()
            }
        }
    } // photoLibraryDidChange
    
    // MARK: - toggleSelectedPhoto
    func toggleSelectedPhoto(_ photo: PhotosImage) {
        if let i = selectedPhotos.firstIndex(of: photo), photo.isSelected {
            selectedPhotos.remove(at: i)
            if let idx = photosArr.firstIndex(of: photo) {
                photosArr[idx].isSelected = false
            }
        } else {
            if !selectedPhotos.contains(photo) {
                selectedPhotos.append(photo)
            }
            if let idx = photosArr.firstIndex(of: photo) {
                photosArr[idx].isSelected = true
            }
        }
        
        photosArr = photosArr
        print("\(selectedPhotos.contains(photo) ? "있음" : "없음") \(selectedPhotos.count)")
        print(selectedPhotos)
    } // toggleSelectedPhoto
    
    // MARK: - clearSelectedPhto
    func clearSelectedPhto() {
        selectedPhotos.removeAll()
        
        photosArr = photosArr.map { currentPhoto in
            return PhotosImage(
                id: currentPhoto.id,
                image: currentPhoto.image,
                creationDate: currentPhoto.creationDate,
                location: currentPhoto.location,
                pixelWidth: currentPhoto.pixelWidth,
                pixelHeight: currentPhoto.pixelHeight,
                isFavorite: currentPhoto.isFavorite
            )
        }
    } // clearSelectedPhto
    
    // MARK: - deleteSelectedPhotos
    func deleteSelectedPhotos() {
        isLoading = true
        
        if selectedPhotos.isEmpty {
            if let selectedPhoto = selected, let idx = photosArr.firstIndex(of: selectedPhoto) {
                photosArr.remove(at: idx)
                if !photosArr.isEmpty {
                    selected = photosArr[idx]
                }
            }
            isLoading = false
        } else {
            DispatchQueue.global(qos: .userInitiated).async {
                self.photosArr.removeAll { photo in
                    self.selectedPhotos.contains(where: { $0.id == photo.id })
                }
                
                DispatchQueue.main.async {
                    self.selectedPhotos.removeAll()
                    
                    self.isLoading = false
                }
            }
        } // if - else
    }
    
    // MARK: - fetchImage
    // PHImageManager을 통한 포토 라이브러리에서 data 가져오는 메서드
    private func fetchImage(for asset: PHAsset, completion: @escaping (UIImage?) -> Void) {
        let phototSize = CGSize(width: 150, height: 150)
        let imageManager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.isSynchronous = false
        
        imageManager.requestImage(for: asset, targetSize: phototSize, contentMode: .aspectFit, options: options) { image, _ in
            completion(image)
        } // requestImage
    } // fetchImage
    
    // MARK: - addPhotoToYear
    private func addPhotoForDic(_ photo: PhotosImage) {
        guard let creationDate = photo.creationDate else { return }
        let calendar = Calendar.current
        let year = calendar.component(.year, from: creationDate)
        let month = calendar.component(.month, from: creationDate)

        if yearsDicts[year] != nil {
            if !yearsDicts[year]!.contains(where: { $0.id == photo.id }) {
                yearsDicts[year]?.append(photo)
            }
        } else {
            yearsDicts[year] = [photo]
        }
        
        if monthDicts[year] != nil {
            if monthDicts[year]![month] != nil {
                if !monthDicts[year]![month]!.contains(where: { $0.id == photo.id }) {
                    monthDicts[year]![month]?.append(photo)
                }
            } else {
                monthDicts[year]![month] = [photo]
            }
        } else {
            monthDicts[year] = [month: [photo]]
        }
        
    } // addPhotoToYear
}
