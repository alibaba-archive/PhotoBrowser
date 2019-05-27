//
//  PhotoPreviewController.swift
//  PhotoBrowser
//
//  Created by zouliangming on 2018/8/6.
//  Copyright © 2018年 Teambition. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher
import Photos

// MARK: - PhotoPreviewControllerDelegate
protocol PhotoPreviewControllerDelegate: class {
    var isFullScreenMode: Bool { get set }
    func didTapBackground(_ controller: PhotoPreviewController)
    func photoPreviewController(_ controller: PhotoPreviewController, longPressOn photo: Photo, gesture: UILongPressGestureRecognizer)
    func photoPreviewController(_ controller: PhotoPreviewController, didTapSkitch skitch: Skitch, versionID: String)
    func photoPreviewController(_ controller: PhotoPreviewController, didShowPhotoAtIndex index: Int)
    func photoPreviewController(_ controller: PhotoPreviewController, doDraging dragProgress: CGFloat)
    func photoPreviewController(_ controller: PhotoPreviewController, doDownDrag isBegin: Bool, needBack: Bool, imageFrame: CGRect, imageView: UIView?)
}

typealias ImageView = ImageContainerView

// MARK: - PhotoPreviewController
class PhotoPreviewController: UIViewController {
    var index: NSInteger
    var photo: Photo

    lazy var imageView: ImageView = {
        let imageView = ImageView()
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private var waitingView: WaitingView?
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: self.view.frame)
        scrollView.delegate = self
        scrollView.backgroundColor = .clear
        scrollView.clipsToBounds = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.alwaysBounceHorizontal = true
        scrollView.alwaysBounceVertical = true
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = .greatestFiniteMagnitude
        scrollView.zoomScale = 1.0
        scrollView.contentOffset = .zero

        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        }
        return scrollView
    }()

    // Support Skitch View
    private var skitches: [Skitch] = []
    private var versionID: String = ""
    private var isSkitchButtonHidden = true
    private var skitchViews: [SkitchView] = []
    private var skitchTopConstraints: [NSLayoutConstraint] = []
    private var skitchLeftConstraints: [NSLayoutConstraint] = []
    private var skitchWidthConstraints: [NSLayoutConstraint] = []
    private var skitchHeightConstraints: [NSLayoutConstraint] = []

    // Support pull to dismiss
    private var minPanY: CGFloat {
        return  (miniMap?.isHidden ?? true) ? -10 : -CGFloat.greatestFiniteMagnitude
    }
    private var moveImage: UIView? // 拖拽图片
    private var isPanning: Bool = false // 正在拖拽
    private var isZooming: Bool = false // 正在缩放
    private var panningProgress: CGFloat = 0  // 拖拽进度
    private var isDirectionDown: Bool = false // 拖拽是否向下
    private var dragCoefficient: CGFloat = 0 // 拖拽系数
    private var panBeginX: CGFloat = 0 // 向下拖拽开始的X
    private var panBeginY: CGFloat = 0 // 向下拖拽开始的Y
    private var imageWidthBeforeDrag: CGFloat = 0 // 向下拖拽开始时，图片的宽
    private var imageHeightBeforeDrag: CGFloat = 0 // 向下拖拽开始时，图片的高
    private var imageCenterXBeforeDrag: CGFloat = 0 // 向下拖拽开始时，图片的中心X
    private var imageYBeforeDrag: CGFloat = 0 // 向下拖拽开始时，图片的Y
    private var scrollOffsetX: CGFloat = 0 // 向下拖拽开始时，滚动控件的offsetX
    private var scrollNewOffset: CGPoint = .zero
    private var scrollOldOffset: CGPoint = .zero
    private var imageOriginWidth: CGFloat = 0
    private var panLastY: CGFloat = 0
    private var afterZooming = false

    // PhotoPreviewControllerDelegate
    weak var delegate: PhotoPreviewControllerDelegate?
    private var isFullScreenMode: Bool = false {
        didSet {
            updateMiniMapLayout()
        }
    }

    // Support MiniMap
    private var miniMap: MiniMap?
    private var miniMapTopConstraint: NSLayoutConstraint?
    public var miniMapSize = CGSize(width: 100, height: 100)

    required init(photo: Photo, index: NSInteger, skitches: [[String: Any]]? = nil, isSkitchButtonHidden: Bool = true) {
        self.index = index
        self.photo = photo
        
        super.init(nibName: nil, bundle: nil)

        self.isSkitchButtonHidden = isSkitchButtonHidden
        self.initSkitches(skitches)
        self.loadCloudKitPhoto()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        commonInit()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        scrollView.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        loadImage(with: photo)
    }

    private func commonInit() {
        extendedLayoutIncludesOpaqueBars = true
        automaticallyAdjustsScrollViewInsets = false
        edgesForExtendedLayout = UIRectEdge.top

        isFullScreenMode = delegate?.isFullScreenMode ?? false
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

        miniMap = makeMiniMap()
        loadImage(with: photo)
    }
}

