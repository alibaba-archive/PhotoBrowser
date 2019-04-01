//
//  Photo.swift
//  PhotoBrowser
//
//  Created by WangWei on 16/2/16.
//  Copyright © 2016年 Teambition. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher
import Photos

public struct Photo {
    public var image: UIImage?
    public var thumbnailImage: UIImage?
    public var photoUrl: URL?
    public var thumbnailUrl: URL?
    public var title: String?
    public var object: Any?
    public var asset: PHAsset?
    public var fileKey: String?
    
    public init(image: UIImage?, title: String? = nil, thumbnailImage: UIImage? = nil, photoUrl: URL? = nil, thumbnailUrl: URL? = nil, object: Any? = nil, fileKey: String?) {
        self.image = image
        self.title = title
        self.thumbnailImage = thumbnailImage
        self.photoUrl = photoUrl
        self.thumbnailUrl = thumbnailUrl
        self.object = object
        self.fileKey = fileKey
    }

    public init(asset: PHAsset) {
        self.asset = asset
    }
    
    public func localOriginalPhoto() -> UIImage? {
        let options: KingfisherOptionsInfo = [.preloadAllAnimationData]
        if image != nil {
            return image
        } else if let originFileKey = fileKey {
            let image = KingfisherManager.shared.cache
                .retrieveImageInMemoryCache(forKey: originFileKey,
                                            options: options)
            return image ?? KingfisherManager.shared.cache
                .retrieveImageInDiskCache(forKey: originFileKey,
                                          options: options)
        } else if let photoUrl = photoUrl {
            let image = KingfisherManager.shared.cache
                .retrieveImageInMemoryCache(forKey: photoUrl.absoluteString,
                                            options: options)
            return image ?? KingfisherManager.shared.cache
                .retrieveImageInDiskCache(forKey: photoUrl.absoluteString,
                                          options: options)
        }
        return nil
    }
    
    public func localThumbnailPhoto() -> UIImage? {
        let options: KingfisherOptionsInfo = [.preloadAllAnimationData]
        if thumbnailImage != nil {
            return thumbnailImage
        } else if let thumbnailUrl = thumbnailUrl {
            let image = KingfisherManager.shared.cache
                .retrieveImageInMemoryCache(forKey: thumbnailUrl.absoluteString,
                                            options: options)
            return image ?? KingfisherManager.shared.cache
                .retrieveImageInDiskCache(forKey: thumbnailUrl.absoluteString,
                                          options: options)
        }
        return nil
    }
    
    public func imageToSave() -> UIImage? {
        if let imageToSave = localOriginalPhoto() {
            return imageToSave
        }
        if let imageToSave = localThumbnailPhoto() {
            return imageToSave
        }
        return nil
    }
}
