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

public protocol PhotoBrowserDelegate: class {
    func dismissPhotoBrowser(_ photoBrowser: PhotoBrowser)
    func photoBrowser(_ browser: PhotoBrowser, longPressOnPhoto photo: Photo, index: Int)
    func photoBrowser(_ browser: PhotoBrowser, didShowPhotoAtIndex index: Int)
    func photoBrowser(_ browser: PhotoBrowser, willSharePhoto photo: Photo)
    func photoBrowser(_ browser: PhotoBrowser, canSelectPhotoAtIndex index: Int) -> Bool
    func photoBrowser(_ browser: PhotoBrowser, didSelectPhotoAtIndex index: Int)
    func photoBrowser(_ browser: PhotoBrowser, didTapSkitch skitch: Skitch, versionID: String)
    func photoBrowser(_ browser: PhotoBrowser, didHideSkitchButton isHidden: Bool)
    func didShowMoreFiles(_ browser: PhotoBrowser)
}

public extension PhotoBrowserDelegate {
    func dismissPhotoBrowser(_ photoBrowser: PhotoBrowser) {
        photoBrowser.dismiss(animated: false, completion: nil)
    }
    func photoBrowser(_ browser: PhotoBrowser, longPressOnPhoto photo: Photo, index: Int) {}
    func photoBrowser(_ browser: PhotoBrowser, didShowPhotoAtIndex index: Int) {}
    func photoBrowser(_ browser: PhotoBrowser, willSharePhoto photo: Photo) {
        browser.defaultShareAction()
    }
    func photoBrowser(_ browser: PhotoBrowser, canSelectPhotoAtIndex index: Int) -> Bool {
        return true
    }
    func photoBrowser(_ browser: PhotoBrowser, didSelectPhotoAtIndex index: Int) {}
    func photoBrowser(_ browser: PhotoBrowser, didTapSkitch skitch: Skitch, versionID: String) {}
    func photoBrowser(_ browser: PhotoBrowser, didHideSkitchButton isHidden: Bool) {}
    func didShowMoreFiles(_ browser: PhotoBrowser) {}
}

open class PhotoBrowser: UIPageViewController {
    open var photos: [Photo]? {
        didSet {
            loadPhotos()
        }
    }
    
    private var isFullScreen = false
    private var headerView: PBNavigationBar?
    
    // Support Skitch
    open var isSkitchButtonHidden: Bool = true
    private var isSkitchesSetted: Bool = false
    open var skitchesDictionary: [Int: [[String: Any]]] = [:]

    open var assets: [PHAsset]? {
        didSet {
            if  let assets = assets {
                self.photos = assets.map { Photo(asset: $0) }
            }
        }
    }

    open var toolbar: PBToolbar?
    open var backgroundColor = UIColor.black
    open weak var photoBrowserDelegate: PhotoBrowserDelegate?
    open var enableShare: Bool = true {
        didSet {
            headerView?.rightButton.isHidden = !enableShare
            headerView?.updateShareStatus(enableShare)
        }
    }
    open var enableSelect: Bool = true {
        didSet {
            headerView?.rightButton.isHidden = !enableSelect
        }
    }
    
