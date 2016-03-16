//
//  PBCustomView.swift
//  PhotoBrowser
//
//  Created by WangWei on 16/3/16.
//  Copyright © 2016年 Teambition. All rights reserved.
//

import UIKit

let statusBarHeight = UIApplication.sharedApplication().statusBarFrame.size.height

class PBNavigationBar: UIView {
    
    lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(self.leftButton)
        view.addSubview(self.rightButton)
        view.addSubview(self.titleLabel)
        view.addSubview(self.indexLabel)
        
        view.addConstraint(NSLayoutConstraint(item: view, attribute: .CenterY, relatedBy: .Equal, toItem: self.rightButton, attribute: .CenterY, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: view, attribute: .CenterY, relatedBy: .Equal, toItem: self.leftButton, attribute: .CenterY, multiplier: 1.0, constant: 0))
        
        view.addConstraint(NSLayoutConstraint(item: view, attribute: .Leading, relatedBy: .Equal, toItem: self.leftButton, attribute: .Leading, multiplier: 1.0, constant: -8))
        view.addConstraint(NSLayoutConstraint(item: view, attribute: .Trailing, relatedBy: .Equal, toItem: self.rightButton, attribute: .Trailing, multiplier: 1.0, constant: 8))
        
        view.addConstraint(NSLayoutConstraint(item: view, attribute: .Top, relatedBy: .Equal, toItem: self.titleLabel, attribute: .Top, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: view, attribute: .CenterX, relatedBy: .Equal, toItem: self.titleLabel, attribute: .CenterX, multiplier: 1.0, constant: 0))
        
        view.addConstraint(NSLayoutConstraint(item: self.titleLabel, attribute: .Bottom, relatedBy: .Equal, toItem: self.indexLabel, attribute: .Top, multiplier: 1.0, constant: -3))
        view.addConstraint(NSLayoutConstraint(item: self.titleLabel, attribute: .CenterX, relatedBy: .Equal, toItem: self.indexLabel, attribute: .CenterX, multiplier: 1.0, constant: 0))
        return view
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Title"
        label.textColor = UIColor.whiteColor()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var indexLabel: UILabel = {
        let label = UILabel()
        label.text = "Index"
        label.textColor = UIColor.whiteColor()
        label.font = UIFont.systemFontOfSize(14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var leftButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: "icon-cross", inBundle: NSBundle(forClass: classForCoder()), compatibleWithTraitCollection: nil)
        button.setImage(image, forState: .Normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addConstraint(NSLayoutConstraint(item: button, attribute: .Width, relatedBy: .GreaterThanOrEqual, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 30))
        button.addConstraint(NSLayoutConstraint(item: button, attribute: .Height, relatedBy: .GreaterThanOrEqual, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 30))
        return button
    }()
    
    var rightButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: "icon-share", inBundle: NSBundle(forClass: classForCoder()), compatibleWithTraitCollection: nil)
        button.setImage(image, forState: .Normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addConstraint(NSLayoutConstraint(item: button, attribute: .Width, relatedBy: .GreaterThanOrEqual, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 30))
        button.addConstraint(NSLayoutConstraint(item: button, attribute: .Height, relatedBy: .GreaterThanOrEqual, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 30))
        return button
    }()
    
    var gradientView = GradientView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setup() {
        addSubview(gradientView)
        gradientView.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        gradientView.colors = [UIColor.blackColor().colorWithAlphaComponent(0.48).CGColor, UIColor.clearColor().CGColor]
        gradientView.startPoint = CGPoint(x: 0, y: 0)
        gradientView.endPoint = CGPoint(x: 0, y: 1)
        addSubview(contentView)
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[contentView]-0-|", options: [], metrics: nil, views: ["contentView": contentView]))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-statusBarHeight-[contentView]-0-|", options: [], metrics: ["statusBarHeight":statusBarHeight], views: ["contentView": contentView]))
    }
}

public class PBToolbar: UIToolbar {
    
    var gradientView = GradientView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setBackgroundImage(UIImage(), forToolbarPosition: .Any, barMetrics: .Default)
        clipsToBounds = true
        addSubview(gradientView)
        gradientView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        gradientView.colors = [UIColor.blackColor().colorWithAlphaComponent(0.48).CGColor, UIColor.clearColor().CGColor]
        gradientView.startPoint = CGPoint(x: 0, y: 1)
        gradientView.endPoint = CGPoint(x: 0, y: 0)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class GradientView: UIView {
    
    var colors: [AnyObject]? {
        get {
            return (layer as! CAGradientLayer).colors
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
    
    override class func layerClass() -> AnyClass {
        return CAGradientLayer.self
    }
}



















