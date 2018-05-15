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
import Photos

// MARK: - PhotoPreviewControllerDelegate
protocol PhotoPreviewControllerDelegate: class {
    var isFullScreenMode: Bool {get set}
    func longPressOn(_ photo: Photo, gesture: UILongPressGestureRecognizer)
    func didTapOnBackground()
    func didTapSkitch(_ skitch: Skitch, versionID: String)
    func didShowPhotoAtIndex(_ index: Int)
    
    func doDraging(_ dragProgress: CGFloat)
    func doDownDrag(_ isBegin: Bool, view: PhotoPreviewController, needBack: Bool, imageFrame: CGRect, imageView: UIImageView?)
}

// MARK: - PhotoPreviewConstant
struct PhotoPreviewConstant {
    static let skitchButtonFontSize: CGFloat = CGFloat(15)
    static let skitchButtonTag: Int = 777
    static let skitchButtonRadius: CGFloat = 32
    static let skitchButtonBgColor = UIColor(red: 61/255, green: 168/255, blue: 245/255, alpha: 1)
    static let skitchRectangleButtonBgColor = UIColor(red: 61/255, green: 168/255, blue: 245/255, alpha: 0.24)
}

fileprivate struct PopConstant {
    static let springBounciness: CGFloat = 0
    static let springSpeed: CGFloat = 20
}

// MARK: - PhotoPreviewController
class PhotoPreviewController: UIViewController {

    var index: NSInteger?
    var photo: Photo?
    var skitches: [Skitch] = []
    var versionID: String = ""

    fileprivate var isSkitchButtonHidden = true
    fileprivate var skitchViews: [SkitchView] = []
    fileprivate var skitchTopConstraints: [NSLayoutConstraint] = []
    fileprivate var skitchLeftConstraints: [NSLayoutConstraint] = []
    fileprivate var skitchWidthConstraints: [NSLayoutConstraint] = []
    fileprivate var skitchHeightConstraints: [NSLayoutConstraint] = []

    lazy var scrollView: UIScrollView = self.makeScrollView()
    lazy var imageView: UIImageView = self.makeImageView()
    var waitingView: WaitingView?
    
    weak var delegate:PhotoPreviewControllerDelegate?
    
    fileprivate let minPanY: CGFloat = -10
    fileprivate let maxMoveOfY: CGFloat = 250
    fileprivate let minZoom: CGFloat = 0.3
    fileprivate let screenWidth: CGFloat = UIScreen.main.bounds.size.width
    fileprivate let screenHeight: CGFloat = UIScreen.main.bounds.size.height
    
    fileprivate var moveImage: UIImageView? // 拖拽图片
    fileprivate var isPanning: Bool = false // 正在拖拽
    fileprivate var isZooming: Bool = false // 正在缩放
    fileprivate var panningProgress: CGFloat = 0  // 拖拽进度
    fileprivate var isDirectionDown: Bool = false // 拖拽是否向下
    
    fileprivate var dragCoefficient: CGFloat = 0 // 拖拽系数
    fileprivate var panBeginX: CGFloat = 0 // 向下拖拽开始的X
    fileprivate var panBeginY: CGFloat = 0 // 向下拖拽开始的Y
    fileprivate var imageWidthBeforeDrag: CGFloat = 0 // 向下拖拽开始时，图片的宽
    fileprivate var imageHeightBeforeDrag: CGFloat = 0 // 向下拖拽开始时，图片的高
    fileprivate var imageCenterXBeforeDrag: CGFloat = 0 // 向下拖拽开始时，图片的中心X
    fileprivate var imageYBeforeDrag: CGFloat = 0 // 向下拖拽开始时，图片的Y
    fileprivate var scrollOffsetX: CGFloat = 0 // 向下拖拽开始时，滚动控件的offsetX
    
    fileprivate var scrollNewY: CGFloat = 0
    fileprivate var scrollOldY: CGFloat = 0
    fileprivate var isFullScreenMode: Bool = false
    
    fileprivate var panLastY: CGFloat = 0
    
    fileprivate var miniMap: MiniMap?
    public var miniMapSize: CGSize = CGSize(width: 100, height: 100)
    