    open var currentIndex: Int = 0
    open var currentPhoto: Photo? {
        return photos?[currentIndex]
    }
    private lazy var progressView: UIProgressView = {
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

    open var isShowMoreButton: Bool = true {
        didSet {
            headerView?.isShowMoreButton = isShowMoreButton
        }
    }
    open var isFromPhotoPicker: Bool = false
    open var isPreviewMode: Bool = false
    open var selectedIndex: [Int] = []

    // MARK: - init methods
    public override init(transitionStyle style: UIPageViewController.TransitionStyle, navigationOrientation: UIPageViewController.NavigationOrientation, options: [UIPageViewController.OptionsKey: Any]? = nil) {
        super.init(transitionStyle: style, navigationOrientation: navigationOrientation, options: options)
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public convenience init() {
        self.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: [UIPageViewController.OptionsKey.interPageSpacing: 20])
    }
    
    // MARK: - life cycle
    open override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = backgroundColor
        extendedLayoutIncludesOpaqueBars = true
        automaticallyAdjustsScrollViewInsets = false
        edgesForExtendedLayout = .top
        modalPresentationStyle = .custom
        dataSource = self
        delegate = self
        updateToolbar()
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
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    open func updatePhotoSkitch(at index: Int, skitches: [[String: Any]], versionID: String) {
        guard let previewController = viewControllers?[0] as? PhotoPreviewController, index == currentIndex else {
            return
        }
        if skitchesDictionary[index] == nil || skitchesDictionary[index]?.count == 0 { // first skitches set
            if isSkitchButtonHidden && !isSkitchesSetted {
                isSkitchButtonHidden = false
                isSkitchesSetted = true
            }
        }
        skitchesDictionary[index] = skitches
        previewController.updateSkiches(skitches, versionID: versionID, isHidden: isSkitchButtonHidden)
        updateNavigationBarTitle()
    }
    
    open func setToolBarButton(at index: NSInteger, enabled: Bool) {
        guard let items = toolbar?.items, items.count > 0 && index < items.count else { return }

        var toolBarIndex: NSInteger?
        if UIDevice.current.userInterfaceIdiom == .pad {
            toolBarIndex = index + 2
        } else {
            if items.count == 1 {
                toolBarIndex = 1
            } else if items.count == 2 {
                toolBarIndex = index * 3 + 1
            } else {
                toolBarIndex = index * 2 + 1
            }
        }
        if let toolBarIndex = toolBarIndex, toolBarIndex < items.count {
            toolbar?.items?[toolBarIndex].isEnabled = enabled
        }
    }
}

// MARK: - Progress bar updates
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
            let initPage = PhotoPreviewController(photo: photos[index], index: index, skitches: skitchesDictionary[currentIndex])

            initPage.delegate = self
            setViewControllers([initPage], direction: .forward, animated: false, completion: nil)
            updateNavigationBarTitle()
        }
    }
    
    private func loadPhotos() {
        if let photos = photos {
            if photos.count == 0 {
                leftButtonTap(nil) // dismiss
            } else {
                currentIndex = min(currentIndex, photos.count - 1)
                let initPage = PhotoPreviewController(photo: photos[currentIndex], index: currentIndex, skitches: skitchesDictionary[currentIndex], isSkitchButtonHidden: isSkitchButtonHidden)
                initPage.delegate = self
                setViewControllers([initPage], direction: .forward, animated: false, completion: nil)
                updateNavigationBarTitle()
            }
        }
    }
}

extension PhotoBrowser {
    open override var prefersStatusBarHidden: Bool {
        return isFullScreen
    }
    
    open override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .fade
    }
    
    open func showSkitchButtonTapped() {
        if isSkitchButtonHidden {
            isSkitchButtonHidden = false
        } else {
            isSkitchButtonHidden = true
        }
        if let previewController = viewControllers?[0] as? PhotoPreviewController {
            previewController.updateSkitchButtonStatus(isSkitchButtonHidden)
        }
        photoBrowserDelegate?.photoBrowser(self, didHideSkitchButton: isSkitchButtonHidden)
    }

    public func defaultShareAction() {
        if let image = currentImageView()?.image, let button = headerView?.rightButton, let photos = photos {
            let url = URL(fileURLWithPath: NSTemporaryDirectory().appending(photos[currentIndex].title ?? ""))
            let data = image.pngData()
            do {
                try data?.write(to: url)
            } catch {}
            
            let activityController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            if UIDevice.current.userInterfaceIdiom == .pad {
                activityController.modalPresentationStyle = .popover
                activityController.popoverPresentationController?.sourceView = view
                let frame = view.convert(button.frame, from: button.superview)
                activityController.popoverPresentationController?.sourceRect = frame
            }
            activityController.completionWithItemsHandler = { (_, _, _, _) in
                do {
                    try FileManager.default.removeItem(at: url)
                } catch {}
            }
            present(activityController, animated: true)
        }
    }
}

