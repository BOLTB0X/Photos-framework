//
//  Photos.swift
//  Photos-Framework
//
//  Created by KyungHeon Lee on 2024/09/04.
//

import Foundation
import Photos
import SwiftUI

// MARK: - Photos
struct PhotosImage: Identifiable, Equatable, Hashable {
    let id: String
    let image: UIImage
    let creationDate: Date?
    let location: CLLocation?
    let pixelWidth: CGFloat
    let pixelHeight: CGFloat
    var isFavorite: Bool
    var isSelected: Bool
    
    // ...
    // MARK: init
    init(id: String, image: UIImage,
         creationDate: Date?, location: CLLocation?,
         pixelWidth: CGFloat, pixelHeight: CGFloat,
         isFavorite: Bool, isSelected: Bool) {
        self.id = id
        self.image = image
        self.creationDate = creationDate
        self.location = location
        self.pixelWidth = pixelWidth
        self.pixelHeight = pixelHeight
        self.isFavorite = isFavorite
        self.isSelected = isSelected
    }
    
    init(id: String, image: UIImage,
         creationDate: Date?, location: CLLocation?,
         pixelWidth: CGFloat, pixelHeight: CGFloat,
         isFavorite: Bool) {
        self.id = id
        self.image = image
        self.creationDate = creationDate
        self.location = location
        self.pixelWidth = pixelWidth
        self.pixelHeight = pixelHeight
        self.isFavorite = isFavorite
        self.isSelected = false
    }
    
    static func ==(lhs: PhotosImage, rhs: PhotosImage) -> Bool {
        return lhs.id == rhs.id
    }
    
    static var zoomStages: [Int] {
        if UIDevice.current.orientation.isLandscape {
            return [4, 6, 8, 9]
        } else {
            return [1, 3, 5]
        }
    }
    
    static func getZoomStage(at index: Int) -> Int {
        if index >= zoomStages.count {
            return zoomStages.last!
        } else if index < 0 {
            return zoomStages.first!
        } else {
            return zoomStages[index]
        }
    }
    
    static func getMaxZoomStageIndex() -> Int {
        return zoomStages.count - 1
    }
}
