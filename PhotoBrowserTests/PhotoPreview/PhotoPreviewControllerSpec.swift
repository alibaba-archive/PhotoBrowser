//
//  PhotoPreviewControllerSpec.swift
//  PhotoBrowserTests
//
//  Created by zouliangming on 2018/8/7.
//  Copyright © 2018年 Teambition. All rights reserved.
//

import XCTest
import Quick
import Nimble
@testable import PhotoBrowser

class PhotoPreviewControllerSpec: QuickSpec {
    override func spec() {
        describe("photo preview vc") {
            var photo: Photo!
            let image = UIImage()
            let title = "photoTitle"
            let thumb = UIImage()
            let url = URL(string: "www.teambition.com")
            let thubmUrl = URL(string: "www.teambition.com/thumb")
            let fileKey = "fileKey"
            let object = "any object"
            var photoPreview: PhotoPreviewController!
            
            beforeEach {
                photo = Photo(image: image, title: title, thumbnailImage: thumb, photoUrl: url, thumbnailUrl: thubmUrl, object: object, fileKey: fileKey)
                photoPreview = PhotoPreviewController(photo: photo, index: 0)
            }
            it("photo preview's phtoto and index", closure: {
                expect(photoPreview.photo).notTo(beNil())
                expect(photoPreview.index).to(equal(0))
            })
        }
    }
}