    init(photo: Photo, index: NSInteger, skitches: [[String: Any]]? = nil, isSkitchButtonHidden: Bool = true) {
        super.init(nibName: nil, bundle: nil)
        self.index = index
        self.photo = photo
        self.isSkitchButtonHidden = isSkitchButtonHidden
        
        if let skitches = skitches {
            self.skitches = skitches.compactMap({ (skitchJSON) -> Skitch? in
                return Skitch(skitchJSON: skitchJSON)
            })
        }
        
        extendedLayoutIncludesOpaqueBars = true
        automaticallyAdjustsScrollViewInsets = false
        edgesForExtendedLayout = UIRectEdge.top
        if let asset = self.photo?.asset, self.photo?.image == nil /* CloudKit or ... */ {
            if let waitingView = waitingView {
                waitingView.removeFromSuperview()
            }
            
            waitingView = WaitingView(frame: CGRect(x: 0, y: 0, width: 70, height: 70))
            
            if let newWaitingView = waitingView {
                newWaitingView.center = view.center
                view.addSubview(newWaitingView)
            }
            
            let options = PHImageRequestOptions()
            options.deliveryMode = .highQualityFormat
            options.isSynchronous = false
            options.isNetworkAccessAllowed = true
            options.progressHandler = { progress, _, _, _ in
                DispatchQueue.main.async { [weak self] in
                    self?.waitingView?.progress = CGFloat(progress)
                }
            }
            
            PHImageManager.default().requestImageData(for: asset, options: options) { [weak self] data, _, _, _ in
                DispatchQueue.main.async {
                    if let imageData = data, let image = UIImage(data: imageData) {
                        self?.photo?.image = image
                        self?.setImageViewFrame(image)
                        self?.imageView.image = image
                        self?.addSkitches()
                        self?.delegate?.didShowPhotoAtIndex(index)
                    }
                    
                    if let waitingView = self?.waitingView {
                        waitingView.removeFromSuperview()
                    }
                }
            }
        }
    }
    
    fileprivate func makeScrollView() -> UIScrollView {
        let scrollView = UIScrollView(frame: self.view.frame)
        scrollView.delegate = self
        scrollView.backgroundColor = UIColor.clear
        scrollView.clipsToBounds = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.alwaysBounceHorizontal = true
        scrollView.alwaysBounceVertical = true
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 3.0
        scrollView.zoomScale = 1.0
        scrollView.contentOffset = CGPoint.zero
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        }
        return scrollView
    }
    
    fileprivate func makeImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill

        return imageView
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        commonInit()
    }
    
    fileprivate func computeImageViewCenter(_ scrollView: UIScrollView) -> CGPoint {
        let offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width) ? (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0 //x偏移
        let offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height) ? (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0 //y偏移
        let actualCenter = CGPoint(x: scrollView.contentSize.width * 0.5 + offsetX, y: scrollView.contentSize.height * 0.5 + offsetY);
        return actualCenter
    }
    
    fileprivate func setImageViewFrame(_ image: UIImage) {
        miniMap?.image = image
        imageView.width = screenWidth
        imageView.height = image.size.height / image.size.width * screenWidth
        imageView.center = self.view.center
        scrollView.contentSize = imageView.frame.size
    }
    
    func commonInit() {
        guard let photo = photo else {
            return
        }

        isFullScreenMode = delegate?.isFullScreenMode ?? false
        view.backgroundColor = UIColor.clear
        view.addSubview(scrollView)

        scrollView.addSubview(imageView)
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
        
        let miniMap = MiniMap(size: miniMapSize)
        miniMap.isHidden = true
        view.addSubview(miniMap)
        miniMap.translatesAutoresizingMaskIntoConstraints = false
        miniMap.widthAnchor.constraint(equalToConstant: miniMapSize.width).isActive = true
        miniMap.heightAnchor.constraint(equalToConstant: miniMapSize.height).isActive = true
        miniMap.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
        miniMap.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50).isActive = true
        
        self.miniMap = miniMap
        
        if let image = photo.localOriginalPhoto() {
            setImageViewFrame(image)
            imageView.image = image
            addSkitches()

            if let index = self.index {
                self.delegate?.didShowPhotoAtIndex(index)
            }
        } else {
            if let thumbnail = photo.localThumbnailPhoto() {
                setImageViewFrame(thumbnail)
                imageView.image = thumbnail
            }
            if let waitingView = waitingView {
                waitingView.removeFromSuperview()
            }
            
            if let photoUrl = photo.photoUrl, let photoFileKey = photo.fileKey {
                waitingView = WaitingView.init(frame: CGRect(x: 0, y: 0, width: 70, height: 70))
                
                if let newWaitingView = waitingView {
                    newWaitingView.center = view.center
                    view.addSubview(newWaitingView)
                }
                
                let resource = ImageResource(downloadURL: photoUrl, cacheKey: photoFileKey)
                imageView.kf.setImage(with: resource, placeholder: photo.localThumbnailPhoto(), options: nil, progressBlock: { (receivedSize, totalSize) -> () in
                    let progress = CGFloat(receivedSize) / CGFloat(totalSize)
                    if let waitingView = self.waitingView {
                        waitingView.progress = progress
                    }
                    }, completionHandler: { (image, error, cacheType, imageURL) -> () in
                        if let waitingView = self.waitingView {
                            waitingView.removeFromSuperview()
                        }
                        if let image = image {
                            self.setImageViewFrame(image)
                        }
                        self.addSkitches()
                        if let index = self.index {
                            self.delegate?.didShowPhotoAtIndex(index)
                        }
                })
            }
        }
    }
    
    func updateConstraint() {
        updateSkitchViewConstraint()
        view.layoutIfNeeded()
    }

    fileprivate func zoomScaleForDoubleTap() -> CGFloat {
        guard imageView.image != nil  else {
            return scrollView.minimumZoomScale
        }
        return 2 * scrollView.minimumZoomScale
    }
}

