//
//  UIViewSpec.swift
//  PhotoBrowserTests
//
//  Created by zouliangming on 2018/8/7.
//  Copyright © 2018年 Teambition. All rights reserved.
//

import XCTest
import Quick
import Nimble
@testable import PhotoBrowser

class UIViewSpec: QuickSpec {
    override func spec() {
        describe("UIView frame extension") {
            describe("UIView frame get methods") {
                var frame: CGRect!
                var view: UIView!
                beforeEach {
                    frame = CGRect(x: 10, y: 11, width: 12, height: 13)
                    view = UIView(frame: frame)
                }
                it("UIView frame's originX should be CGFloat(10)", closure: {
                    expect(view.originX).to(equal(CGFloat(10)))
                })
                it("UIView frame's originY should be CGFloat(11)", closure: {
                    expect(view.originY).to(equal(CGFloat(11)))
                })
                it("UIView frame's width should be CGFloat(12)", closure: {
                    expect(view.width).to(equal(CGFloat(12)))
                })
                it("UIView frame's height should be CGFloat(13)", closure: {
                    expect(view.height).to(equal(CGFloat(13)))
                })
                it("UIView frame's size should be CGSize(width: 12, height: 13))", closure: {
                    expect(view.size).to(equal(CGSize(width: 12, height: 13)))
                })
                it("UIView frame's origin should be CGPoint(x: 10, y: 11))", closure: {
                    expect(view.origin).to(equal(CGPoint(x: 10, y: 11)))
                })
            }
            
            describe("UIView frame set originX, originY, width, height methods") {
                var frame: CGRect!
                var view: UIView!
                beforeEach {
                    frame = CGRect(x: 10, y: 11, width: 12, height: 13)
                    view = UIView(frame: frame)
                    view.originX = 100
                    view.originY = 101
                    view.width = 102
                    view.height = 103
                }
                it("UIView frame's originX should be CGFloat(100)", closure: {
                    expect(view.originX).to(equal(CGFloat(100)))
                })
                it("UIView frame's originY should be CGFloat(101)", closure: {
                    expect(view.originY).to(equal(CGFloat(101)))
                })
                it("UIView frame's width should be CGFloat(102)", closure: {
                    expect(view.width).to(equal(CGFloat(102)))
                })
                it("UIView frame's height should be CGFloat(103)", closure: {
                    expect(view.height).to(equal(CGFloat(103)))
                })
            }
            
            describe("UIView frame set origin and size methods") {
                var frame: CGRect!
                var view: UIView!
                beforeEach {
                    frame = CGRect(x: 10, y: 11, width: 12, height: 13)
                    view = UIView(frame: frame)
                    view.size = CGSize(width: 102, height: 103)
                    view.origin = CGPoint(x: 100, y: 101)
                }
                it("UIView frame's size should be CGSize(width: 102, height: 103))", closure: {
                    expect(view.size).to(equal(CGSize(width: 102, height: 103)))
                })
                it("UIView frame's origin should be CGPoint(x: 100, y: 101))", closure: {
                    expect(view.origin).to(equal(CGPoint(x: 100, y: 101)))
                })
            }
        }
    }
}
