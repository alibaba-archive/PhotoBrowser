//
//  PhotoPreviewController.swift
//  PhotoBrowser
//
//  Created by WangWei on 16/2/3.
//  Copyright © 2016年 Teambition. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

protocol PhotoPreviewControllerDelegate: class {
    
    var isFullScreenMode: Bool {get set}
    
    func longPressOn(photo: Photo, gesture: UILongPressGestureRecognizer)
}

class PhotoPreviewController: UIViewController {
    
    var index: NSInteger?
    var photo: Photo?
    var scrollView: UIScrollView!
    var imageView: UIImageView!
    var waitingView: WaitingView?
    weak var delegate:PhotoPreviewControllerDelegate?
    
    init(photo: Photo, index: NSInteger) {
        super.init(nibName: nil, bundle: nil)
        self.index = index
        self.photo = photo
        scrollView = UIScrollView()
        imageView = UIImageView()
        extendedLayoutIncludesOpaqueBars = true
        automaticallyAdjustsScrollViewInsets = false
        edgesForExtendedLayout = UIRectEdge.Top
        view.backgroundColor = UIColor.clearColor()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        commonInit()
    }
    
    func commonInit() {
        
        guard let photo = photo else {
            return
        }
        
        scrollView.delegate = self
        scrollView.maximumZoomScale = 1.0
        scrollView.minimumZoomScale = 1.0
        scrollView.frame = view.bounds
        
        scrollView.addSubview(imageView)
        imageView.userInteractionEnabled = true
        
        let doubleTap = UITapGestureRecognizer.init(target: self, action: "handleDoubleTap:")
        doubleTap.numberOfTapsRequired = 2
        imageView.addGestureRecognizer(doubleTap)
        
        let singleTap = UITapGestureRecognizer.init(target: self, action: "handleSingleTap:")
        singleTap.numberOfTapsRequired = 1
        view.addGestureRecognizer(singleTap)
        
        let longPress = UILongPressGestureRecognizer.init(target: self, action: "handleLongPress:")
        imageView.addGestureRecognizer(longPress)
        
        singleTap.requireGestureRecognizerToFail(doubleTap)
        
        if let image = photo.localOriginalPhoto() {
            imageView.image = image
            displayImage()
        } else {
            if let thumbnail = photo.localThumbnailPhoto() {
                imageView.image = thumbnail
                imageView.bounds = CGRectMake(0, 0, thumbnail.size.width, thumbnail.size.height)
                imageView.center = scrollView.center
            }
            if let waitingView = waitingView {
                waitingView.removeFromSuperview()
            }
            
            if let photoUrl = photo.photoUrl {
                waitingView = WaitingView.init(frame: CGRectMake(0, 0, 70, 70))
                
                if let newWaitingView = waitingView {
                    newWaitingView.center = scrollView.center
                    scrollView.addSubview(newWaitingView)
                }
                imageView.kf_setImageWithURL(photoUrl, placeholderImage: photo.localThumbnailPhoto(), optionsInfo: nil, progressBlock: { (receivedSize, totalSize) -> () in
                    let progress = CGFloat(receivedSize) / CGFloat(totalSize)
                    if let waitingView = self.waitingView {
                        waitingView.progress = progress
                    }
                    }, completionHandler: { (image, error, cacheType, imageURL) -> () in
                        if let waitingView = self.waitingView {
                            waitingView.removeFromSuperview()
                        }
                        if let _ = image {
                            self.displayImage()
                        }
                })
            }
        }
        view.addSubview(scrollView)
    }
    
    func handleDoubleTap(sender: UITapGestureRecognizer) {
        if scrollView.zoomScale != scrollView.minimumZoomScale {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
            scrollView.scrollEnabled = false
        } else {
            let touchPoint = sender.locationInView(imageView)
            let newZoomScale:CGFloat = scrollView.maximumZoomScale
            let xsize = scrollView.bounds.size.width / newZoomScale
            let ysize = scrollView.bounds.size.height / newZoomScale
            scrollView.zoomToRect(CGRectMake(touchPoint.x - xsize/2, touchPoint.y - ysize/2, xsize, ysize), animated: true)
            scrollView.scrollEnabled = true
        }
    }
    
    func handleSingleTap(sender: UITapGestureRecognizer) {
        guard let delegate = delegate else {
            return
        }
        delegate.isFullScreenMode = !delegate.isFullScreenMode
    }
    
    func handleLongPress(sender: UILongPressGestureRecognizer) {
        guard let delegate = delegate, let photo = photo else {
            return
        }
        if sender.state == UIGestureRecognizerState.Began {
            delegate.longPressOn(photo, gesture: sender)
        }
    }
    
    func displayImage() {
        guard let image = imageView.image else {
            return
        }
        let scrollViewSize = scrollView.bounds.size
        let widthScale = image.size.width / scrollViewSize.width
        let heightScale = image.size.height / scrollViewSize.height
        let finalScale = max(widthScale, heightScale)
        var width = image.size.width
        var height = image.size.height
        if finalScale > 1 {
            width = width / finalScale
            height = height / finalScale
        }
        imageView.bounds = CGRectMake(0, 0, width, height)
        imageView.center = self.scrollView.center
        scrollView.maximumZoomScale = self.maximumZoomScaleForImage(image)
    }
    
    func centreImageView() {
        
        var newFrame = imageView.frame
        
        if newFrame.size.width < view.bounds.size.width {
            newFrame.origin.x = floor((view.bounds.size.width - newFrame.size.width)/2.0)
        } else {
            newFrame.origin.x = 0
        }
        
        if newFrame.size.height < view.bounds.size.height {
            newFrame.origin.y = floor((view.bounds.size.height - newFrame.size.height)/2.0)
        } else {
            newFrame.origin.y = 0
        }
        
        if !CGRectEqualToRect(imageView.frame, newFrame) {
            imageView.frame = newFrame
        }
        
    }
    
    func maximumZoomScaleForImage(image: UIImage) -> CGFloat {
        var maxZoomScale:CGFloat = 2.5
        
        let imageSize = image.size
        let boundSize = view.bounds.size
        
        let xScale = boundSize.width / imageSize.width
        let yScale = boundSize.height / imageSize.height
        
        let minScale = min(xScale, yScale)
        let maxScale = max(xScale, yScale)
        
        if minScale > 1 {
            maxZoomScale = max(maxZoomScale, maxScale)
        } else {
            maxZoomScale = max(maxZoomScale, maxScale / minScale)
        }
        return maxZoomScale
    }

}

extension PhotoPreviewController:UIScrollViewDelegate  {
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        centreImageView()
    }
    
}

