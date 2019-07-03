//
//  PBCustomView.swift
//  PhotoBrowser
//
//  Created by WangWei on 16/3/16.
//  Copyright © 2016年 Teambition. All rights reserved.
//

import UIKit

private let statusBarHeight = 20
private let waitingViewMargin: CGFloat = 10.0

class WaitingView: UIView {
    
    var logoView: UIImageView!
    var progress: CGFloat = 0 {
        
        willSet {
            if newValue > 1 {
                removeFromSuperview()
            }
        }
        
        didSet {
            setNeedsDisplay()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 5.0
        layer.masksToBounds = true
        backgroundColor = UIColor.black.withAlphaComponent(0.6)
        clipsToBounds = true
        
        let image = getLogoLoadingImage()
        
        logoView = UIImageView.init(image: image)
        logoView.center = center
        addSubview(logoView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        let currentContext = UIGraphicsGetCurrentContext()
        let centerX = rect.size.width / 2
        let centerY = rect.size.height / 2
        let center = CGPoint(x: centerX, y: centerY)
        
        UIColor.white.set()
        currentContext?.setLineWidth(2)
        currentContext?.setLineCap(CGLineCap.round)
        let end = -CGFloat.pi/2 + CGFloat(progress) * CGFloat.pi*2 + 0.05
        let radius = min(rect.size.width, rect.size.height) / 2 - waitingViewMargin
        currentContext?.addArc(center: center, radius: radius, startAngle: -CGFloat.pi / 2, endAngle: end, clockwise: false)
        currentContext?.strokePath()
    }
    
    fileprivate func getLogoLoadingImage() -> UIImage? {
        if let logoImage = CustomPhotoBroswerManager.shared.customLogoLoading {
            return logoImage
        } else {
            return UIImage.init(named: "icon-logo-white", in: Bundle.init(for: classForCoder), compatibleWith: nil)
        }
    }
    
}

class PBNavigationBar: UIView {

    var isPreviewMode: Bool = false {
        didSet {
            if isPreviewMode {
                isFromPhotoPicker = true
                rightButton.isHidden = true
            }
        }
    }
    
    var isFromPhotoPicker: Bool = false {
        didSet {
            self.updateMoreButtonStatus(isFromPhotoPicker)
        }
    }
    var imageSelected: Bool = false {
        didSet {
            if isFromPhotoPicker {
                let unselectedImage = UIImage(named: "checkmark_unselected", in: Bundle(for: classForCoder), compatibleWith: nil)
                let image = self.imageSelected ? self.getCheckedSelectedImage() : unselectedImage
                rightButton.setImage(image, for: .normal)
            }
        }
    }
    var isShowMoreButton: Bool = true {
        didSet {
            self.updateMoreButtonStatus(!isShowMoreButton)
        }
    }
    
    lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(self.leftButton)
        view.addSubview(self.rightButton)
        view.addSubview(self.titleLabel)

        var titleLabelTrailingConstant: CGFloat = 60
        if !self.isFromPhotoPicker {
            view.addSubview(self.moreButton)
            view.addConstraint(NSLayoutConstraint(item: view, attribute: .centerY, relatedBy: .equal, toItem: self.moreButton, attribute: .centerY, multiplier: 1.0, constant: 0))
            self.moreTrailingConstraint = NSLayoutConstraint(item: self.moreButton, attribute: .trailing, relatedBy: .equal, toItem: self.rightButton, attribute: .leading, multiplier: 1.0, constant: 0)
            view.addConstraint(self.moreTrailingConstraint!)
            titleLabelTrailingConstant = 85
        }

        NSLayoutConstraint(item: view, attribute: .centerY, relatedBy: .equal, toItem: self.leftButton, attribute: .centerY, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: view, attribute: .leading, relatedBy: .equal, toItem: self.leftButton, attribute: .leading, multiplier: 1.0, constant: -8).isActive = true
        
        NSLayoutConstraint(item: view, attribute: .centerY, relatedBy: .equal, toItem: self.rightButton, attribute: .centerY, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: view, attribute: .trailing, relatedBy: .equal, toItem: self.rightButton, attribute: .trailing, multiplier: 1.0, constant: 8).isActive = true
        
        NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: self.titleLabel, attribute: .top, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: self.titleLabel, attribute: .bottom, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: view, attribute: .centerX, relatedBy: .equal, toItem: self.titleLabel, attribute: .centerX, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: view, attribute: .leading, relatedBy: .equal, toItem: self.titleLabel, attribute: .leading, multiplier: 1, constant: -60).isActive = true
        self.titleTrailingConstraint = NSLayoutConstraint(item: view, attribute: .trailing, relatedBy: .equal, toItem: self.titleLabel, attribute: .trailing, multiplier: 1, constant: titleLabelTrailingConstant)
        self.titleTrailingConstraint?.isActive = true

        return view
    }()
    
