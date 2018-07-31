//
//  TransitionDelegate.swift
//  PhotoBrowser
//
//  Created by zouliangming on 2018/8/6.
//  Copyright © 2018年 Teambition. All rights reserved.
//

import Foundation

open class TransitionDelegate: NSObject, UIViewControllerTransitioningDelegate {
    open var fromView: UIView
    open var toView: UIView?
    open var snapshot: UIView
    
    init(fromView: UIView, snapshot: UIView) {
        self.fromView = fromView
        self.toView = fromView
        self.snapshot = snapshot
        super.init()
    }
    
    open func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PresentAnimation(fromView: fromView, snapshot: snapshot)
    }
    
    open func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if let destView = toView {
            return DismissAnimation(toView: destView)
        } else {
            return DismissImmediatelyAnimation()
        }
    }
}
