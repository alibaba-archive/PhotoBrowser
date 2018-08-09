//
//  SkitchViewSpec.swift
//  PhotoBrowserTests
//
//  Created by zouliangming on 2018/8/2.
//  Copyright © 2018年 Teambition. All rights reserved.
//

import XCTest
import Quick
import Nimble
@testable import PhotoBrowser

class MockSkitchViewDelegate: SkitchViewDelegate {
    var delegateResult: Int?
    
    func didPressedSkitchView(skitchView: SkitchView, index: Int) {
        delegateResult = index
    }
}

class SkitchViewSpec: QuickSpec {
    override func spec() {
        describe("skitch view") {
            describe("delegate", {
                var skitchView: SkitchView!
                var mockDelegate: MockSkitchViewDelegate!
                beforeEach {
                    skitchView = SkitchView(frame: CGRect.zero)
                    mockDelegate = MockSkitchViewDelegate()
                    skitchView.delegate = mockDelegate
                    skitchView.setTitle("10", index: 10)
                    mockDelegate.didPressedSkitchView(skitchView: skitchView, index: 10)
                }
                
                it("delegate should not be nil", closure: {
                    expect(skitchView.delegate) === mockDelegate
                })
                
                it("skitchCircleButton title and tag", closure: {
                    expect(skitchView.skitchCircleButton.titleLabel?.text).to(equal("10"))
                    expect(skitchView.skitchCircleButton.tag).to(equal(777 + 10))
                    expect(skitchView.skitchRectangleButton.tag).to(equal(777 + 10))
                })
                
                it("skitchCircleButton pressed", closure: {
                    expect(mockDelegate.delegateResult).to(equal(10))
                })
            })
        }
    }
}
