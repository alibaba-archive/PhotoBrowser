//
//  WaitingView.swift
//  PhotoBrowser
//
//  Created by WangWei on 16/2/14.
//  Copyright © 2016年 Teambition. All rights reserved.
//

import Foundation
import UIKit

private let waitingViewMargin: CGFloat = 10.0

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
        backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.6)
        clipsToBounds = true
        
        let image = UIImage.init(named: "icon-logo-white", inBundle: NSBundle.init(forClass: classForCoder), compatibleWithTraitCollection: nil)
        
        logoView = UIImageView.init(image: image)
        logoView.center = center
        addSubview(logoView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func drawRect(rect: CGRect) {
        let currentContext = UIGraphicsGetCurrentContext()
        let centerX = rect.size.width / 2
        let centerY = rect.size.height / 2
        
        UIColor.whiteColor().set()
        CGContextSetLineWidth(currentContext, 2)
        CGContextSetLineCap(currentContext, CGLineCap.Round)
        let end = CGFloat( -M_PI_2 + Double(progress) * M_PI * 2 + 0.05)
        let radius = min(rect.size.width, rect.size.height) / 2 - waitingViewMargin
        CGContextAddArc(currentContext, centerX, centerY, radius, CGFloat(-M_PI_2), end, 0)
        CGContextStrokePath(currentContext)
    }
    
}
