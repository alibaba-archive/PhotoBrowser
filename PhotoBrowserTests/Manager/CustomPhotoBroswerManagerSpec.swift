//
//  CustomPhotoBroswerManagerSpec.swift
//  PhotoBrowserTests
//
//  Created by zouliangming on 2018/8/7.
//  Copyright © 2018年 Teambition. All rights reserved.
//

import XCTest
import Quick
import Nimble
@testable import PhotoBrowser

class CustomPhotoBroswerManagerSpec: QuickSpec {
    override func spec() {
        describe("CustomPhotoBroswerManager") {
            var manager: CustomPhotoBroswerManager!
            let customLogoLoading = UIImage()
            let customCheckSelected = UIImage()
            beforeEach {
                manager = CustomPhotoBroswerManager.shared
                manager.customLogoLoading = customLogoLoading
                manager.customCheckSelected = customCheckSelected
            }
            it("CustomPhotoBroswerManager customLogoLoading should be customLogoLoading", closure: {
                expect(CustomPhotoBroswerManager.shared.customLogoLoading).to(equal(customLogoLoading))
            })
            it("CustomPhotoBroswerManager customCheckSelected should be customCheckSelected", closure: {
                expect(CustomPhotoBroswerManager.shared.customCheckSelected).to(equal(customCheckSelected))
            })
        }
    }
}