// MARK: - Actions
extension PhotoBrowser {
    @objc private func leftButtonTap(_ sender: Any?) {
        if let delegate = photoBrowserDelegate {
            delegate.dismissPhotoBrowser(self)
        } else {
            dismissPhotoBrowser()
        }
    }
    
    @objc private func showMoreFiles(_ sender: Any) {
        photoBrowserDelegate?.didShowMoreFiles(self)
    }
    
    @objc private func rightButtonTap(_ sender: Any) {
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
        let preViewController = PhotoPreviewController(photo: prePhoto, index: index - 1, skitches: skitchesDictionary[index - 1])
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
        let nextViewController = PhotoPreviewController(photo: nextPhoto, index: index + 1, skitches: skitchesDictionary[index + 1])
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
                updateNavigationBarTitle()
                photoBrowserDelegate?.photoBrowser(self, didShowPhotoAtIndex: index)
            }
        }
    }
}

// MARK: - PhotoPreviewControllerDelegate
extension PhotoBrowser: PhotoPreviewControllerDelegate {
    var isFullScreenMode: Bool {
        get {
            return isFullScreen
        }
        set(newValue) {
            isFullScreen = newValue
            showFullScreen(isFullScreen)
        }
    }

    func photoPreviewController(_ controller: PhotoPreviewController, longPressOn photo: Photo, gesture: UILongPressGestureRecognizer) {
        photoBrowserDelegate?.photoBrowser(self, longPressOnPhoto: photo, index: currentIndex)
    }

    func didTapBackground(_ controller: PhotoPreviewController) {
        if let delegate = photoBrowserDelegate {
            delegate.dismissPhotoBrowser(self)
        } else {
            dismissPhotoBrowser()
        }
    }

    func photoPreviewController(_ controller: PhotoPreviewController, didTapSkitch skitch: Skitch, versionID: String) {
        print("photo index: \(currentIndex), skitch index: \(index)")
        photoBrowserDelegate?.photoBrowser(self, didTapSkitch: skitch, versionID: versionID)
    }
    
    func photoPreviewController(_ controller: PhotoPreviewController, didShowPhotoAtIndex index: Int) {
        photoBrowserDelegate?.photoBrowser(self, didShowPhotoAtIndex: index)
    }
    
    func photoPreviewController(_ controller: PhotoPreviewController, doDraging dragProgress: CGFloat) {
        let progress = min(1, (1-dragProgress))
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: progress)
    }

    func photoPreviewController(_ controller: PhotoPreviewController, doDownDrag isBegin: Bool, needBack: Bool, imageFrame: CGRect, imageView: UIImageView?) {
        if needBack { // 页面消失
            guard let imageView = imageView else { return }
            UIView.animate(withDuration: 0.25, animations: {
                imageView.alpha = 0
                self.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
            }, completion: { (completion) in
                self.dismiss(animated: false, completion: nil)
            })
        } else {
            guard let vcs = viewControllers else { return }
            for vc in vcs where vc != controller {
                vc.view.isHidden = isBegin
            }
        }
    }
}

// MARK: - Helpers
extension PhotoBrowser {
    func currentImageView() -> ImageView? {
        guard let page = viewControllers?.last as? PhotoPreviewController else {
            return nil
        }
        return page.imageView
    }
    
