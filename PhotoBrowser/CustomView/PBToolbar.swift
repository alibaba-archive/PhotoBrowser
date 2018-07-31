//
//  PBToolbar.swift
//  PhotoBrowser
//
//  Created by zouliangming on 2018/8/6.
//  Copyright © 2018年 Teambition. All rights reserved.
//

import Foundation

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
        
        addSubview(toolbar)
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
