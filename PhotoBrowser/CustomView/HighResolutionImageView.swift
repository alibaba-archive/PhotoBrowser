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
        
        contentScale = contentScaleFactor
        contentMode = .scaleAspectFit
        layer.contentsGravity = .resizeAspect
        
        backgroundColor = .white
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var imageScale: CGFloat = 1.0
    
    private var contentScale: CGFloat = 1.0
    
    private func updateTileSize() {
        guard let imageSize = image?.size else { return }
        
        // divide to 2 * 2 tiles
        // tileSize is in Pixels
        let tileWidth = bounds.width / 2 * contentScaleFactor
        let tileHeight = bounds.height / 2 * contentScaleFactor
        tiledLayer.tileSize = CGSize(width: tileWidth, height: tileHeight)
        // cal imageScale
        imageScale = max(bounds.width * contentScaleFactor / imageSize.width, bounds.height * contentScaleFactor / imageSize.height)
        
        tiledLayer.levelsOfDetailBias = Int(exactly: ceil(log2(1 / imageScale)))!
    }
    
    override func draw(_ rect: CGRect) {
        guard let cgImage = image?.cgImage else { return }
        let scaledRect = rect.applying(CGAffineTransform(scaleX: contentScale / imageScale, y: contentScale / imageScale))
        let croppedCGImage = cgImage.cropping(to: scaledRect)!
        let croppedImage = UIImage(cgImage: croppedCGImage)
        croppedImage.draw(in: rect)
    }
}
