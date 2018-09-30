//
//  PBNavigationBar.swift
//  PhotoBrowser
//
//  Created by zouliangming on 2018/8/6.
//  Copyright © 2018年 Teambition. All rights reserved.
//

import Foundation

private let statusBarHeight = 20

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
            updateMoreButtonStatus(isFromPhotoPicker)
        }
    }
    var imageSelected: Bool = false {
        didSet {
            if isFromPhotoPicker {
                let unselectedImage = UIImage(named: "checkmark_unselected", in: Bundle(for: classForCoder), compatibleWith: nil)
                let image = imageSelected ? getCheckedSelectedImage() : unselectedImage
                rightButton.setImage(image, for: .normal)
            }
        }
    }
    var isShowMoreButton: Bool = true {
        didSet {
            updateMoreButtonStatus(!isShowMoreButton)
        }
    }
    
    lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(leftButton)
        view.addSubview(rightButton)
        view.addSubview(titleLabel)
        
        var titleLabelTrailingConstant: CGFloat = 60
        if !isFromPhotoPicker {
            view.addSubview(moreButton)
            view.addConstraint(NSLayoutConstraint(item: view, attribute: .centerY, relatedBy: .equal, toItem: moreButton, attribute: .centerY, multiplier: 1.0, constant: 0))
            moreTrailingConstraint = NSLayoutConstraint(item: moreButton, attribute: .trailing, relatedBy: .equal, toItem: rightButton, attribute: .leading, multiplier: 1.0, constant: 0)
            view.addConstraint(moreTrailingConstraint!)
            titleLabelTrailingConstant = 85
        }
        
        NSLayoutConstraint(item: view, attribute: .centerY, relatedBy: .equal, toItem: leftButton, attribute: .centerY, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: view, attribute: .leading, relatedBy: .equal, toItem: leftButton, attribute: .leading, multiplier: 1.0, constant: -8).isActive = true
        
        NSLayoutConstraint(item: view, attribute: .centerY, relatedBy: .equal, toItem: rightButton, attribute: .centerY, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: view, attribute: .trailing, relatedBy: .equal, toItem: rightButton, attribute: .trailing, multiplier: 1.0, constant: 8).isActive = true
        
        NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: titleLabel, attribute: .top, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: titleLabel, attribute: .bottom, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: view, attribute: .centerX, relatedBy: .equal, toItem: titleLabel, attribute: .centerX, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: view, attribute: .leading, relatedBy: .equal, toItem: titleLabel, attribute: .leading, multiplier: 1, constant: -60).isActive = true
        titleTrailingConstraint = NSLayoutConstraint(item: view, attribute: .trailing, relatedBy: .equal, toItem: titleLabel, attribute: .trailing, multiplier: 1, constant: titleLabelTrailingConstant)
        titleTrailingConstraint?.isActive = true
        
        return view
    }()
    
    var titleTrailingConstraint: NSLayoutConstraint?
    var moreTrailingConstraint: NSLayoutConstraint?
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Title"
        label.textAlignment = .center
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var leftButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: "icon-cross", in: Bundle(for: classForCoder), compatibleWith: nil)
        button.setImage(image, for: .normal)
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
        if isFromPhotoPicker {
            let unselectedImage = UIImage(named: "checkmark_unselected", in: Bundle(for: classForCoder), compatibleWith: nil)
            image = imageSelected ? getCheckedSelectedImage() : unselectedImage
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
        removeConstraint(moreTrailingConstraint!)
        
        if !isEnableShare {
            rightButton.isHidden = true
            moreTrailingConstraint = NSLayoutConstraint(item: moreButton, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1.0, constant: -15)
            addConstraint(moreTrailingConstraint!)
            titleTrailingConstraint?.constant = 60
        } else {
            rightButton.isHidden = false
            moreTrailingConstraint = NSLayoutConstraint(item: moreButton, attribute: .trailing, relatedBy: .equal, toItem: rightButton, attribute: .leading, multiplier: 1.0, constant: 0)
            addConstraint(moreTrailingConstraint!)
            
            titleTrailingConstraint?.constant = 85
        }
        layoutIfNeeded()
    }
    
    func updateMoreButtonStatus(_ isHidden: Bool) {
        moreButton.isHidden = isHidden
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
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        } else {
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[contentView]-0-|", options: [], metrics: nil, views: ["contentView": contentView]))
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-statusBarHeight-[contentView]-0-|", options: [], metrics: ["statusBarHeight": statusBarHeight], views: ["contentView": contentView]))
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
