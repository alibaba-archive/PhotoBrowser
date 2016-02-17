//
//  PhotoBrowser.swift
//  PhotoBrowser
//
//  Created by WangWei on 16/2/3.
//  Copyright © 2016年 Teambition. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

public protocol PhotoBrowserDelegate: class {
    func longPressOn(photo: Photo, gesture: UILongPressGestureRecognizer)
}

public class PhotoBrowser: UIPageViewController {
    
    var isFullScreen = false
    public var currentIndex: Int = 0
    
    public var photos: [Photo]?
    public var toolbar: UIToolbar?
    public weak var photoBrowserDelegate: PhotoBrowserDelegate?
    
    public var currentPhoto: Photo? {
        return photos?[currentIndex]
    }
    
    public override init(transitionStyle style: UIPageViewControllerTransitionStyle, navigationOrientation: UIPageViewControllerNavigationOrientation, options: [String : AnyObject]?) {
        super.init(transitionStyle: style, navigationOrientation: navigationOrientation, options: options)
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public convenience init() {
        self.init(transitionStyle: UIPageViewControllerTransitionStyle.Scroll, navigationOrientation: UIPageViewControllerNavigationOrientation.Horizontal, options: [UIPageViewControllerOptionInterPageSpacingKey:20])
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.whiteColor()
        extendedLayoutIncludesOpaqueBars = true
        automaticallyAdjustsScrollViewInsets = false
        edgesForExtendedLayout = UIRectEdge.Top
        dataSource = self
        delegate = self
        
        if let photos = photos {
            let initPage = PhotoPreviewController(photo: photos[currentIndex], index: currentIndex)
            initPage.delegate = self
            setViewControllers([initPage], direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)
        }
        updateNavigationBarTitle()
        updateToolbar()
    }
}

extension PhotoBrowser {
    
    public override func prefersStatusBarHidden() -> Bool {
        return isFullScreen
    }
    
    func updateNavigationBarTitle() {
        guard let photos = photos else {
            return
        }
        title = "\(currentIndex + 1) / \(photos.count)"
    }
    
    func updateToolbar() {
        if toolbar == nil {
            toolbar = UIToolbar.init(frame: CGRectMake(0, view.bounds.size.height - 44, view.bounds.size.width, 44))
        }
        guard let toolbar = toolbar, let items = toolbarItems where items.count > 0 else {
            return
        }
        let itemsArray = layoutToolbar(items)
        toolbar.setItems(itemsArray, animated: false)
        toolbar.tintColor = UIColor.whiteColor()
        view.addSubview(toolbar)
    }
    
    func layoutToolbar(items: [UIBarButtonItem]) -> [UIBarButtonItem]? {
        let flexSpace = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: self, action: nil)
        var itemsArray = [UIBarButtonItem]()
        if items.count == 1, let first = items.first {
            itemsArray = [flexSpace, first, flexSpace]
        } else if items.count == 2, let first = items.first, let last = items.last {
            itemsArray = [flexSpace, first, flexSpace, flexSpace, last, flexSpace]
        } else {
            for item in items {
                itemsArray.append(item)
                itemsArray.append(flexSpace)
            }
            if itemsArray.count > 0 {
                itemsArray.removeLast()
            }
        }
        return itemsArray
    }
    
}

extension PhotoBrowser: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    public func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        guard let viewController = viewController as? PhotoPreviewController else {
            return nil
        }
        guard let index = viewController.index, let photos = photos else {
            return nil
        }
        if index < 1 {
            return nil
        }
        let prePhoto = photos[index - 1]
        let preViewController = PhotoPreviewController(photo: prePhoto, index: index - 1)
        preViewController.delegate = self
        return preViewController
    }
    
    public func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        guard let viewController = viewController as? PhotoPreviewController else {
            return nil
        }
        guard let index = viewController.index else {
            return nil
        }
        guard let photos = photos else {
            return nil
        }
        if index + 1 > photos.count - 1 {
            return nil
        }
        let nextPhoto = photos[index + 1]
        let nextViewController = PhotoPreviewController(photo: nextPhoto, index: index + 1)
        nextViewController.delegate = self
        
        return nextViewController
    }
    
    public func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            guard let currentViewController = pageViewController.viewControllers?.last as? PhotoPreviewController else {
                return
            }
            if let index = currentViewController.index {
                currentIndex = index
                updateNavigationBarTitle()
            }
        }
    }
}

extension PhotoBrowser: PhotoPreviewControllerDelegate {
    
    var isFullScreenMode: Bool {
        get {
            return isFullScreen
        }
        
        set(newValue) {
            isFullScreen = newValue
            self.navigationController?.setNavigationBarHidden(newValue, animated: true)
            UIView.animateWithDuration(0.25) { () -> Void in
                self.view.backgroundColor = newValue ? UIColor.blackColor() : UIColor.whiteColor()
                if let toolbar = self.toolbar {
                    var frame = toolbar.frame
                    let offset = newValue ? frame.size.height : -frame.size.height
                    frame.origin.y = frame.origin.y + offset
                    toolbar.frame = frame
                }
            }
        }
    }
    
    func longPressOn(photo: Photo, gesture: UILongPressGestureRecognizer) {
        guard let browserDelegate = photoBrowserDelegate else {
            return
        }
        browserDelegate.longPressOn(photo, gesture: gesture)
    }
    
}
