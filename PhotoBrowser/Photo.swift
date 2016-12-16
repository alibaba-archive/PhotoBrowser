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
    public var object: AnyObject?
    public var asset: PHAsset?
    
    public init(image: UIImage?, title: String? = nil, thumbnailImage: UIImage? = nil, photoUrl: URL? = nil, thumbnailUrl: URL? = nil, object: AnyObject? = nil) {
        self.image = image
        self.title = title
        self.thumbnailImage = thumbnailImage
        self.photoUrl = photoUrl
        self.thumbnailUrl = thumbnailUrl
        self.object = object
    }

    public init(asset: PHAsset) {
        self.asset = asset
    }
    
    public func localOriginalPhoto() -> UIImage? {
        if image != nil {
            return image
        } else if let photoUrl = photoUrl {
            let image = KingfisherManager.shared.cache.retrieveImageInMemoryCache(forKey: photoUrl.kfCacheKey)
            return image ?? KingfisherManager.shared.cache.retrieveImageInDiskCache(forKey: photoUrl.kfCacheKey)
        }
        return nil
    }
    
    public func localThumbnailPhoto() -> UIImage? {
        if thumbnailImage != nil {
            return thumbnailImage
        } else if let thumbnailUrl = thumbnailUrl {
            let image = KingfisherManager.shared.cache.retrieveImageInMemoryCache(forKey: thumbnailUrl.absoluteString)
            return image ?? KingfisherManager.shared.cache.retrieveImageInDiskCache(forKey: thumbnailUrl.absoluteString)
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

extension URL {
    var kfCacheKey: String {
        var photoCacheKey = absoluteString
        if let query = query {
            photoCacheKey = absoluteString.replacingOccurrences(of: query, with: "")
        }
        return photoCacheKey
    }
}
