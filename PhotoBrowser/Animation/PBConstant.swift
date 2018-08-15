//
//  PBConstant.swift
//  PhotoBrowser
//
//  Created by zouliangming on 2018/8/6.
//  Copyright © 2018年 Teambition. All rights reserved.
//

import Foundation

enum PBConstant {
    enum Animation {
        static let presentDuration = 0.3
        static let dismissDuration = 0.35
        static var associatedObjectHandle: UInt8 = 0
    }
    
    enum WaitingView {
        static let margin: CGFloat = 10.0
    }
    
    enum PhotoBrowser {
        static let toolBarHeight: CGFloat = 44
        static let padToolBarSpace: CGFloat = 72
    }
    
    enum PhotoPreview {
        static let skitchButtonFontSize: CGFloat = CGFloat(15)
        static let skitchButtonTag: Int = 777
        static let skitchButtonRadius: CGFloat = 32
        static let skitchButtonBgColor = UIColor(red: 61/255, green: 168/255, blue: 245/255, alpha: 1)
        static let skitchRectangleButtonBgColor = UIColor(red: 61/255, green: 168/255, blue: 245/255, alpha: 0.24)
        
        static let maxMoveOfY: CGFloat = 250
        static let minZoom: CGFloat = 0.3
    }
    
    enum DeviceSize {
        enum Landscape {
            static let iPhoneX = CGSize(width: 812, height: 375)
        }
        enum Portrait {
            static let iPhoneX = CGSize(width: 375, height: 812)
        }
    }

    enum Device {
        static let isIPhoneX = (UIScreen.main.bounds.size == PBConstant.DeviceSize.Portrait.iPhoneX || UIScreen.main.bounds.size == PBConstant.DeviceSize.Landscape.iPhoneX)
    }
}
