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
import Photos

let ToolbarHeight: CGFloat = 44
let PadToolbarItemSpace: CGFloat = 72

public protocol PhotoBrowserDelegate: class {
    func dismissPhotoBrowser(_ photoBrowser: PhotoBrowser)
    func longPressOnImage(_ gesture: UILongPressGestureRecognizer)
    func photoBrowser(_ browser: PhotoBrowser, didShowPhotoAtIndex index: Int)
    func photoBrowser(_ browser: PhotoBrowser, willSharePhoto photo: Photo)
    func photoBrowser(_ browser: PhotoBrowser, canSelectPhotoAtIndex index: Int) -> Bool
    func photoBrowser(_ browser: PhotoBrowser, didSelectPhotoAtIndex index: Int)
}

public extension PhotoBrowserDelegate {
    func dismissPhotoBrowser(_ photoBrowser: PhotoBrowser) {
        photoBrowser.dismiss(animated: false, completion: nil)
    }
    func longPressOnImage(_ gesture: UILongPressGestureRecognizer) {}
    func photoBrowser(_ browser: PhotoBrowser, willShowPhotoAtIndex index: Int) {}
    func photoBrowser(_ browser: PhotoBrowser, didShowPhotoAtIndex index: Int) {}
    func photoBrowser(_ browser: PhotoBrowser, willSharePhoto photo: Photo) {
        browser.defaultShareAction()
    }
    func photoBrowser(_ browser: PhotoBrowser, canSelectPhotoAtIndex index: Int) -> Bool {
        return true
    }
    func photoBrowser(_ browser: PhotoBrowser, didSelectPhotoAtIndex index: Int) {}
}

open class PhotoBrowser: UIPageViewController {
    
    var isFullScreen = false
    var toolbarHeightConstraint: NSLayoutConstraint?
    var toolbarBottomConstraint: NSLayoutConstraint?
    var navigationTopConstraint: NSLayoutConstraint?
    var navigationHeightConstraint: NSLayoutConstraint?
    
    var headerView: PBNavigationBar?
    
    open var photos: [Photo]? {
        didSet {
            if let photos = photos {
                if photos.count == 0 {
                    leftButtonTap(nil)
                } else {
                    currentIndex = min(currentIndex, photos.count - 1)
                    let initPage = PhotoPreviewController(photo: photos[currentIndex], index: currentIndex)
                    initPage.delegate = self
                    setViewControllers([initPage], direction: UIPageViewControllerNavigationDirection.forward, animated: false, completion: nil)
                    updateNavigationBarTitle()
                }
            }
        }
    }

    open var assets: [PHAsset]? {
        didSet {
            if  let assets = assets {
                var p: [Photo] = []
                for asset in assets {
                    p.append(Photo(asset: asset))
                }
                self.photos = p
            }
        }
    }

    open var toolbar: PBToolbar?
    open var backgroundColor = UIColor.black
    open weak var photoBrowserDelegate: PhotoBrowserDelegate?
    open var enableShare = true {
        didSet {
            headerView?.rightButton.isHidden = !enableShare
        }
    }
    
    open var currentIndex: Int = 0
    open var currentPhoto: Photo? {
        return photos?[currentIndex]
    }
    fileprivate lazy var progressView: UIProgressView = {
        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 2)
        progressView.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
        return progressView
    }()

    open var actionItems = [PBActionBarItem]() {
        willSet {
            for item in newValue {
                item.photoBrowser = self
            }
        }
        didSet {
            toolbarItems = actionItems.map { $0.barButtonItem }
            updateToolbar()
        }
    }

    open var isFromPhotoPicker: Bool = false
    open var selectedIndex: [Int] = []

    public override init(transitionStyle style: UIPageViewControllerTransitionStyle, navigationOrientation: UIPageViewControllerNavigationOrientation, options: [String : Any]?) {
        super.init(transitionStyle: style, navigationOrientation: navigationOrientation, options: options)
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public convenience init() {
        self.init(transitionStyle: UIPageViewControllerTransitionStyle.scroll, navigationOrientation: UIPageViewControllerNavigationOrientation.horizontal, options: [UIPageViewControllerOptionInterPageSpacingKey:20])
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = backgroundColor
        extendedLayoutIncludesOpaqueBars = true
        automaticallyAdjustsScrollViewInsets = false
        edgesForExtendedLayout = UIRectEdge.top
        dataSource = self
        delegate = self
        self.updateToolbar()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isFullScreenMode = false
    }
    
    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        updateToolbar()
    }
    
    open override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
}

// Mark: -Progress bar update

public extension PhotoBrowser {
    func beginUpdate() {
        dataSource = nil
        toolbar?.addSubview(progressView)
    }
    func endUpdate() {
        dataSource = self
        progressView.removeFromSuperview()
    }
    func update(progress value: Float) {
        progressView.progress = value
    }
}

public extension PhotoBrowser {
    func setCurrentIndex(to index: Int) {
        if let photos = photos {
            currentIndex = index
            let initPage = PhotoPreviewController(photo: photos[index], index: index)
            initPage.delegate = self
            setViewControllers([initPage], direction: UIPageViewControllerNavigationDirection.forward, animated: false, completion: nil)
            updateNavigationBarTitle()
        }
    }
}

extension PhotoBrowser {
    
    open override var prefersStatusBarHidden : Bool {
        return isFullScreen
    }
    
    open override var preferredStatusBarUpdateAnimation : UIStatusBarAnimation {
        return .fade
    }
    