// MARK: - Helpers
extension PhotoPreviewController {
    private func computeImageViewCenter(_ scrollView: UIScrollView) -> CGPoint {
        let offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width) ? (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0 //x偏移
        let offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height) ? (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0 //y偏移
        let actualCenter = CGPoint(x: scrollView.contentSize.width * 0.5 + offsetX, y: scrollView.contentSize.height * 0.5 + offsetY)
        return actualCenter
    }

    private func setImageViewFrame(_ image: UIImage) {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.miniMap?.image = image
            strongSelf.imageOriginWidth = image.size.width
            strongSelf.imageView.frame = strongSelf.scrollView.bounds

            var resultWidth: CGFloat = image.size.width
            var resultHeight: CGFloat = image.size.height

            // compute frame width and height
            if image.size.width >= UIScreen.main.bounds.size.width {
                resultWidth = UIScreen.main.bounds.size.width
                resultHeight = image.size.height / image.size.width * UIScreen.main.bounds.size.width
            }

            if resultHeight >= UIScreen.main.bounds.size.height {
                resultHeight = UIScreen.main.bounds.size.height
                resultWidth = resultWidth / resultHeight * UIScreen.main.bounds.size.height
            }

            strongSelf.imageView.size = CGSize(width: resultWidth, height: resultHeight)
            strongSelf.imageView.center = strongSelf.scrollView.center
            strongSelf.scrollView.contentSize = strongSelf.imageView.frame.size
        }
    }

    private func updateMiniMap(with image: UIImage) {
        let pointSize = miniMapSize
        DispatchQueue.global().async { [weak self] in
            // downsample image to minimap size to reduce memory cost
            let downsampled = image.kf.resize(to: pointSize, for: .aspectFit)
            DispatchQueue.main.async {
                self?.miniMap?.image = downsampled
            }
        }
    }

    private func updateImageViewFrameWithImageSize(_ imageSize: CGSize) {
        imageOriginWidth = imageSize.width
        imageView.frame = scrollView.bounds

        var imageViewSize = imageSize
        let imageScale = min(scrollView.bounds.width / imageSize.width,
                             scrollView.bounds.height / imageSize.height)
        if imageScale > 1 {
            imageViewSize = imageSize
        } else {
            imageViewSize = CGSize(width: imageSize.width * imageScale,
                                   height: imageSize.height * imageScale)
        }

        imageView.size = imageViewSize
        imageView.center = scrollView.center
        scrollView.contentSize = imageView.frame.size
    }

    private func loadCloudKitPhoto() {
        guard let asset = self.photo.asset,
            self.photo.image == nil else {
            return
        }

        // Add waiting view
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
        options.progressHandler = { [weak self] progress, _, _, _ in
            DispatchQueue.main.async { [weak self] in
                self?.waitingView?.progress = CGFloat(progress)
            }
        }

        // Request data
        PHImageManager.default().requestImageData(for: asset, options: options) { [weak self] data, _, _, _ in
            guard let strongSelf = self else { return }
            DispatchQueue.main.async {
                if let imageData = data, let image = UIImage(data: imageData) {
                    strongSelf.photo.image = image
                    strongSelf.updateImageViewFrameWithImageSize(image.size)
                    strongSelf.imageView.image = image
                    strongSelf.addSkitches()
                    strongSelf.delegate?.photoPreviewController(strongSelf,
                                                                didShowPhotoAtIndex: strongSelf.index)
                }
                if let waitingView = strongSelf.waitingView {
                    waitingView.removeFromSuperview()
                }
            }
        }
    }

    private func loadImage(with photo: Photo) {
        let setImage: (UIImage) -> Void = { [weak self] (image) in
            guard let strongSelf = self else { return }
            strongSelf.updateImageViewFrameWithImageSize(image.size)
            strongSelf.imageView.image = image
            strongSelf.updateMiniMap(with: image)
            strongSelf.addSkitches()
            strongSelf.delegate?.photoPreviewController(strongSelf,
                                                        didShowPhotoAtIndex: strongSelf.index)
        }
        
        let downloadCompleted: (Result<RetrieveImageResult, KingfisherError>) -> Void = { [weak self] (result) in
            DispatchQueue.main.async {
                guard let strongSelf = self else { return }
                strongSelf.dismissProgressView()
                if let image = try? result.get().image {
                    setImage(image)
                }
            }
        }

        let progressUpdated: DownloadProgressBlock
            = { [weak self] (received, total) in
                DispatchQueue.main.async {
                    guard let strongSelf = self else { return }
                    let progress = CGFloat(received) / CGFloat(total)
                    strongSelf.waitingView?.progress = progress
                }
        }
        
        if photo.isOriginImageCached() {
            photo.localOriginalPhoto { (image) in
                if let originImage = image {
                    setImage(originImage)
                }
            }
            return
        }
        
        if photo.isThumbnailCached() {
            photo.localThumbnailPhoto { (thumbnail) in
                if let thumbnail = thumbnail {
                    // show thumbnail first when exists
                    setImage(thumbnail)
                }
            }
        }
        
        // load image from url
        guard let url = photo.photoUrl else { return }
        
        // add access token for CRM
        if let accessToken = PhotoBrowser.accessToken {
            let configuration = URLSessionConfiguration.default
            configuration.httpAdditionalHeaders = ["Authorization": "Bearer \(accessToken)"]
            let imgManager = ImageDownloader.default
            imgManager.sessionConfiguration = configuration
            KingfisherManager.shared.downloader = imgManager
        }
        
        // specify cacheKey to fileKey if exists
        let imageResource = ImageResource(downloadURL: url, cacheKey: photo.fileKey)
        
        showProgressView()
        let options: KingfisherOptionsInfo = [.preloadAllAnimationData,
                                              .cacheSerializer(CustomCacheSerializer.default)]
        KingfisherManager.shared.retrieveImage(with: imageResource,
                                               options: options,
                                               progressBlock: progressUpdated,
                                               completionHandler: downloadCompleted)
    }

    private func showProgressView() {
        if let old = waitingView {
            old.removeFromSuperview()
        }

        let progressView = WaitingView(frame: CGRect(x: 0, y: 0, width: 70, height: 70))
        progressView.center = view.center
        view.addSubview(progressView)
        waitingView = progressView
    }

    private func dismissProgressView() {
        waitingView?.removeFromSuperview()
    }

    private func updateConstraint() {
        updateSkitchViewConstraint()
        view.layoutIfNeeded()
    }

    private func zoomScaleForDoubleTap() -> CGFloat {
        guard imageView.image != nil  else {
            return scrollView.minimumZoomScale
        }
        return 2 * scrollView.minimumZoomScale
    }

    private func updateMiniMapLayout() {
        guard miniMap != nil else {
            return
        }
        if PBConstant.Device.isIPhoneX {
            miniMapTopConstraint?.constant = isFullScreenMode ? 15 : 15 + 44
        } else {
            miniMapTopConstraint?.constant = isFullScreenMode ? 15 : 15 + 64
        }
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }

    private func initSkitches(_ skitches: [[String: Any]]? = nil) {
        if let skitches = skitches {
            self.skitches = skitches.compactMap({ (skitchJSON) -> Skitch? in
                return Skitch(skitchJSON: skitchJSON)
            })
        }
    }
}