    private func showFullScreen(_ flag: Bool) {
        if isFullScreen { // fix status bar dimiss animation bug
            UIView.animate(withDuration: 0.25, animations: { () -> Void in
                self.view.backgroundColor = .black
                self.headerView?.alpha = 0
                self.toolbar?.alpha = 0
            }) { (_) in
                self.setNeedsStatusBarAppearanceUpdate()
            }
        } else {
            UIView.animate(withDuration: 0.25, animations: { () -> Void in
                self.setNeedsStatusBarAppearanceUpdate()
                self.view.backgroundColor = self.backgroundColor
                self.headerView?.alpha = 1
                self.toolbar?.alpha = 1
            })
        }
    }
    
    private func updateNavigationBarTitle() {
        guard let photos = photos else {
            return
        }
        
        if headerView == nil {
            headerView = PBNavigationBar()
            if let headerView = headerView {
                headerView.isFromPhotoPicker = isFromPhotoPicker
                headerView.isPreviewMode = isPreviewMode
                headerView.isShowMoreButton = isShowMoreButton
                headerView.alpha = 0
                view.addSubview(headerView)
                headerView.translatesAutoresizingMaskIntoConstraints = false
                
                view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[headerView]-0-|", options: [], metrics: nil, views: ["headerView": headerView]))
                if #available(iOS 11.0, *) {
                    view.addConstraint(NSLayoutConstraint(item: headerView, attribute: .bottom, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .top, multiplier: 1.0, constant: 44))
                } else {
                    headerView.addConstraint(NSLayoutConstraint(item: headerView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 64))
                }
                view.addConstraint(NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: headerView, attribute: .top, multiplier: 1.0, constant: 0))
                
                headerView.leftButton.addTarget(self, action: #selector(leftButtonTap(_:)), for: .touchUpInside)
                headerView.rightButton.addTarget(self, action: #selector(rightButtonTap(_:)), for: .touchUpInside)
                headerView.moreButton.addTarget(self, action: #selector(showMoreFiles(_:)), for: .touchUpInside)
                headerView.imageSelected = selectedIndex.contains(currentIndex)
            }
        }
        if let headerView = headerView {
            headerView.titleLabel.text = photos[currentIndex].title
            headerView.imageSelected = selectedIndex.contains(currentIndex)
        }
    }
    
    private func updateToolbar() {
        guard let items = toolbarItems, items.count > 0 else {
            return
        }
        if toolbar == nil {
            toolbar = PBToolbar()
            if let toolbar = toolbar {
                toolbar.alpha = 0
                view.addSubview(toolbar)
                toolbar.translatesAutoresizingMaskIntoConstraints = false
                view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[toolbar]-0-|", options: [], metrics: nil, views: ["toolbar": toolbar]))
                
                view.addConstraint(NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: toolbar, attribute: .bottom, multiplier: 1.0, constant: 0))
                if #available(iOS 11.0, *) {
                    view.addConstraint(NSLayoutConstraint(item: toolbar, attribute: .top, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .bottom, multiplier: 1.0, constant: -PBConstant.PhotoBrowser.toolBarHeight))
                } else {
                    view.addConstraint(NSLayoutConstraint(item: toolbar, attribute: .top, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: -PBConstant.PhotoBrowser.toolBarHeight))
                }
                
            }
        }
        if let toolbar = toolbar {
            let itemsArray = layoutToolbar(items)
            toolbar.setItems(itemsArray, animated: false)
        }
    }
    
    private func layoutToolbar(_ items: [UIBarButtonItem]) -> [UIBarButtonItem]? {
        let flexSpace = UIBarButtonItem.init(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let fixedSpace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: self, action: nil)
        fixedSpace.width = PBConstant.PhotoBrowser.padToolBarSpace
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
}

// MARK: - update waiting image view and checked image view
extension PhotoBrowser {
    public static func updateCustomImages(_ loadingLogoImage: UIImage? = nil, checkSelectedImage: UIImage? = nil) {
        if let logoImage = loadingLogoImage {
            CustomPhotoBroswerManager.shared.customLogoLoading = logoImage
        }

        if let checkSelected = checkSelectedImage {
            CustomPhotoBroswerManager.shared.customCheckSelected = checkSelected
        }
    }
}