extension PhotoPreviewController: SkitchViewDelegate {
    func didPressedSkitchView(skitchView: SkitchView, index: Int) {
        let skitch = skitches[index]
        delegate?.didTapSkitch(skitch, versionID: self.versionID)
    }
}

extension PhotoPreviewController {
    
    @objc func handleDoubleTap(_ sender: UITapGestureRecognizer) {
        if scrollView.zoomScale != scrollView.minimumZoomScale {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        } else {
            let touchPoint = sender.location(in: imageView)
            let newZoomScale = zoomScaleForDoubleTap()
            let xsize = scrollView.bounds.size.width / newZoomScale
            let ysize = scrollView.bounds.size.height / newZoomScale
            scrollView.zoom(to: CGRect(x: touchPoint.x - xsize/2, y: touchPoint.y - ysize/2, width: xsize, height: ysize), animated: true)
        }
        updateConstraint()
    }
    
    @objc func handleSingleTap(_ sender: UITapGestureRecognizer) {
        guard let delegate = delegate else {
            return
        }
        delegate.isFullScreenMode = !delegate.isFullScreenMode
    }
    
    @objc func handleLongPress(_ sender: UILongPressGestureRecognizer) {
        guard let delegate = delegate, let photo = photo else {
            return
        }
        if sender.state == UIGestureRecognizerState.began {
            delegate.longPressOn(photo, gesture: sender)
        }
    }

    @objc func handleBackgroundSingleTap(_ sender: UITapGestureRecognizer) {
        delegate?.didTapOnBackground()
    }
}

// MARK: - UIScrollViewDelegate
extension PhotoPreviewController: UIScrollViewDelegate {

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        imageView.center = computeImageViewCenter(scrollView)
//        scrollView.contentSize = imageView.size
        isZooming = false
        updateConstraint()
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        isZooming = true
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        endPan()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollNewY = scrollView.contentOffset.y
        if (scrollView.contentOffset.y < minPanY || isPanning) && !isZooming {
            doPan(scrollView.panGestureRecognizer)
        }
        scrollOldY = scrollNewY
        
        if moveImage != nil {
            miniMap?.isHidden = true
        } else {
            miniMap?.isHidden = scrollView.contentSize.width <= view.frame.width

        }
        
        miniMap?.ratios =
            Ratios(
                top: scrollView.contentOffset.y / scrollView.contentSize.height,
                left: scrollView.contentOffset.x / scrollView.contentSize.width,
                width: view.frame.width / scrollView.contentSize.width,
                height: view.frame.height / scrollView.contentSize.height
            )
    }
}

