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
    func longPressOn(_ photo: Photo, gesture: UILongPressGestureRecognizer)
    func didTapOnBackground()
}

class PhotoPreviewController: UIViewController {
    
    var index: NSInteger?
    var photo: Photo?
    var scrollView: UIScrollView!
    var imageView: UIImageView!
    var waitingView: WaitingView?
    weak var delegate:PhotoPreviewControllerDelegate?
    
    var imageViewLeadingConstraint: NSLayoutConstraint?
    var imageViewTrailingConstraint: NSLayoutConstraint?
    var imageViewTopConstraint: NSLayoutConstraint?
    var imageViewBottomConstraint: NSLayoutConstraint?
    
    init(photo: Photo, index: NSInteger) {
        super.init(nibName: nil, bundle: nil)
        self.index = index
        self.photo = photo
        scrollView = UIScrollView()
        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        extendedLayoutIncludesOpaqueBars = true
        automaticallyAdjustsScrollViewInsets = false
        edgesForExtendedLayout = UIRectEdge.top
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        commonInit()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if scrollView.zoomScale != scrollView.minimumZoomScale {
            scrollView.zoomScale = scrollView.minimumZoomScale
        }
        coordinator.animate(alongsideTransition: { (_) -> Void in
            self.updateZoom()
            if let waitingView = self.waitingView {
                waitingView.center = CGPoint(x: size.width / 2, y: size.height / 2)
            }
            }, completion: nil)
    }
    
