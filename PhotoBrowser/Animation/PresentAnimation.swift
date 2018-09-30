//
//  PresentAnimation.swift
//  PhotoBrowser
//
//  Created by zouliangming on 2018/8/6.
//  Copyright © 2018年 Teambition. All rights reserved.
//

import Foundation

open class PresentAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    open var fromView: UIView
    open var snapshot: UIView
    
    public init(fromView: UIView, snapshot: UIView) {
        self.fromView = fromView
        self.snapshot = snapshot
        super.init()
    }
    
    open func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return PBConstant.Animation.presentDuration
    }
    
    open func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) else {
            return
        }

        let container = transitionContext.containerView
        container.addSubview(self.snapshot)
        container.addSubview(toViewController.view)
        let fromFrame = container.convert(fromView.frame, from: fromView.superview)
        let toFrame = transitionContext.finalFrame(for: toViewController)
        
        let scale = CGAffineTransform(scaleX: fromFrame.width/toFrame.width, y: fromFrame.height/toFrame.height)
        let translate = CGAffineTransform(translationX: -(toViewController.view.center.x - fromFrame.midX), y: -(toViewController.view.center.y - fromFrame.midY))
        toViewController.view.transform = scale.concatenating(translate)
        toViewController.view.alpha = 0
        
        UIView.animate(withDuration: PBConstant.Animation.presentDuration, delay: 0, options: UIView.AnimationOptions(), animations: {
            toViewController.view.transform = CGAffineTransform(scaleX: 1, y: 1)
            toViewController.view.alpha = 1
            self.fromView.alpha = 0
        }) { (_) in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            self.fromView.alpha = 1
        }
    }
}
