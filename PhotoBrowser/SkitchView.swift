//
//  SkitchView.swift
//  PhotoBrowser
//
//  Created by bruce on 2017/5/31.
//  Copyright © 2017年 Teambition. All rights reserved.
//

import UIKit

protocol SkitchViewDelegate: class {
    func didPressedSkitchView(skitchView: SkitchView, index: Int)
}

class SkitchView: UIView {

    weak var delegate: SkitchViewDelegate?
    lazy var skitchCircleButton: UIButton = self.makeSkitchCircleButton()
    lazy var skitchRectangleButton: UIButton = self.makeSkitchRectangleButton()

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    private func makeSkitchCircleButton() -> UIButton {
        let circleButton = UIButton()
        circleButton.translatesAutoresizingMaskIntoConstraints = false

        circleButton.titleLabel?.font = UIFont.systemFont(ofSize: PhotoPreviewConstant.skitchButtonFontSize)
        circleButton.setTitleColor(UIColor.white, for: .normal)
        circleButton.backgroundColor = PhotoPreviewConstant.skitchButtonBgColor
        circleButton.addTarget(self, action: #selector(handleSkitchButtonTap(_:)), for: .touchUpInside)
        
        circleButton.layer.cornerRadius = PhotoPreviewConstant.skitchButtonRadius/2
        circleButton.clipsToBounds = false
        circleButton.layer.shadowColor = UIColor.black.cgColor
        circleButton.layer.shadowOpacity = 0.2
        circleButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        circleButton.layer.shadowRadius = 4

        return circleButton
    }

    private func makeSkitchRectangleButton() -> UIButton {
        let rectangleButton = UIButton()
        rectangleButton.translatesAutoresizingMaskIntoConstraints = false
        rectangleButton.layer.masksToBounds = true
        rectangleButton.layer.cornerRadius = 2
        rectangleButton.layer.borderWidth = 1
        rectangleButton.layer.borderColor = PhotoPreviewConstant.skitchButtonBgColor.cgColor
        rectangleButton.backgroundColor = PhotoPreviewConstant.skitchRectangleButtonBgColor
        rectangleButton.addTarget(self, action: #selector(handleSkitchButtonTap(_:)), for: .touchUpInside)
        return rectangleButton
    }

    func commonInit() {
        // rectangle button constraint
        self.addSubview(skitchRectangleButton)
        self.addConstraint(NSLayoutConstraint(item: skitchRectangleButton, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: skitchRectangleButton, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: skitchRectangleButton, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: skitchRectangleButton, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0))

        // circle button constraint
        self.addSubview(skitchCircleButton)
        self.addConstraint(NSLayoutConstraint(item: skitchCircleButton, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: -PhotoPreviewConstant.skitchButtonRadius/2))
        self.addConstraint(NSLayoutConstraint(item: skitchCircleButton, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: -PhotoPreviewConstant.skitchButtonRadius/2))
        self.addConstraint(NSLayoutConstraint(item: skitchCircleButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: PhotoPreviewConstant.skitchButtonRadius))
        self.addConstraint(NSLayoutConstraint(item: skitchCircleButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: PhotoPreviewConstant.skitchButtonRadius))
    }
    
    func setTitle(_ title: String, index: Int) {
        skitchCircleButton.setTitle(title, for: .normal)
        skitchCircleButton.tag = PhotoPreviewConstant.skitchButtonTag + index
        skitchRectangleButton.tag = PhotoPreviewConstant.skitchButtonTag + index
    }

    func handleSkitchButtonTap(_ button: UIButton) {
        let index = button.tag - PhotoPreviewConstant.skitchButtonTag

        UIView.animate(withDuration: 0.15, delay: 0, options: [.curveEaseInOut], animations: {
            self.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }, completion: { _ in
            UIView.animate(withDuration: 0.15, delay: 0, options: [.curveEaseInOut], animations: {
                self.transform = CGAffineTransform(scaleX: 1, y: 1)
            }, completion: { _ in
                self.delegate?.didPressedSkitchView(skitchView: self, index: index)
            })
        })
    }
}
