//
//  SkitchSpec.swift
//  PhotoBrowserTests
//
//  Created by zouliangming on 2018/8/1.
//  Copyright © 2018年 Teambition. All rights reserved.
//

import XCTest
import Quick
import Nimble
@testable import PhotoBrowser

class SkitchSpec: QuickSpec {
    
    override func spec() {
        describe("point model") {
            describe("point double test", {
                var point: Point!

                beforeEach {
                    let pointJSON = ["x": 1420.7524752475247, "y": 1596.8316831683169, "width": 273.74257425742576, "height": 273.74257425742579] // Double
                    point = Point(pointJSON: pointJSON)
                }

                it("point x should be 1420.7524752475247", closure: {
                    expect(point.x).to(equal(CGFloat(1420.7524752475247)))
                })
                it("point y should be 1596.8316831683169", closure: {
                    expect(point.y).to(equal(CGFloat(1596.8316831683169)))
                })
                it("point width should be 273.74257425742576", closure: {
                    expect(point.width).to(equal(CGFloat(273.74257425742576)))
                })
                it("point height should be 273.74257425742579", closure: {
                    expect(point.height).to(equal(CGFloat(273.74257425742579)))
                })
            })
            
            describe("point int test", {
                var point: Point!
                
                beforeEach {
                    let pointJSON = ["x": 10, "y": 11, "width": 12, "height": 13] // int
                    point = Point(pointJSON: pointJSON)
                }
                
                it("point x should be 10", closure: {
                    expect(point.x).to(equal(CGFloat(10)))
                })
                it("point y should be 11", closure: {
                    expect(point.y).to(equal(CGFloat(11)))
                })
                it("point width should be 12", closure: {
                    expect(point.width).to(equal(CGFloat(12)))
                })
                it("point height should be 13", closure: {
                    expect(point.height).to(equal(CGFloat(13)))
                })
            })
        }

        describe("skitch model") {
            describe("skitch type is point", {
                var skicth: Skitch!
                
                beforeEach {
                    let pointJSON: [String: Any] = ["x": 1420.7524752475247, "y": 1596.8316831683169, "width": 273.74257425742576, "height": 273.74257425742579] // Double
                    let skitchJSON: [String: Any] = ["_id": "abcdefg", "num": 3, "coordinate": pointJSON, "type": "point"]
                    skicth = Skitch(skitchJSON: skitchJSON)
                }
                it("id should be abcdefg", closure: {
                    expect(skicth.id).to(equal("abcdefg"))
                })
                it("number should be 3", closure: {
                    expect(skicth.number).to(equal(3))
                })
                it("type should be point", closure: {
                    expect(skicth.type).to(equal(SkitchType.point))
                })
                it("point x should be 1420.7524752475247", closure: {
                    expect(skicth.point.x).to(equal(CGFloat(1420.7524752475247)))
                })
            })
            
            describe("skitch type is rectangle", {
                var skicth: Skitch!
                
                beforeEach {
                    let pointJSON: [String: Any] = ["x": 1420.7524752475247, "y": 1596.8316831683169, "width": 273.74257425742576, "height": 273.74257425742579] // Double
                    let skitchJSON: [String: Any] = ["_id": "abcdefg", "num": 3, "coordinate": pointJSON, "type": "rectangle"]
                    skicth = Skitch(skitchJSON: skitchJSON)
                }
                it("id should be abcdefg", closure: {
                    expect(skicth.id).to(equal("abcdefg"))
                })
                it("number should be 3", closure: {
                    expect(skicth.number).to(equal(3))
                })
                it("type should be rectangle", closure: {
                    expect(skicth.type).to(equal(SkitchType.rectangle))
                })
                it("point should be rectangle", closure: {
                    expect(skicth.point.x).to(equal(CGFloat(1420.7524752475247)))
                })
            })
            
            describe("skitch type is nil", {
                var skicth: Skitch?
                beforeEach {
                    let pointJSON: [String: Any] = ["x": 1420.7524752475247, "y": 1596.8316831683169, "width": 273.74257425742576, "height": 273.74257425742579] // Double
                    let skitchJSON: [String: Any] = ["_id": "abcdefg", "num": 3, "coordinate": pointJSON, "type": "other"]
                    skicth = Skitch(skitchJSON: skitchJSON)
                }
                it("id should be abcdefg", closure: {
                    expect(skicth).to(beNil())
                })
            })
        }
    }
}