// MARK: - factory methods
extension PhotoPreviewController {
    private func makeMiniMap() -> MiniMap {
        let miniMap = MiniMap(size: miniMapSize)
        miniMap.isHidden = true
        view.addSubview(miniMap)
        miniMap.translatesAutoresizingMaskIntoConstraints = false
        miniMap.widthAnchor.constraint(equalToConstant: miniMapSize.width).isActive = true
        miniMap.heightAnchor.constraint(equalToConstant: miniMapSize.height).isActive = true
        miniMap.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15).isActive = true
        if #available(iOS 11.0, *), PBConstant.Device.isIPhoneX {
            miniMapTopConstraint = miniMap.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: isFullScreenMode ? 15 : 15 + 44)
        } else {
            miniMapTopConstraint = miniMap.topAnchor.constraint(equalTo: view.topAnchor, constant: isFullScreenMode ? 15 : 15 + 64)
        }
        miniMapTopConstraint?.isActive = true
        return miniMap
    }
}

// MARK: - SkitchViewDelegate
extension PhotoPreviewController: SkitchViewDelegate {
    func didPressedSkitchView(skitchView: SkitchView, index: Int) {
        let skitch = skitches[index]
        delegate?.photoPreviewController(self, didTapSkitch: skitch, versionID: self.versionID)
    }
}

