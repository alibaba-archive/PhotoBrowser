//
//  DismissAnimation.swift
//  PhotoBrowser
//
//  Created by zouliangming on 2018/8/6.
//  Copyright © 2018年 Teambition. All rights reserved.
//

import Foundation

open class DismissAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    open var toView: UIView
    
    init(toView: UIView) {
        self.toView = toView
        super.init()
    }
    
    open func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return PBConstant.Animation.dismissDuration
    }
    
    open func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromViewController = transitionContext.viewController(forKey: .from), let toViewController = transitionContext.viewController(forKey: .to) else {
            return
        }

        let container = transitionContext.containerView
        toViewController.view.frame = transitionContext.finalFrame(for: toViewController)
        container.addSubview(toViewController.view)
        container.addSubview(fromViewController.view)
        let toFrame = container.convert(toView.frame, from: toView.superview)
        let scale = CGAffineTransform(scaleX: toFrame.width/fromViewController.view.frame.width, y: toFrame.height/fromViewController.view.frame.height)
        let translate = CGAffineTransform(translationX: -(fromViewController.view.center.x - toFrame.midX), y: -(fromViewController.view.center.y - toFrame.midY))
        toView.alpha = 0
        
        UIView.animate(withDuration: PBConstant.Animation.dismissDuration, delay: 0, options: .curveEaseOut, animations: {
            fromViewController.view.transform = scale.concatenating(translate)
            fromViewController.view.alpha = 0
            self.toView.alpha = 1
        }) { (_) in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}
