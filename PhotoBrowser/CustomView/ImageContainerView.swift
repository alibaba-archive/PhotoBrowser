//
//  ImageContainerView.swift
//  PhotoBrowser
//
//  Created by WangWei on 2019/3/26.
//  Copyright © 2019 Teambition. All rights reserved.
//

import UIKit

final class ImageContainerView: UIView {
    lazy var highResImageView: HighResolutionImageView = {
        let imageView = HighResolutionImageView()
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    lazy var normalImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    var image: UIImage? {
        didSet {
            update(with: image)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        addSubview(normalImageView)
        addSubview(highResImageView)
        normalImageView.frame = bounds
        highResImageView.frame = bounds
    }
    
    override func layoutSubviews() {
        normalImageView.frame = bounds
        highResImageView.frame = bounds
    }
    
    private func update(with image: UIImage?) {
        guard let image = image else {
            highResImageView.image = nil
            normalImageView.image = nil
            return
        }
        let shouldUseHighResImageView =
            image.size.width * image.size.height > 3000 * 3000
        highResImageView.isHidden = !shouldUseHighResImageView
        normalImageView.isHidden = shouldUseHighResImageView
        if shouldUseHighResImageView {
            highResImageView.frame = bounds
            highResImageView.image = image
        } else {
            normalImageView.frame = bounds
            normalImageView.image = image
        }
    }
}