// MARK: - Actions
extension PhotoPreviewController {
    @objc private func handleDoubleTap(_ sender: UITapGestureRecognizer) {
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

    @objc private func handleSingleTap(_ sender: UITapGestureRecognizer) {
        guard let delegate = delegate else {
            return
        }
        isFullScreenMode = !isFullScreenMode
        delegate.isFullScreenMode = !delegate.isFullScreenMode
    }

    @objc private func handleLongPress(_ sender: UILongPressGestureRecognizer) {
        guard let delegate = delegate else {
            return
        }
        if sender.state == .began {
            delegate.photoPreviewController(self, longPressOn: photo, gesture: sender)
        }
    }

    @objc private func handleBackgroundSingleTap(_ sender: UITapGestureRecognizer) {
        delegate?.didTapBackground(self)
    }

    @objc private func hideMiniMap() {
        miniMap?.isHidden = true
    }
}

// MARK: - UIScrollViewDelegate
extension PhotoPreviewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        imageView.center = computeImageViewCenter(scrollView)
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
        /// sometime, iOS called once `scrollViewDidScroll` when after `scrollViewDidEndZooming`
        if afterZooming {
            afterZooming = false
        } else {
            NSObject.cancelPreviousPerformRequests(withTarget: self)
        }

        if scrollView.panGestureRecognizer.state == .began {
            scrollOldOffset = scrollView.contentOffset
        }

        scrollNewOffset = scrollView.contentOffset
        if !isZooming {
            if isPanning {
                onPan(scrollView.panGestureRecognizer)
            } else {
                checkPanGesture(scrollView)
            }
        }

        miniMap?.isHidden = scrollView.contentSize.width <= view.frame.width || moveImage != nil
        miniMap?.ratios =
            Ratios(
                top: scrollView.contentOffset.y / scrollView.contentSize.height,
                left: scrollView.contentOffset.x / scrollView.contentSize.width,
                width: view.frame.width / scrollView.contentSize.width,
                height: view.frame.height / scrollView.contentSize.height
            )
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView.panGestureRecognizer.state == .ended {
            perform(#selector(hideMiniMap), with: self, afterDelay: 3, inModes: [.default])
        } else {
            NSObject.cancelPreviousPerformRequests(withTarget: self)
        }
    }

    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        perform(#selector(hideMiniMap), with: self, afterDelay: 3, inModes: [.default])
        afterZooming = true
    }
}

// MARK: - pan gesture
extension PhotoPreviewController {
    private func checkPanGesture(_ scrollView: UIScrollView) {
        guard scrollNewOffset.y < scrollOldOffset.y else {
            return
        }

        if scrollView.contentOffset.y < minPanY {
            let x = abs(scrollNewOffset.x - scrollOldOffset.x)
            let y = abs(scrollNewOffset.y - scrollOldOffset.y)
            let minTan: CGFloat = 0.577 // tan 30
            if x / y < minTan {
                onPan(scrollView.panGestureRecognizer)
            }
        }
    }

