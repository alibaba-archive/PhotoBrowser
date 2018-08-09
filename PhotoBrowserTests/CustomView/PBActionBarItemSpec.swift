//
//  PBActionBarItemSpec.swift
//  PhotoBrowserTests
//
//  Created by zouliangming on 2018/8/7.
//  Copyright © 2018年 Teambition. All rights reserved.
//

import XCTest
import Quick
import Nimble
@testable import PhotoBrowser

class PBActionBarItemSpec: QuickSpec {
    override func spec() {
        describe("PBActionBarItem") {
            describe("PBActionBarItem title") {
                var barItem: PBActionBarItem!
                var title: String!
                beforeEach {
                    title = "barItemTitle"
                    barItem = PBActionBarItem(title: title, style: .done, action: nil)
                }
                it("PBActionBarItem title should be barItemTitle", closure: {
                    expect(barItem.barButtonItem.title).to(equal(title))
                })
            }
        }
    }
}