// MARK: - pan gesture
extension PhotoPreviewController {
    fileprivate func saveFrameBeginPan() {
        updateSkitchButtonStatus(true)
        imageWidthBeforeDrag = imageView.width
        imageHeightBeforeDrag = imageView.height

        //计算图片centerY需要考虑到图片此时的高
        let imageBeginY = (imageHeightBeforeDrag < screenHeight) ? (screenHeight - imageHeightBeforeDrag) * 0.5 : 0.0
        imageYBeforeDrag = imageBeginY
        
        //centerX需要考虑到offset
        scrollOffsetX = self.scrollView.contentOffset.x
        let imageX = -scrollOffsetX
        imageCenterXBeforeDrag = imageX + imageWidthBeforeDrag * 0.5

//        imageCenterXBeforeDrag = imageView.center.x // 更正后
        dragCoefficient = 1.0 + imageHeightBeforeDrag / 2000.0
    }
    
    fileprivate func doPan(_ pan: UIPanGestureRecognizer) {
        if pan.state == .ended || pan.state == .possible { // 手势已结束
            panBeginX = 0
            panBeginY = 0
            isPanning = false
            if !isDirectionDown {
                delegate?.isFullScreenMode = isFullScreenMode
            }
            return
        }
        
        if pan.numberOfTouches != 1 || isZooming { // 两个手指在拖，此时在缩放
            moveImage = nil
            isPanning = false
            panBeginX = 0
            panBeginY = 0
            return
        }
        
        if panBeginX == 0.0 && panBeginY == 0.0 { // 新的一次下拉开始了
            panBeginX = pan.location(in: self.view).x
            panBeginY = pan.location(in: self.view).y
            print(panBeginX, panBeginY)
            isPanning = true
            imageView.isHidden = true
            delegate?.isFullScreenMode = true
            saveFrameBeginPan()
            delegate?.doDownDrag(true, view: self, needBack: false, imageFrame: CGRect.zero, imageView: nil)
        }
        
        if moveImage == nil { // 添加moveImage
            moveImage = UIImageView()
            view.addSubview(moveImage!)
            moveImage?.contentMode = UIViewContentMode.scaleAspectFill
            moveImage?.backgroundColor = UIColor.white
            moveImage?.layer.masksToBounds = true
            moveImage?.image = imageView.image
            moveImage?.width = imageWidthBeforeDrag
            moveImage?.height = imageHeightBeforeDrag
            moveImage?.center.x = imageCenterXBeforeDrag
            moveImage?.originY = imageYBeforeDrag
        }
        
        let panCurrentX: CGFloat = pan.location(in: view).x
        let panCurrentY: CGFloat = pan.location(in: view).y
        
        // 判断是否向下拖拽
        isDirectionDown = panCurrentY > panLastY
        panLastY = panCurrentY

        // 拖拽进度
        let progress = (panCurrentY - panBeginY) / maxMoveOfY
        panningProgress = min(progress, 1.0)
        delegate?.doDraging(panningProgress)

        if panCurrentY > panBeginY {
            moveImage?.width = imageWidthBeforeDrag - (imageWidthBeforeDrag - imageWidthBeforeDrag * minZoom) * panningProgress
            moveImage?.height = imageHeightBeforeDrag - (imageHeightBeforeDrag - imageHeightBeforeDrag * minZoom) * panningProgress
        } else {
            moveImage?.width = imageWidthBeforeDrag
            moveImage?.height = imageHeightBeforeDrag
        }
        moveImage?.center.x = (panCurrentX - panBeginX) + imageCenterXBeforeDrag
        moveImage?.originY = (panCurrentY - panBeginY) * dragCoefficient + imageYBeforeDrag
    }
    
    fileprivate func endPan() {
        if !isDirectionDown { // 不退回页面
            guard moveImage != nil else {
                self.panningProgress = 0
                self.panBeginX = 0
                self.panBeginY = 0
                return
            }
            UIView.animate(withDuration: 0.25, animations: {
                self.panningProgress = 0
                self.delegate?.doDraging(self.panningProgress)
                self.moveImage?.width = self.imageWidthBeforeDrag
                self.moveImage?.height = self.imageHeightBeforeDrag
                self.moveImage?.center.x = self.imageCenterXBeforeDrag
                self.moveImage?.originY = self.imageYBeforeDrag
            }, completion: { (_) in
                self.scrollView.contentOffset = CGPoint(x: self.scrollOffsetX, y: 0)
                self.panBeginX = 0
                self.panBeginY = 0
                self.moveImage?.isHidden = true
                self.imageView.isHidden = false
                self.moveImage?.removeFromSuperview()
                self.moveImage = nil
                self.updateSkitchButtonStatus(false)
                self.miniMap?.isHidden = self.scrollView.contentSize.width <= self.view.frame.width
            })
        } else {
            guard let image = moveImage else { return }
            self.delegate?.doDownDrag(false, view: self, needBack: true, imageFrame: image.frame, imageView: image)
        }
    }
}