    private func saveFrameBeginPan() {
        updateSkitchButtonStatus(true)
        imageWidthBeforeDrag = imageView.width
        imageHeightBeforeDrag = imageView.height

        //计算图片centerY需要考虑到图片此时的高
        let imageBeginY = (imageHeightBeforeDrag < UIScreen.main.bounds.size.height) ? (UIScreen.main.bounds.size.height - imageHeightBeforeDrag) * 0.5 : 0.0
        imageYBeforeDrag = imageBeginY

        //centerX需要考虑到offset
        scrollOffsetX = self.scrollView.contentOffset.x
        let imageX = -scrollOffsetX
        imageCenterXBeforeDrag = imageX + imageWidthBeforeDrag * 0.5
        dragCoefficient = 1.0 + imageHeightBeforeDrag / 2000.0
    }

    private func onPan(_ pan: UIPanGestureRecognizer) {
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
            isPanning = true
            imageView.isHidden = true
            delegate?.isFullScreenMode = true
            saveFrameBeginPan()
            delegate?.photoPreviewController(self, doDownDrag: true, needBack: false, imageFrame: CGRect.zero, imageView: nil)
        }

        if moveImage == nil { // 添加moveImage
            let imageSizeBeforeDrag = CGSize(width: imageWidthBeforeDrag,
                              height: imageHeightBeforeDrag)
            let shotImageView = imageView.snapshotView(afterScreenUpdates: false)
            moveImage = shotImageView
            moveImage?.frame = CGRect(origin: .zero, size: imageSizeBeforeDrag)
//            moveImage = UIImageView(frame: CGRect(origin: .zero, size: imageSizeBeforeDrag))
            view.addSubview(moveImage!)
            moveImage?.contentMode = .scaleAspectFill
            moveImage?.backgroundColor = .white
            moveImage?.layer.masksToBounds = true
//            let adjustedSize = CGSize(width: ceil(imageSizeBeforeDrag.width), height: ceil(imageSizeBeforeDrag.height))
//            moveImage?.image = imageView.image?.kf.resize(to: adjustedSize,
//                                                          for: .aspectFill)
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
        let progress = (panCurrentY - panBeginY) / PBConstant.PhotoPreview.maxMoveOfY
        panningProgress = min(progress, 1.0)
        delegate?.photoPreviewController(self, doDraging: panningProgress)

        if panCurrentY > panBeginY {
            moveImage?.width = imageWidthBeforeDrag - (imageWidthBeforeDrag - imageWidthBeforeDrag * PBConstant.PhotoPreview.minZoom) * panningProgress
            moveImage?.height = imageHeightBeforeDrag - (imageHeightBeforeDrag - imageHeightBeforeDrag * PBConstant.PhotoPreview.minZoom) * panningProgress
        } else {
            moveImage?.width = imageWidthBeforeDrag
            moveImage?.height = imageHeightBeforeDrag
        }
        moveImage?.center.x = (panCurrentX - panBeginX) + imageCenterXBeforeDrag
        moveImage?.originY = (panCurrentY - panBeginY) * dragCoefficient + imageYBeforeDrag
    }

    private func endPan() {
        if !isDirectionDown { // 不退回页面
            guard moveImage != nil else {
                self.panningProgress = 0
                self.panBeginX = 0
                self.panBeginY = 0
                return
            }
            UIView.animate(withDuration: 0.25, animations: {
                self.panningProgress = 0
                self.delegate?.photoPreviewController(self, doDraging: self.panningProgress)
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
            delegate?.photoPreviewController(self, doDownDrag: false, needBack: true, imageFrame: image.frame, imageView: image)
        }
    }
}

// MARK: - Add skitch
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

    private func addSkitches() {
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

    private func addSkitchView(_ i: Int) {
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
        let widthConstraint = NSLayoutConstraint(item: skitchView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: skitchViewFrame.width)
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

    private func getSkitchViewFrame(_ skitch: Skitch) -> CGRect {
        let zoomScale = imageView.size.width / imageOriginWidth
        let offsetX: CGFloat = imageView.frame.origin.x + skitch.point.x*zoomScale
        let offsetY: CGFloat = imageView.frame.origin.y + skitch.point.y*zoomScale
        let width = skitch.point.width * zoomScale
        let height = skitch.point.height * zoomScale
        return CGRect(x: offsetX, y: offsetY, width: width, height: height)
    }

    private func updateSkitchViewConstraint() {
        guard skitches.count > 0 else {
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