    var titleTrailingConstraint: NSLayoutConstraint?
    var moreTrailingConstraint: NSLayoutConstraint?
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Title"
        label.textAlignment = .center
        label.textColor = UIColor.white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy var leftButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: "icon-cross", in: Bundle(for: classForCoder), compatibleWith: nil)
        button.setImage(image, for: UIControl.State())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addConstraint(NSLayoutConstraint(item: button, attribute: .width, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 40))
        button.addConstraint(NSLayoutConstraint(item: button, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 40))
        return button
    }()
    
    lazy var moreButton: UIButton = {
        let button = UIButton()
        var image = UIImage(named: "moreIcon", in: Bundle(for: classForCoder), compatibleWith: nil)
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addConstraint(NSLayoutConstraint(item: button, attribute: .width, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 40))
        button.addConstraint(NSLayoutConstraint(item: button, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 40))

        return button
    }()

    lazy var rightButton: UIButton = {
        let button = UIButton()
        var image = UIImage(named: "icon-share", in: Bundle(for: classForCoder), compatibleWith: nil)
        if self.isFromPhotoPicker {
            let unselectedImage = UIImage(named: "checkmark_unselected", in: Bundle(for: classForCoder), compatibleWith: nil)
            image = self.imageSelected ? self.getCheckedSelectedImage() : unselectedImage
        }
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addConstraint(NSLayoutConstraint(item: button, attribute: .width, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 40))
        button.addConstraint(NSLayoutConstraint(item: button, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 40))
        return button
    }()

    var backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func updateShareStatus(_ isEnableShare: Bool) {
        self.removeConstraint(self.moreTrailingConstraint!)
        
        if !isEnableShare {
            rightButton.isHidden = true

//            self.moreTrailingConstraint = NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1.0, constant: -15)
            
            self.moreTrailingConstraint = NSLayoutConstraint(item: self.moreButton, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1.0, constant: -15)
            self.addConstraint(self.moreTrailingConstraint!)
            
            titleTrailingConstraint?.constant = 60
        } else {
            rightButton.isHidden = false

            self.moreTrailingConstraint = NSLayoutConstraint(item: self.moreButton, attribute: .trailing, relatedBy: .equal, toItem: self.rightButton, attribute: .leading, multiplier: 1.0, constant: 0)
            self.addConstraint(self.moreTrailingConstraint!)

            titleTrailingConstraint?.constant = 85
        }
        layoutIfNeeded()
    }
    
    func updateMoreButtonStatus(_ isHidden: Bool) {
        
        self.moreButton.isHidden = isHidden
        if isHidden {
            titleTrailingConstraint?.constant = 60
        } else {
            titleTrailingConstraint?.constant = 85
        }
        layoutIfNeeded()
    }

    func setup() {
        addSubview(backgroundView)
        backgroundView.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        backgroundView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        addSubview(contentView)
        if #available(iOS 11.0, *) {
            contentView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
            contentView.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 0).isActive = true
            contentView.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: 0).isActive = true
            contentView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        } else {
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[contentView]-0-|", options: [], metrics: nil, views: ["contentView": contentView]))
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-statusBarHeight-[contentView]-0-|", options: [], metrics: ["statusBarHeight":statusBarHeight], views: ["contentView": contentView]))
        }
    }

    fileprivate func getCheckedSelectedImage() -> UIImage? {
        if let checkedImage = CustomPhotoBroswerManager.shared.customCheckSelected {
            return checkedImage
        } else {
            return UIImage(named: "checkmark_selected", in: Bundle(for: classForCoder), compatibleWith: nil)
        }
    }
}

open class PBToolbar: UIView {
    
    var backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    
    lazy var toolbar: UIToolbar = {
        let toolbar = UIToolbar(frame: frame)
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        toolbar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        toolbar.clipsToBounds = true
        return toolbar
    }()
    
    public var items: [UIBarButtonItem]? {
        get {
            return toolbar.items
        }
        set {
            toolbar.items = items
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(backgroundView)
        backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        self.addSubview(toolbar)
        NSLayoutConstraint(item: toolbar, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: toolbar, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: toolbar, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: 0).isActive = true
        if #available(iOS 11.0, *) {
            NSLayoutConstraint(item: toolbar, attribute: .bottom, relatedBy: .equal, toItem: safeAreaLayoutGuide, attribute: .bottom, multiplier: 1.0, constant: 0).isActive = true
        } else {
            NSLayoutConstraint(item: toolbar, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0).isActive = true
        }
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setItems(_ items: [UIBarButtonItem]?, animated: Bool) {
        toolbar.setItems(items, animated: animated)
    }
}

class GradientView: UIView {
    
    var colors: [AnyObject]? {
        get {
            return (layer as! CAGradientLayer).colors as [AnyObject]?
        }
        set {
            (layer as! CAGradientLayer).colors = newValue
        }
    }
    
    var startPoint: CGPoint {
        get {
            return (layer as! CAGradientLayer).startPoint
        }
        set {
            (layer as! CAGradientLayer).startPoint = newValue
        }
    }
    
    var endPoint: CGPoint {
        get {
            return (layer as! CAGradientLayer).endPoint
        }
        set {
            (layer as! CAGradientLayer).endPoint = newValue
        }
    }
    
    override class var layerClass : AnyClass {
        return CAGradientLayer.self
    }
}
