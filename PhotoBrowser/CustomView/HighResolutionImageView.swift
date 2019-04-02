//
//  HighResolutionImageView.swift
//  PhotoBrowser
//
//  Created by WangWei on 2019/3/22.
//  Copyright © 2019 Teambition. All rights reserved.
//

import UIKit

private class FastTiledLayer: CATiledLayer {
    override class func fadeDuration() -> CFTimeInterval {
        return 0.0
    }
}

// swiftlint:disable force_cast
final class HighResolutionImageView: UIView {
    override class var layerClass: AnyClass {
        return FastTiledLayer.self
    }
    
    fileprivate var tiledLayer: FastTiledLayer {
        return self.layer as! FastTiledLayer
    }
    
    var image: UIImage? {
        didSet {
            updateTileSize()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentMode = .scaleAspectFit
        layer.contentsGravity = .resizeAspect
        
        backgroundColor = .white
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var imageScale: CGFloat = 1.0
    
    private var contentScale: CGFloat = 1.0
    
    override var contentScaleFactor: CGFloat {
        didSet {
            super.contentScaleFactor = 1
        }
    }
    
    private func updateTileSize() {
        guard let imageSize = image?.size else { return }
        
        // divide to 3 * 3 tiles
        // tileSize is in Pixels
        let tileWidth = bounds.width / 4
        let tileHeight = bounds.height / 4
        tiledLayer.tileSize = CGSize(width: tileWidth, height: tileHeight)
        // cal imageScale
        imageScale = max(bounds.width / imageSize.width, bounds.height / imageSize.height)
        
        tiledLayer.levelsOfDetailBias = Int(exactly: ceil(log2(1 / imageScale)))! + 1
    }
    
    override func draw(_ rect: CGRect) {
        guard let cgImage = image?.cgImage else { return }
        let scaledRect = rect.applying(CGAffineTransform(scaleX: 1 / imageScale, y: 1 / imageScale))
        let croppedCGImage = cgImage.cropping(to: scaledRect)!
        let croppedImage = UIImage(cgImage: croppedCGImage)
        croppedImage.draw(in: rect)
    }
}
