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

    @IBOutlet weak var tableView: UITableView!
    
    var photoBrowser: PhotoBrowser?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func saveToAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, "image:didFinishSavingWithError:contextInfo:", nil)
    }
    
    func image(image: UIImage, didFinishSavingWithError error:NSError?, contextInfo:UnsafePointer<Void>) {
        if error == nil {
            print("save success")
        } else {
            print(error)
        }
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)
        cell.textLabel?.text = "\(indexPath.row)"
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        switch indexPath.row {
        case 0:
            showPhotoBrowser()
        default:
            print("default")
        }
    }
    
}

extension ViewController {
    func showPhotoBrowser() {
        let thumbnail1 = UIImage.init(named: "thumbnail1")
        let photoUrl1 = NSURL.init(string: "https://pic4.zhimg.com/453d7ebcdb0c4494e60fa07d09a83a83_r.jpeg")
        
        let thumbnail2 = UIImage.init(named: "thumbnail2")
        let photoUrl2 = NSURL.init(string: "https://pic1.zhimg.com/0f70807392a9f62528b00ec434f5519c_b.png")
        
        let thumbnail3 = UIImage.init(named: "thumbnail3")
        let photoUrl3 = NSURL.init(string: "https://pic2.zhimg.com/a5455838750e168d97480d9247537d31_r.jpeg")
        
        let item1 = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.Bookmarks, target: self, action: nil)
        item1.tintColor = UIColor.blackColor()
        
        let photo = Photo.init(image: nil, thumbnailImage: thumbnail1, photoUrl: photoUrl1)
        let photo2 = Photo.init(image: nil, thumbnailImage: thumbnail2, photoUrl: photoUrl2)
        let photo3 = Photo.init(image: nil, thumbnailImage: thumbnail3, photoUrl: photoUrl3)
        photoBrowser = PhotoBrowser()
        guard let browser = photoBrowser else {
            return
        }
        browser.toolbarItems = [item1]
        browser.photoBrowserDelegate = self
        browser.currentIndex = 0
        browser.photos = [photo, photo2, photo3]
        self.navigationController?.pushViewController(browser, animated: true)
    }
}

extension ViewController: PhotoBrowserDelegate {
    
    func longPressOn(photo: Photo, gesture: UILongPressGestureRecognizer) {
        guard let imageView = gesture.view as? UIImageView else {
            return
        }
        let alertController = UIAlertController.init(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        let cancelAction = UIAlertAction.init(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
        let saveAction = UIAlertAction.init(title: "Save", style: UIAlertActionStyle.Default) {[unowned self] (action) -> Void in
            if let image = imageView.image {
                self.saveToAlbum(image)
            }
        }
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        self.photoBrowser?.presentViewController(alertController, animated: true, completion: nil)
    }
}


















