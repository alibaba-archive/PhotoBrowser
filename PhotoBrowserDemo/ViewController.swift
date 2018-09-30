//
//  ViewController.swift
//  PhotoBrowserDemo
//
//  Created by 王卫 on 16/2/16.
//  Copyright © 2016年 Teambition. All rights reserved.
//

import UIKit
import PhotoBrowser

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
        let thumbnail1 = UIImage.init(named: "thumbnail1")
        let photoUrl1 = URL.init(string: "https://pic1.zhimg.com/0f70807392a9f62528b00ec434f5519c_b.png")
        let thumbnail2 = UIImage.init(named: "thumbnail2")
        let photoUrl2 = URL.init(string: "https://pic1.zhimg.com/0f70807392a9f62528b00ec434f5519c_b.png")
        let thumbnail3 = UIImage.init(named: "thumbnail3")
        let photoUrl3 = URL.init(string: "https://pic2.zhimg.com/a5455838750e168d97480d9247537d31_r.jpeg")
        
        let photo = Photo.init(image: nil, title: "Image1fjdkkfadjfkajdkfalkdsfjklasfklaskdfkadsjfklajklsdjfkajsdkfaksdjfkajsdkfjlaksdfjkakdfklak", thumbnailImage: thumbnail1, photoUrl: photoUrl1, fileKey: "abc100")
        let photo2 = Photo.init(image: nil, title: "Image2", thumbnailImage: thumbnail2, photoUrl: photoUrl2, fileKey: "abc101")
        let photo3 = Photo.init(image: nil, title: "Image3", thumbnailImage: thumbnail3, photoUrl: photoUrl3, fileKey: "abc102")

        let item1 = PBActionBarItem(title: "ONE", style: .plain) { (photoBrowser, _) in
            let photos = [photo, photo2]
            photoBrowser.photos = photos
        }
        let item2 = PBActionBarItem(title: "TWO", style: .plain) { (photoBrowser, _) in
//            photoBrowser.enableShare = !photoBrowser.enableShare
            print("item2")
            let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DetailViewController")
            self.photoBrowser?.navigationController?.pushViewController(vc, animated: true)
        }
        let item3 = PBActionBarItem(title: "THREE", style: .plain) { (_, _) in
            print("item3")
        }
        let item4 = PBActionBarItem(title: "FOUR", style: .plain) { (_, _) in
            print("item3")
        }

        photoBrowser = PhotoBrowser()
        if let browser = photoBrowser {
//            browser.isFromPhotoPicker = true

            browser.selectedIndex = [0, 1]
            browser.photos = [photo, photo2, photo3]
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
            photo.imageToSave({ (image) in
                if let image = image {
                    self.saveToAlbum(image)
                }
            })
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