    func updateNavigationBarTitle() {
        guard let photos = photos else {
            return
        }
        
        if headerView == nil {
            headerView = PBNavigationBar()
            if let headerView = headerView {
                headerView.isFromPhotoPicker = isFromPhotoPicker
                headerView.alpha = 0
                view.addSubview(headerView)
                headerView.translatesAutoresizingMaskIntoConstraints = false
                view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[headerView]-0-|", options: [], metrics: nil, views: ["headerView":headerView]))
                headerView.addConstraint(NSLayoutConstraint(item: headerView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 64))
                view.addConstraint(NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: headerView, attribute: .top, multiplier: 1.0, constant: 0))
                
                headerView.leftButton.addTarget(self, action: #selector(leftButtonTap(_:)), for: .touchUpInside)
                headerView.rightButton.addTarget(self, action: #selector(rightButtonTap(_:)), for: .touchUpInside)
                headerView.imageSelected = selectedIndex.contains(currentIndex)
            }
        }
        if let headerView = headerView {
            headerView.titleLabel.text = photos[currentIndex].title
            headerView.indexLabel.text = "\(currentIndex + 1)/\(photos.count)"
            headerView.imageSelected = selectedIndex.contains(currentIndex)
        }
    }
    
    func updateToolbar() {
        guard let items = toolbarItems , items.count > 0 else {
            return
        }
        if toolbar == nil {
            toolbar = PBToolbar()
            if let toolbar = toolbar {
                toolbar.alpha = 0
                view.addSubview(toolbar)
                toolbar.translatesAutoresizingMaskIntoConstraints = false
                view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[toolbar]-0-|", options: [], metrics: nil , views: ["toolbar":toolbar]))
                view.addConstraint(NSLayoutConstraint(item: bottomLayoutGuide, attribute: .top, relatedBy: .equal, toItem: toolbar, attribute: .bottom, multiplier: 1.0, constant: 0))
                toolbar.addConstraint(NSLayoutConstraint(item: toolbar, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: ToolbarHeight))
            }
        }
        if let toolbar = toolbar {
            let itemsArray = layoutToolbar(items)
            toolbar.setItems(itemsArray, animated: false)
        }
    }
    
    func layoutToolbar(_ items: [UIBarButtonItem]) -> [UIBarButtonItem]? {
        let flexSpace = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil)
        let fixedSpace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: self, action: nil)
        fixedSpace.width = PadToolbarItemSpace
        var itemsArray = [UIBarButtonItem]()
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            itemsArray.append(flexSpace)
            for item in items {
                itemsArray.append(item)
                itemsArray.append(fixedSpace)
            }
            itemsArray.removeLast()
            itemsArray.append(flexSpace)
        } else {
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
        }
        return itemsArray
    }
    
    func leftButtonTap(_ sender: AnyObject?) {
        if let delegate = photoBrowserDelegate {
            delegate.dismissPhotoBrowser(self)
        } else {
            dismissPhotoBrowser()
        }
    }

    func rightButtonTap(_ sender: AnyObject) {
        guard let photo = currentPhoto else {
            return
        }
        if let delegate = photoBrowserDelegate {
            if isFromPhotoPicker {
                if delegate.photoBrowser(self, canSelectPhotoAtIndex: currentIndex) {
                    delegate.photoBrowser(self, didSelectPhotoAtIndex: currentIndex)
                    if let i = selectedIndex.index(of: currentIndex) {
                        selectedIndex.remove(at: i)
                        if let headerView = headerView {
                            headerView.imageSelected = false
                        }
                    } else {
                        selectedIndex.append(currentIndex)
                        if let headerView = headerView {
                            headerView.imageSelected = true
                        }
                    }
                }
            } else {
                delegate.photoBrowser(self, willSharePhoto: photo)
            }
        } else {
            defaultShareAction()
        }
    }

    public func defaultShareAction() {
        if let image = currentImageView()?.image, let button = headerView?.rightButton {
            let activityController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
            if UIDevice.current.userInterfaceIdiom == .pad {
                activityController.modalPresentationStyle = .popover
                activityController.popoverPresentationController?.sourceView = view
                let frame = view.convert(button.frame, from: button.superview)
                activityController.popoverPresentationController?.sourceRect = frame
            }
            present(activityController, animated: true, completion: nil)
        }
    }
}

extension PhotoBrowser: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    open func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
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
    
    open func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
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

    open func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            guard let currentViewController = pageViewController.viewControllers?.last as? PhotoPreviewController else {
                return
            }
            if let index = currentViewController.index {
                currentIndex = index
                photoBrowserDelegate?.photoBrowser(self, didShowPhotoAtIndex: index)
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
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.setNeedsStatusBarAppearanceUpdate()
                self.view.backgroundColor = newValue ? UIColor.black : self.backgroundColor
                self.headerView?.alpha = newValue ? 0 : 1
                self.toolbar?.alpha = newValue ? 0 : 1
            }) 
        }
    }
    
    func longPressOn(_ photo: Photo, gesture: UILongPressGestureRecognizer) {
        photoBrowserDelegate?.longPressOnImage(gesture)
    }

    func didTapOnBackground() {
        if let delegate = photoBrowserDelegate {
            delegate.dismissPhotoBrowser(self)
        } else {
            dismissPhotoBrowser()
        }
    }
}

extension PhotoBrowser {
    func currentImageView() -> UIImageView? {
        guard let page = viewControllers?.last as? PhotoPreviewController else {
            return nil
        }
        return page.imageView
    }
}