    func commonInit() {
        
        guard let photo = photo else {
            return
        }
        view.backgroundColor = UIColor.clear
        
        scrollView.delegate = self
        scrollView.maximumZoomScale = 3.0
        scrollView.minimumZoomScale = 1.0
        scrollView.isScrollEnabled = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        scrollView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        initializeConstraint()
        imageView.isUserInteractionEnabled = true
        
        let doubleTap = UITapGestureRecognizer.init(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        imageView.addGestureRecognizer(doubleTap)
        
        let singleTap = UITapGestureRecognizer.init(target: self, action: #selector(handleSingleTap(_:)))
        singleTap.numberOfTapsRequired = 1
        imageView.addGestureRecognizer(singleTap)
        
        let longPress = UILongPressGestureRecognizer.init(target: self, action: #selector(handleLongPress(_:)))
        imageView.addGestureRecognizer(longPress)

        let backgroudSingleTap = UITapGestureRecognizer.init(target: self, action: #selector(handleBackgroundSingleTap(_:)))
        backgroudSingleTap.numberOfTapsRequired = 1
        view.addGestureRecognizer(backgroudSingleTap)
        
        singleTap.require(toFail: doubleTap)
        
        
        if let image = photo.localOriginalPhoto() {
            imageView.image = image
            updateZoom()
        } else {
            if let thumbnail = photo.localThumbnailPhoto() {
                imageView.image = thumbnail
                updateZoom()
            }
            if let waitingView = waitingView {
                waitingView.removeFromSuperview()
            }
            
            if let photoUrl = photo.photoUrl {
                waitingView = WaitingView.init(frame: CGRect(x: 0, y: 0, width: 70, height: 70))
                
                if let newWaitingView = waitingView {
                    newWaitingView.center = view.center
                    view.addSubview(newWaitingView)
                }
                imageView.kf_setImage(with: photoUrl, placeholder: photo.localThumbnailPhoto(), options: nil, progressBlock: { (receivedSize, totalSize) -> () in
                    let progress = CGFloat(receivedSize) / CGFloat(totalSize)
                    if let waitingView = self.waitingView {
                        waitingView.progress = progress
                    }
                    }, completionHandler: { (image, error, cacheType, imageURL) -> () in
                        if let waitingView = self.waitingView {
                            waitingView.removeFromSuperview()
                        }
                        if let _ = image {
                            self.updateZoom()
                        }
                })
            }
        }
    }
    
    func initializeConstraint() {
        //layout scrollView in view
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[scrollView]-0-|", options: [], metrics: nil, views: ["scrollView":scrollView]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[scrollView]-0-|", options: [], metrics: nil, views: ["scrollView":scrollView]))
        
        //layout imageView in scrollView
        imageViewLeadingConstraint = NSLayoutConstraint(item: imageView, attribute: .leading, relatedBy: .equal, toItem: scrollView, attribute: .leading, multiplier: 1.0, constant: 0)
        imageViewTopConstraint = NSLayoutConstraint(item: imageView, attribute: .top, relatedBy: .equal, toItem: scrollView, attribute: .top, multiplier: 1.0, constant: 0)
        imageViewTrailingConstraint = NSLayoutConstraint(item: scrollView, attribute: .trailing, relatedBy: .equal, toItem: imageView, attribute: .trailing, multiplier: 1.0, constant: 0)
        imageViewBottomConstraint = NSLayoutConstraint(item: scrollView, attribute: .bottom, relatedBy: .equal, toItem: imageView, attribute: .bottom, multiplier: 1.0, constant: 0)
        if let lead = imageViewLeadingConstraint, let trail = imageViewTrailingConstraint, let top = imageViewTopConstraint, let bottom = imageViewBottomConstraint {
            scrollView.addConstraints([lead, trail, top, bottom])
        }
    }
    
    
    func updateZoom() {
        guard let image = imageView.image else {
            return
        }
        //Zoom to show as much image as possible unless image is smaller than screen
        var minZoom = min(view.bounds.size.width / image.size.width, view.bounds.size.height / image.size.height)
        minZoom = min(minZoom, 1)
        scrollView.minimumZoomScale = minZoom

        //Force scrollViewDidZoom fire if zoom did not change
        if scrollView.zoomScale == minZoom {
            minZoom += 0.000001
        }
        scrollView.zoomScale = minZoom
    }
    
    
    func updateConstraint() {
        
        guard let image = imageView.image else {
            return
        }
        
        guard let lead = imageViewLeadingConstraint, let trail = imageViewTrailingConstraint, let top = imageViewTopConstraint, let bottom = imageViewBottomConstraint else {
            return
        }
        
        let imageWidth = image.size.width
        let imageHeight = image.size.height
        
        let viewWidth = view.bounds.size.width
        let viewHeight = view.bounds.size.height
        
        //center image if it is smaller than screen
        var hPadding = (viewWidth - scrollView.zoomScale * imageWidth) / 2
        hPadding = max(hPadding, 0)
        
        var vPadding = (viewHeight - scrollView.zoomScale * imageHeight) / 2
        vPadding = max(vPadding, 0)
        
        lead.constant = hPadding
        trail.constant = hPadding
        top.constant = vPadding
        bottom.constant = vPadding
        
        view.layoutIfNeeded()
    }
    
    
    func zoomScaleForDoubleTap() -> CGFloat {
        guard let image = imageView.image else {
            return scrollView.minimumZoomScale
        }
        
        //Zoom to fit the smaller edge to screen if possible
        //but at least double the minimumZoomScale
        
        var maxZoomScale: CGFloat = 2
        
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
        return maxZoomScale * scrollView.minimumZoomScale
    }

}

extension PhotoPreviewController {
    
    func handleDoubleTap(_ sender: UITapGestureRecognizer) {
        if scrollView.zoomScale != scrollView.minimumZoomScale {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        } else {
            let touchPoint = sender.location(in: imageView)
            let newZoomScale = zoomScaleForDoubleTap()
            let xsize = scrollView.bounds.size.width / newZoomScale
            let ysize = scrollView.bounds.size.height / newZoomScale
            scrollView.zoom(to: CGRect(x: touchPoint.x - xsize/2, y: touchPoint.y - ysize/2, width: xsize, height: ysize), animated: true)
        }
    }
    
    func handleSingleTap(_ sender: UITapGestureRecognizer) {
        guard let delegate = delegate else {
            return
        }
        delegate.isFullScreenMode = !delegate.isFullScreenMode
    }
    
    func handleLongPress(_ sender: UILongPressGestureRecognizer) {
        guard let delegate = delegate, let photo = photo else {
            return
        }
        if sender.state == UIGestureRecognizerState.began {
            delegate.longPressOn(photo, gesture: sender)
        }
    }

    func handleBackgroundSingleTap(_ sender: UITapGestureRecognizer) {
        delegate?.didTapOnBackground()
    }
}

extension PhotoPreviewController:UIScrollViewDelegate  {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        if scrollView.zoomScale - scrollView.minimumZoomScale < 0.01 {
            scrollView.isScrollEnabled = false
        } else {
            scrollView.isScrollEnabled = true
        }
        updateConstraint()
    }
}

