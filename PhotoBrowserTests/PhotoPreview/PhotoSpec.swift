//
//  PhotoSpec.swift
//  PhotoBrowserTests
//
//  Created by zouliangming on 2018/8/7.
//  Copyright © 2018年 Teambition. All rights reserved.
//

import XCTest
import Quick
import Nimble
@testable import PhotoBrowser

class PhotoSpec: QuickSpec {
    
    override func spec() {
        describe("photo model") {
            var photo: Photo!
            let image = UIImage()
            let title = "photoTitle"
            let thumb = UIImage()
            let url = URL(string: "www.teambition.com")
            let thubmUrl = URL(string: "www.teambition.com/thumb")
            let fileKey = "fileKey"
            let object = "any object"
            
            beforeEach {
                photo = Photo(image: image, title: title, thumbnailImage: thumb, photoUrl: url, thumbnailUrl: thubmUrl, object: object, fileKey: fileKey)
            }
            it("photo image be image", closure: {
                expect(photo.image).to(equal(image))
            })
            it("photo title be title", closure: {
                expect(photo.title).to(equal(title))
            })
            it("photo thumb be thumb", closure: {
                expect(photo.thumbnailImage).to(equal(thumb))
            })
            it("photoUrl be url", closure: {
                expect(photo.photoUrl).to(equal(url))
            })
            it("photo thubmUrl be thubmUrl", closure: {
                expect(photo.thumbnailUrl).to(equal(thubmUrl))
            })
            it("photo fileKey be fileKey", closure: {
                expect(photo.fileKey).to(equal(fileKey))
            })
            it("photo object not be nil", closure: {
                expect(photo.object).notTo(beNil())
            })
            
            it("photo localOriginalPhoto not be nil", closure: {
                expect(photo.localOriginalPhoto()).notTo(beNil())
            })
            it("photo localThumbnailPhoto not be nil", closure: {
                expect(photo.localThumbnailPhoto()).notTo(beNil())
            })
            it("photo localThumbnailPhoto not be nil", closure: {
                expect(photo.imageToSave()).notTo(beNil())
            })
        }
    }
}
