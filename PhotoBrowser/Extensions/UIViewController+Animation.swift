//
//  UIViewController+Animation.swift
//  PhotoBrowser
//
//  Created by zouliangming on 2018/8/6.
//  Copyright © 2018年 Teambition. All rights reserved.
//

import Foundation

extension UIViewController {
    var shotImageView: UIImageView {
        guard let window = UIApplication.shared.keyWindow else { return UIImageView() }
        UIGraphicsBeginImageContextWithOptions(window.bounds.size, false, 0)
        window.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        let snapshot: UIImageView
        snapshot = UIImageView(image: image)
        return snapshot
    }
    
    public func presentPhotoBrowser(_ viewControllerToPresent: UIViewController, fromView: UIView, animated: Bool? = true, completion: (() -> Void)? = nil) {
        let transitionDelegate = TransitionDelegate(fromView: fromView, snapshot: shotImageView)
        let navigationController = UINavigationController(rootViewController: viewControllerToPresent)
        navigationController.modalPresentationStyle = .fullScreen
        navigationController.pbTransitionDelegate = transitionDelegate
        navigationController.transitioningDelegate = transitionDelegate
        if let animated = animated {
            present(navigationController, animated: animated, completion: {
                completion?()
            })
        } else {
            present(navigationController, animated: true, completion: nil)
        }
    }
    
    public func dismissPhotoBrowser(toView: UIView? = nil) {
        dismiss(animated: true, completion: nil)
    }
    
    // swiftlint:disable force_cast
    internal var pbTransitionDelegate: TransitionDelegate {
        get {
            return objc_getAssociatedObject(self, &PBConstant.Animation.associatedObjectHandle) as! TransitionDelegate
        }
        set {
            objc_setAssociatedObject(self, &PBConstant.Animation.associatedObjectHandle, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
