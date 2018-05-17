//
//  MiniMap.swift
//  ImageMap
//
//  Created by wzxjiang on 2018/5/10.
//  Copyright © 2018 wzxjiang. All rights reserved.
//

import UIKit

struct Ratios {
    let top: CGFloat
    let left: CGFloat
    let width: CGFloat
    let height: CGFloat
    
    static let zero = Ratios(top: 0, left: 0, width: 0, height: 0)
    
    init(top: CGFloat, left: CGFloat, width: CGFloat, height: CGFloat) {
        self.top = min(max(top, 0), 1)
        self.left = min(max(left, 0), 1)
        self.width = min(max(width, 0), 1)
        self.height = min(max(height, 0), 1)
    }
}

public class MiniMap: UIView {
    public var image = UIImage() {
        didSet {
            updateimageViewSize()
            imageView.image = image
        }
    }
    
    private let imageView = UIImageView()
    
    private let backgroundLayer = CALayer()
    
    private var lineLayer = CAShapeLayer()
    
    private var maskLayer = CAShapeLayer()
    
    private let _size: CGSize
    
    var ratios: Ratios = .zero {
        didSet {
            updateLayer()
        }
    }
    
    private var imageViewSize: CGSize
    
    required public init(size: CGSize) {
        _size = size
        imageViewSize = size
        super.init(frame: .zero)
        setup()
        addLayer()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        backgroundColor = .black
        addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        updateImageViewSize()
    }
    
    private func addLayer() {
        backgroundLayer.frame = CGRect(origin: .zero, size: _size)
        backgroundLayer.backgroundColor = UIColor.black.withAlphaComponent(0.5).cgColor
        imageView.layer.addSublayer(backgroundLayer)

        lineLayer.strokeColor = UIColor.white.cgColor
        lineLayer.fillColor = UIColor.clear.cgColor
        imageView.layer.addSublayer(lineLayer)
    }
    
    private func updateLayer() {
        var top: CGFloat = imageViewSize.height * ratios.top
        var left: CGFloat = imageViewSize.width * ratios.left
        let width: CGFloat = imageViewSize.width * ratios.width
        let height: CGFloat = imageViewSize.height * ratios.height
        
        if top + height > imageViewSize.height {
            top = imageViewSize.height - height
        }
        
        if left + width > imageViewSize.width {
            left = imageViewSize.width - width
        }
        
        let maskBezierPath = UIBezierPath()
        maskBezierPath.move(to: CGPoint(x: 0, y: 0))
        maskBezierPath.addLine(to: CGPoint(x: 0, y: imageViewSize.height))
        maskBezierPath.addLine(to: CGPoint(x: imageViewSize.width, y: imageViewSize.height))
        maskBezierPath.addLine(to: CGPoint(x: imageViewSize.width, y: 0))
        maskBezierPath.move(to: CGPoint(x: left, y: top))
        maskBezierPath.addLine(to: CGPoint(x: left + width, y: top))
        maskBezierPath.addLine(to: CGPoint(x: left + width, y: top + height))
        maskBezierPath.addLine(to: CGPoint(x: left, y: top + height))
        maskBezierPath.close()
        maskLayer.path = maskBezierPath.cgPath
        backgroundLayer.mask = maskLayer

        
        let lineBezierPath = UIBezierPath()
        lineBezierPath.move(to: CGPoint(x: left, y: top))
        lineBezierPath.addLine(to: CGPoint(x: left + width, y: top))
        lineBezierPath.addLine(to: CGPoint(x: left + width, y: top + height))
        lineBezierPath.addLine(to: CGPoint(x: left, y: top + height))
        lineBezierPath.close()
        lineBezierPath.stroke()
        lineLayer.path = lineBezierPath.cgPath
    }
    
    private func updateimageViewSize() {
        let ratio = image.size.width / image.size.height
        
        if image.size.width > image.size.height {
            imageViewSize = CGSize(width: _size.width, height: _size.width / ratio)
        } else {
            imageViewSize = CGSize(width: _size.height * ratio, height: _size.height)
        }
        
        updateImageViewSize()
    }
    
    private func updateImageViewSize() {
        imageView.widthAnchor.constraint(equalToConstant: imageViewSize.width).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: imageViewSize.height).isActive = true
    }
}
