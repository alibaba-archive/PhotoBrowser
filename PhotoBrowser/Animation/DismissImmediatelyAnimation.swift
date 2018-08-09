//
//  DismissImmediatelyAnimation.swift
//  PhotoBrowser
//
//  Created by zouliangming on 2018/8/6.
//  Copyright © 2018年 Teambition. All rights reserved.
//

import Foundation

open class DismissImmediatelyAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    open func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return PBConstant.Animation.dismissDuration/2
    }
    
    open func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from), let toVC = transitionContext.viewController(forKey: .to) else {
            return
        }
        
        transitionContext.containerView.addSubview(toVC.view)
        transitionContext.containerView.addSubview(fromVC.view)
        
        UIView.animate(withDuration: PBConstant.Animation.dismissDuration/2, animations: { () -> Void in
            fromVC.view.alpha = 0
        }, completion: { (_) -> Void in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}
