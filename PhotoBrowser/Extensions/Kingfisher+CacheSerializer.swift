//
//  Kingfisher+CacheSerializer.swift
//  PhotoBrowser
//
//  Created by WangWei on 2019/4/2.
//  Copyright © 2019 Teambition. All rights reserved.
//

import Kingfisher

struct CustomCacheSerializer: CacheSerializer {
    static let `default` = CustomCacheSerializer()
    private init() {}
    
    func data(with image: Image, original: Data?) -> Data? {
        // do nothing when image.size is too large
        if image.size.width * image.size.height > 3000 * 3000 {
            return original
        }

        let imageFormat = original?.kf.imageFormat ?? .unknown

        let data: Data?
        switch imageFormat {
        case .PNG: data = image.kf.pngRepresentation()
        case .JPEG: data = image.kf.jpegRepresentation(compressionQuality: 1.0)
        case .GIF: data = image.kf.gifRepresentation()
        case .unknown: data = original ?? image.kf.normalized.kf.pngRepresentation()
        }

        return data
    }
    
    func image(with data: Data, options: KingfisherParsedOptionsInfo) -> Image? {
        let imageCreatingOptions =
            ImageCreatingOptions(scale: options.scaleFactor,
                                 duration: 0.0,
                                 preloadAll: options.preloadAllAnimationData,
                                 onlyFirstFrame: options.onlyLoadFirstFrame)
        return KingfisherWrapper<Image>.image(data: data,
                                              options: imageCreatingOptions)
    }
}
