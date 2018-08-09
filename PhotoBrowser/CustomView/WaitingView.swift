//
//  WaitingView.swift
//  PhotoBrowser
//
//  Created by zouliangming on 2018/8/6.
//  Copyright © 2018年 Teambition. All rights reserved.
//

import UIKit

class WaitingView: UIView {
    var logoView: UIImageView!
    var progress: CGFloat = 0 {
        willSet {
            if newValue > 1 {
                removeFromSuperview()
            }
        }
        didSet {
            setNeedsDisplay()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 5.0
        layer.masksToBounds = true
        backgroundColor = UIColor.black.withAlphaComponent(0.6)
        clipsToBounds = true
        
        let image = getLogoLoadingImage()
        logoView = UIImageView.init(image: image)
        logoView.center = center
        addSubview(logoView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        let currentContext = UIGraphicsGetCurrentContext()
        let centerX = rect.size.width / 2
        let centerY = rect.size.height / 2
        let center = CGPoint(x: centerX, y: centerY)
        
        UIColor.white.set()
        currentContext?.setLineWidth(2)
        currentContext?.setLineCap(CGLineCap.round)
        let end = -CGFloat.pi/2 + CGFloat(progress) * CGFloat.pi*2 + 0.05
        let radius = min(rect.size.width, rect.size.height) / 2 - PBConstant.WaitingView.margin
        currentContext?.addArc(center: center, radius: radius, startAngle: -CGFloat.pi / 2, endAngle: end, clockwise: false)
        currentContext?.strokePath()
    }
    
    private func getLogoLoadingImage() -> UIImage? {
        if let logoImage = CustomPhotoBroswerManager.shared.customLogoLoading {
            return logoImage
        } else {
            return UIImage.init(named: "icon-logo-white", in: Bundle.init(for: classForCoder), compatibleWith: nil)
        }
    }
    
}