// MARK: - Skitch
extension PhotoPreviewController {
    func updateSkiches(_ skitches: [[String: Any]], versionID: String, isHidden: Bool) {
        self.versionID = versionID
        self.isSkitchButtonHidden = isHidden
        self.skitches = skitches.compactMap({ (skitchJSON) -> Skitch? in
            return Skitch(skitchJSON: skitchJSON)
        })
        self.addSkitches()
        self.updateSkitchButtonStatus()
    }

    func updateSkitchButtonStatus(_ isHidden: Bool? = nil) {
        if let isHidden = isHidden {
            isSkitchButtonHidden = isHidden
        }

        updateSkitchViewConstraint()
        for skitchView in skitchViews {
            skitchView.isHidden = isSkitchButtonHidden
        }
    }

    fileprivate func addSkitches() {
        if skitches.count <= 0 {
            return
        }
        for skitchView in skitchViews {
            skitchView.removeFromSuperview()
        }

        skitchTopConstraints.removeAll()
        skitchLeftConstraints.removeAll()
        skitchWidthConstraints.removeAll()
        skitchHeightConstraints.removeAll()

        for i in 0..<skitches.count {
            addSkitchView(i)
        }
        updateConstraint()
    }

    fileprivate func addSkitchView(_ i: Int) {
        let skitch = skitches[i]
        let skitchView = SkitchView()
        let skitchViewFrame = getSkitchViewFrame(skitch)

        skitchView.delegate = self
        skitchView.setTitle(String(skitch.number), index: i)
        scrollView.addSubview(skitchView)
        skitchView.isHidden = isSkitchButtonHidden
        skitchView.translatesAutoresizingMaskIntoConstraints = false

        let topConstraint = NSLayoutConstraint(item: skitchView, attribute: .top, relatedBy: .equal, toItem: scrollView, attribute: .top, multiplier: 1, constant: skitchViewFrame.origin.y)
        let leftConstraint = NSLayoutConstraint(item: skitchView, attribute: .left, relatedBy: .equal, toItem: scrollView, attribute: .left, multiplier: 1, constant: skitchViewFrame.origin.x)
        let widthConstraint = NSLayoutConstraint(item: skitchView, attribute: .width , relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: skitchViewFrame.width)
        let heightConstraint = NSLayoutConstraint(item: skitchView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: skitchViewFrame.height)

        scrollView.addConstraint(topConstraint)
        scrollView.addConstraint(leftConstraint)
        scrollView.addConstraint(widthConstraint)
        scrollView.addConstraint(heightConstraint)

        skitchTopConstraints.append(topConstraint)
        skitchLeftConstraints.append(leftConstraint)
        skitchWidthConstraints.append(widthConstraint)
        skitchHeightConstraints.append(heightConstraint)
        skitchViews.append(skitchView)
    }

    func getSkitchViewFrame(_ skitch: Skitch) -> CGRect {
        let zoomScale = scrollView.zoomScale
        let offsetX: CGFloat = imageView.frame.origin.x + skitch.point.x*zoomScale
        let offsetY: CGFloat = imageView.frame.origin.y + skitch.point.y*zoomScale
        let width = skitch.point.width * zoomScale
        let height = skitch.point.height * zoomScale

        return CGRect(x: offsetX, y: offsetY, width: width, height: height)
    }

    fileprivate func updateSkitchViewConstraint() {
        if skitches.count <= 0 {
            return
        }

        for i in 0..<skitches.count {
            let skitch = skitches[i]
            let skitchFrame = getSkitchViewFrame(skitch)

            if i < skitchLeftConstraints.count {
                skitchTopConstraints[i].constant = skitchFrame.origin.y
                skitchLeftConstraints[i].constant = skitchFrame.origin.x
                skitchWidthConstraints[i].constant = skitchFrame.width
                skitchHeightConstraints[i].constant = skitchFrame.height
            }
        }
    }
}
