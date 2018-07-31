//
//  RatiosSpec.swift
//  PhotoBrowserTests
//
//  Created by zouliangming on 2018/8/2.
//  Copyright © 2018年 Teambition. All rights reserved.
//

import XCTest
import Quick
import Nimble
@testable import PhotoBrowser

class RatiosSpec: QuickSpec {
    // swiftlint:disable function_body_length
    override func spec() {
        describe("Ratios") {
            describe("Normal ratios") {
                var ratios: Ratios!
                beforeEach {
                    ratios = Ratios(top: 0.1, left: 0.2, width: 0.3, height: 0.4)
                }
                it("ratios top should be 0.1", closure: {
                    expect(ratios.top).to(equal(CGFloat(0.1)))
                })
                it("ratios left should be 0.2", closure: {
                    expect(ratios.left).to(equal(CGFloat(0.2)))
                })
                it("ratios width should be 0.3", closure: {
                    expect(ratios.width).to(equal(CGFloat(0.3)))
                })
                it("ratios height should be 0.4", closure: {
                    expect(ratios.height).to(equal(CGFloat(0.4)))
                })
            }
            
            describe("Ratios with nagative top") {
                var ratios: Ratios!
                beforeEach {
                    ratios = Ratios(top: -0.1, left: 0.2, width: 0.3, height: 0.4)
                }
                it("ratios top should be 0", closure: {
                    expect(ratios.top).to(equal(CGFloat(0)))
                })
                it("ratios left should be 0.2", closure: {
                    expect(ratios.left).to(equal(CGFloat(0.2)))
                })
                it("ratios width should be 0.3", closure: {
                    expect(ratios.width).to(equal(CGFloat(0.3)))
                })
                it("ratios height should be 0.4", closure: {
                    expect(ratios.height).to(equal(CGFloat(0.4)))
                })
            }
            
            describe("Ratios with nagative left") {
                var ratios: Ratios!
                beforeEach {
                    ratios = Ratios(top: 0.1, left: -0.2, width: 0.3, height: 0.4)
                }
                it("ratios top should be 0.1", closure: {
                    expect(ratios.top).to(equal(CGFloat(0.1)))
                })
                it("ratios left should be 0", closure: {
                    expect(ratios.left).to(equal(CGFloat(0)))
                })
                it("ratios width should be 0.3", closure: {
                    expect(ratios.width).to(equal(CGFloat(0.3)))
                })
                it("ratios height should be 0.4", closure: {
                    expect(ratios.height).to(equal(CGFloat(0.4)))
                })
            }
            
            describe("Ratios with nagative width") {
                var ratios: Ratios!
                beforeEach {
                    ratios = Ratios(top: 0.1, left: 0.2, width: -0.3, height: 0.4)
                }
                it("ratios top should be 0.1", closure: {
                    expect(ratios.top).to(equal(CGFloat(0.1)))
                })
                it("ratios left should be 0.2", closure: {
                    expect(ratios.left).to(equal(CGFloat(0.2)))
                })
                it("ratios width should be 0", closure: {
                    expect(ratios.width).to(equal(CGFloat(0)))
                })
                it("ratios height should be 0.4", closure: {
                    expect(ratios.height).to(equal(CGFloat(0.4)))
                })
            }
            
            describe("Ratios with nagative height") {
                var ratios: Ratios!
                beforeEach {
                    ratios = Ratios(top: 0.1, left: 0.2, width: 0.3, height: -0.4)
                }
                it("ratios top should be 0.1", closure: {
                    expect(ratios.top).to(equal(CGFloat(0.1)))
                })
                it("ratios left should be 0.2", closure: {
                    expect(ratios.left).to(equal(CGFloat(0.2)))
                })
                it("ratios width should be 0.3", closure: {
                    expect(ratios.width).to(equal(CGFloat(0.3)))
                })
                it("ratios height should be 0", closure: {
                    expect(ratios.height).to(equal(CGFloat(0)))
                })
            }
            
            describe("Ratios with all nagative") {
                var ratios: Ratios!
                beforeEach {
                    ratios = Ratios(top: -0.1, left: -0.2, width: -0.3, height: -0.4)
                }
                it("ratios top should be 0", closure: {
                    expect(ratios.top).to(equal(CGFloat(0)))
                })
                it("ratios left should be 0", closure: {
                    expect(ratios.left).to(equal(CGFloat(0)))
                })
                it("ratios width should be 0", closure: {
                    expect(ratios.width).to(equal(CGFloat(0)))
                })
                it("ratios height should be 0", closure: {
                    expect(ratios.height).to(equal(CGFloat(0)))
                })
            }
            
            describe("Ratios with top > 1") {
                var ratios: Ratios!
                beforeEach {
                    ratios = Ratios(top: 1.2, left: 0.2, width: 0.3, height: 0.4)
                }
                it("ratios top should be 1", closure: {
                    expect(ratios.top).to(equal(CGFloat(1)))
                })
                it("ratios left should be 0.2", closure: {
                    expect(ratios.left).to(equal(CGFloat(0.2)))
                })
                it("ratios width should be 0.3", closure: {
                    expect(ratios.width).to(equal(CGFloat(0.3)))
                })
                it("ratios height should be 0.4", closure: {
                    expect(ratios.height).to(equal(CGFloat(0.4)))
                })
            }
            
            describe("Ratios with left > 1") {
                var ratios: Ratios!
                beforeEach {
                    ratios = Ratios(top: 0.1, left: 1.2, width: 0.3, height: 0.4)
                }
                it("ratios top should be 0.1", closure: {
                    expect(ratios.top).to(equal(CGFloat(0.1)))
                })
                it("ratios left should be 1", closure: {
                    expect(ratios.left).to(equal(CGFloat(1)))
                })
                it("ratios width should be 0.3", closure: {
                    expect(ratios.width).to(equal(CGFloat(0.3)))
                })
                it("ratios height should be 0.4", closure: {
                    expect(ratios.height).to(equal(CGFloat(0.4)))
                })
            }
            
            describe("Ratios with width > 1") {
                var ratios: Ratios!
                beforeEach {
                    ratios = Ratios(top: 0.1, left: 0.2, width: 1.3, height: 0.4)
                }
                it("ratios top should be 0.1", closure: {
                    expect(ratios.top).to(equal(CGFloat(0.1)))
                })
                it("ratios left should be 0.2", closure: {
                    expect(ratios.left).to(equal(CGFloat(0.2)))
                })
                it("ratios width should be 1", closure: {
                    expect(ratios.width).to(equal(CGFloat(1)))
                })
                it("ratios height should be 0.4", closure: {
                    expect(ratios.height).to(equal(CGFloat(0.4)))
                })
            }
            
            describe("Ratios with height > 1") {
                var ratios: Ratios!
                beforeEach {
                    ratios = Ratios(top: 0.1, left: 0.2, width: 0.3, height: 1.4)
                }
                it("ratios top should be 0.1", closure: {
                    expect(ratios.top).to(equal(CGFloat(0.1)))
                })
                it("ratios left should be 0.2", closure: {
                    expect(ratios.left).to(equal(CGFloat(0.2)))
                })
                it("ratios width should be 0.3", closure: {
                    expect(ratios.width).to(equal(CGFloat(0.3)))
                })
                it("ratios height should be 1", closure: {
                    expect(ratios.height).to(equal(CGFloat(1)))
                })
            }
            
            describe("Ratios with all > 1") {
                var ratios: Ratios!
                beforeEach {
                    ratios = Ratios(top: 1.1, left: 1.2, width: 1.3, height: 1.4)
                }
                it("ratios top should be 1", closure: {
                    expect(ratios.top).to(equal(CGFloat(1)))
                })
                it("ratios left should be 1", closure: {
                    expect(ratios.left).to(equal(CGFloat(1)))
                })
                it("ratios width should be 1", closure: {
                    expect(ratios.width).to(equal(CGFloat(1)))
                })
                it("ratios height should be 1", closure: {
                    expect(ratios.height).to(equal(CGFloat(1)))
                })
            }
            
        }
    }
}
