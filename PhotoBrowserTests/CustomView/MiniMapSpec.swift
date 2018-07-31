//
//  MiniMapSpec.swift
//  PhotoBrowserTests
//
//  Created by zouliangming on 2018/8/4.
//  Copyright © 2018年 Teambition. All rights reserved.
//

import XCTest
import Quick
import Nimble
@testable import PhotoBrowser

extension UIImage {
    class func imageFromColor(_ color: UIColor, size: CGSize) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}

class MiniMapSpec: QuickSpec {
    
    override func spec() {
        describe("MiniMap") {
            describe("Normal ratios") {
                var miniMap: MiniMap!
                var size: CGSize!
                var image: UIImage!
                var realSize: CGSize!
                beforeEach {
                    size = CGSize(width: 5, height: 10)
                    miniMap = MiniMap(size: size)
                    image = UIImage.imageFromColor(.red, size: size)
                    miniMap.image = image
                    realSize = miniMap.getImageSize()
                }
                it("MiniMap image width is: size.width", closure: {
                    expect(miniMap.image.size.width).to(equal(size.width))
                })
                it("MiniMap image height is: size.height", closure: {
                    expect(miniMap.image.size.height).to(equal(size.height))
                })
                
                it("MiniMap real width is: size.width", closure: {
                    expect(realSize.width).to(equal(size.width))
                })
                it("MiniMap real height is: size.height", closure: {
                    expect(realSize.height).to(equal(size.height))
                })
                
            }
        }
    }
}
