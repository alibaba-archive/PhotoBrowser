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
    
    public func localOriginalPhoto(_ completion: @escaping ((UIImage)?) -> Void) {
        if image != nil {
            completion(image)
        } else if let originFileKey = fileKey {
            let image = KingfisherManager.shared.cache.retrieveImageInMemoryCache(forKey: originFileKey)
            if image != nil {
                return completion(image)
            } else {
                KingfisherManager.shared.cache.retrieveImageInDiskCache(forKey: originFileKey) { result in
                    switch result {
                    case .success(let diskImage):
                        completion(diskImage)
                    case .failure:
                        completion(nil)
                    }
                }
            }
        } else if let photoUrl = photoUrl {
            let image = KingfisherManager.shared.cache.retrieveImageInMemoryCache(forKey: photoUrl.absoluteString)
            if image != nil {
                return completion(image)
            } else {
                KingfisherManager.shared.cache.retrieveImageInDiskCache(forKey: photoUrl.absoluteString) { result in
                    switch result {
                    case .success(let diskImage):
                        completion(diskImage)
                    case .failure:
                        completion(nil)
                    }
                }
            }
        }
    }
    
    public func localThumbnailPhoto(_ completion: @escaping ((UIImage)?) -> Void) {
        if thumbnailImage != nil {
            completion(thumbnailImage)
        } else if let thumbnailUrl = thumbnailUrl {
            let image = KingfisherManager.shared.cache.retrieveImageInMemoryCache(forKey: thumbnailUrl.absoluteString)
            if image != nil {
                return completion(image)
            } else {
                KingfisherManager.shared.cache.retrieveImageInDiskCache(forKey: thumbnailUrl.absoluteString) { result in
                    switch result {
                    case .success(let diskImage):
                        completion(diskImage)
                    case .failure:
                        completion(nil)
                    }
                }
            }
        }
        completion(nil)
    }
    
    public func imageToSave(_ completion: @escaping ((UIImage)?) -> Void) {
        localOriginalPhoto { (image) in
            if image != nil {
                completion(image)
            }
        }
        localThumbnailPhoto { (image) in
            if image != nil {
                completion(image)
            }
        }
        completion(nil)
    }
}
