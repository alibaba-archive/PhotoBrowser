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

enum PhotoBrowserError: Error {
    case cacheKeyNotExsit
    case imageNotExsit
}

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
    
    public func isOriginImageCached() -> Bool {
        if image != nil {
            return true
        }
        
        guard let cacheKey = fileKey ?? photoUrl?.absoluteString else {
            return false
        }
        
        return KingfisherManager.shared.cache.isCached(forKey: cacheKey)
    }
    
    public func isThumbnailCached() -> Bool {
        if thumbnailImage != nil {
            return true
        }
        
        guard let cacheKey = thumbnailUrl?.absoluteString else {
            return false
        }
        
        return KingfisherManager.shared.cache.isCached(forKey: cacheKey)
    }

    public func localOriginalPhoto(_ completion: @escaping ((UIImage)?) -> Void) {
        if let image = image {
            completion(image)
            return
        }
        guard let cacheKey = fileKey ?? photoUrl?.absoluteString else {
            completion(nil)
            return
        }
        // retrieve image from cache
        let options: KingfisherOptionsInfo = [.preloadAllAnimationData]
        KingfisherManager.shared.cache
            .retrieveImage(forKey: cacheKey,
                           options: options,
                           callbackQueue: .mainAsync) { (result) in
                            completion(try? result.get().image)
        }
    }

    public func localThumbnailPhoto(_ completion: @escaping (UIImage?) -> Void) {
        if thumbnailImage != nil {
            completion(thumbnailImage)
            return
        }
        guard let cacheKey = thumbnailUrl?.absoluteString else {
            completion(nil)
            return
        }
        
        let options: KingfisherOptionsInfo = [.preloadAllAnimationData]
        KingfisherManager.shared.cache
            .retrieveImage(forKey: cacheKey,
                           options: options,
                           callbackQueue: .mainAsync) { (result) in
                completion(try? result.get().image)
        }
    }

    public func imageToSave(_ completion: @escaping (UIImage?) -> Void) {
        localOriginalPhoto { (image) in
            if image != nil {
                completion(image)
            } else {
                self.localThumbnailPhoto { (image) in
                    completion(image)
                }
            }
        }
    }
}
