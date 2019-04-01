//
//  ViewController.swift
//  PhotoBrowserDemo
//
//  Created by WangWei on 16/2/16.
//  Copyright © 2016年 Teambition. All rights reserved.
//

import UIKit
import PhotoBrowser

enum DemoImageConstants {
    static let imageOne = "https://photojournal.jpl.nasa.gov/jpeg/PIA23010.jpg"
    static let imageTwo = "https://photojournal.jpl.nasa.gov/jpeg/PIA22094.jpg"
    static let imageThree = "https://www.jpl.nasa.gov/spaceimages/images/wallpaper/PIA23004-1600x1200.jpg"
    static let gif = "https://www.sample-videos.com/gif/2.gif"
    
    static var thumbnailOne: UIImage? {
        return UIImage(named: "thumbnail_one")
    }
    
    static var thumbnailTwo: UIImage? {
        return UIImage(named: "thumbnail_two")
    }
    
    static var thumbnailThree: UIImage? {
        return UIImage(named: "thumbnail_three")
    }
}

class ViewController: UIViewController {
    var photoBrowser: PhotoBrowser?
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let gesture = UITapGestureRecognizer(target: self, action: #selector(displayPhotoBrowser))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(gesture)
    }

    func saveToAlbum(_ image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
    }

    @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if error == nil {
            print("save success")
        } else {
            print("error: \(String(describing: error))")
        }
    }
}

extension ViewController {
    @objc func displayPhotoBrowser() {
        let photo1 = Photo(image: nil, title: "2412*1713",
                          thumbnailImage: DemoImageConstants.thumbnailOne,
                          photoUrl: URL(string: DemoImageConstants.imageOne),
                          fileKey: nil)
        let photo2 = Photo(image: nil,
                           title: "6000*3500",
                           thumbnailImage: DemoImageConstants.thumbnailTwo,
                           photoUrl: URL(string: DemoImageConstants.imageTwo),
                           fileKey: nil)
        let photo3 = Photo(image: nil,
                           title: "6000*3375",
                           thumbnailImage: DemoImageConstants.thumbnailThree,
                           photoUrl: URL(string: DemoImageConstants.imageThree),
                           fileKey: nil)
        let photo4 = Photo(image: nil,
                           title: "gif",
                           thumbnailImage: nil,
                           photoUrl: URL(string: DemoImageConstants.gif),
                           fileKey: nil)

        let item1 = PBActionBarItem(title: "😄", style: .plain) { (photoBrowser, _) in
            let photos = [photo1, photo2]
            photoBrowser.photos = photos
        }
        let item2 = PBActionBarItem(title: "👌", style: .plain) { (photoBrowser, _) in
//            photoBrowser.enableShare = !photoBrowser.enableShare
            print("item2")
            let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DetailViewController")
            self.photoBrowser?.navigationController?.pushViewController(vc, animated: true)
        }
        let item3 = PBActionBarItem(title: "✈️", style: .plain) { (_, _) in
            print("item3")
        }
        let item4 = PBActionBarItem(title: "🚢", style: .plain) { (_, _) in
            print("item3")
        }

        photoBrowser = PhotoBrowser()
        if let browser = photoBrowser {
//            browser.isFromPhotoPicker = true

            browser.selectedIndex = [0, 1]
            browser.photos = [photo1, photo2, photo3, photo4]
            browser.actionItems = [item1, item2, item3, item4]
            browser.photoBrowserDelegate = self
            browser.currentIndex = 0
//            browser.isFromPhotoPicker = true
            browser.isShowMoreButton = false
            
//            browser.isPreviewMode = false
//            present(browser, animated: true, completion: nil)
            presentPhotoBrowser(browser, fromView: imageView)
        }
    }
}

extension ViewController: PhotoBrowserDelegate {
    func photoBrowser(_ browser: PhotoBrowser, didTapSkitch skitch: Skitch, versionID: String) {
//        print("didTapSkichAtIndex tapped: \(skitch.number)")
    }

    func photoBrowser(_ browser: PhotoBrowser, willShowPhotoAtIndex index: Int) {
//        print("will show photo at index: \(index)")
    }
    
    func photoBrowser(_ browser: PhotoBrowser, didHideSkitchButton isHidden: Bool) {
//        if isHidden {
//            print("hidden")
//        } else {
//            print("visible")
//        }
    }

    func photoBrowser(_ browser: PhotoBrowser, didShowPhotoAtIndex index: Int) {
//        print("photo browser did show at index: \(index)")
//        let points1 = ["x": 100.0, "y": 50.0, "width": 50.0, "height": 50.0]
        let points21 = ["x": 0, "y": 0, "width": 20.0, "height": 20.0]
        let points22 = ["x": 230.0, "y": 230.0, "width": 20.0, "height": 20.0]
        let points23 = ["x": 250.0, "y": 250.0, "width": 50.0, "height": 50.0]
        let points3 = ["x": 80.0, "y": 80.0, "width": 10.0, "height": 10.0]
//        browser.updatePhotoSkitch(at: 0, skitches: [["_id": "120", "num": 1, "type": "point", "coordinate": points1]], versionID: "kkk")
        browser.updatePhotoSkitch(at: 1, skitches: [["_id": "121", "num": 2, "type": "point", "coordinate": points21],
                                                    ["_id": "122", "num": 3, "type": "point", "coordinate": points22],
                                                    ["_id": "123", "num": 4, "type": "point", "coordinate": points23]], versionID: "ggg")
        browser.updatePhotoSkitch(at: 2, skitches: [["_id": "124", "num": 3, "type": "point", "coordinate": points3]], versionID: "zzz")
    }
    
    func dismissPhotoBrowser(_ photoBrowser: PhotoBrowser) {
        dismissPhotoBrowser(toView: imageView)
    }
    
    func photoBrowser(_ browser: PhotoBrowser, longPressOnPhoto photo: Photo, index: Int) {
        let alertController = UIAlertController.init(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        let cancelAction = UIAlertAction.init(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil)
        let saveAction = UIAlertAction.init(title: "Save", style: UIAlertAction.Style.default) {[unowned self] (_) -> Void in
            if let image = photo.imageToSave() {
                self.saveToAlbum(image)
            }
        }
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        self.photoBrowser?.present(alertController, animated: true, completion: nil)
    }

    func photoBrowser(_ browser: PhotoBrowser, willSharePhoto photo: Photo) {
        print("Custom share action here")
    }

    func photoBrowser(_ browser: PhotoBrowser, canSelectPhotoAtIndex index: Int) -> Bool {
        print("canSelectPhotoAtIndex \(index)")
        if index == 2 {
            return false
        }
        return true
    }

    func photoBrowser(_ browser: PhotoBrowser, didSelectPhotoAtIndex index: Int) {
        print("didSelectPhotoAtIndex \(index)")
    }
}
