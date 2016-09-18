//
//  PresentAnimation.swift
//  PhotoBrowser
//
//  Created by WangWei on 16/3/14.
//  Copyright © 2016年 Teambition. All rights reserved.
//

import UIKit

let PresentDuration = 0.3
let DismissDuration = 0.35
var AssociatedObjectHandle: UInt8 = 0

extension UIViewController {

    public func presentPhotoBrowser(_ viewControllerToPresent: UIViewController, fromView: UIView) {
        let transitionDelegate = TransitionDelegate(fromView: fromView)
        let navigationController = UINavigationController(rootViewController: viewControllerToPresent)
        navigationController.modalPresentationStyle = .fullScreen
        navigationController.pb_transitionDelegate = transitionDelegate
        navigationController.transitioningDelegate = transitionDelegate
        present(navigationController, animated: true, completion: nil)
    }
    
    public func dismissPhotoBrowser(toView: UIView? = nil) {
        if let viewController = presentedViewController {
            viewController.pb_transitionDelegate.toView = toView
        }
        dismiss(animated: true, completion: nil)
    }

    internal var pb_transitionDelegate: TransitionDelegate {
        get {
            return objc_getAssociatedObject(self, &AssociatedObjectHandle) as! TransitionDelegate
        }
        set {
            objc_setAssociatedObject(self, &AssociatedObjectHandle, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

open class TransitionDelegate: NSObject, UIViewControllerTransitioningDelegate {
    open var fromView: UIView!
    open var toView: UIView?
    
    init(fromView: UIView) {
        super.init()
        self.fromView = fromView
        self.toView = fromView
    }
    
    open func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PresentAnimation(fromView: fromView)
    }
    
    open func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if let destView = toView {
            return DismissAnimation(toView: destView)
        } else {
            return DismissImmediatelyAnimation()
        }
    }
}

open class PresentAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    open var fromView: UIView!
    
    public init(fromView: UIView) {
        super.init()
        self.fromView = fromView
    }

    open func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return PresentDuration
    }
 
    open func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
        let container = transitionContext.containerView
 
        container.addSubview(toVC.view)
        let fromFrame = container.convert(fromView.frame, from: fromView.superview)
        let toFrame = transitionContext.finalFrame(for: toVC)
        
        let scale = CGAffineTransform(scaleX: fromFrame.width/toFrame.width, y: fromFrame.height/toFrame.height)
        let translate = CGAffineTransform(translationX: -(toVC.view.center.x - fromFrame.midX), y: -(toVC.view.center.y - fromFrame.midY))
        toVC.view.transform = scale.concatenating(translate)
        toVC.view.alpha = 0
        
        UIView.animate(withDuration: PresentDuration, delay: 0, options: UIViewAnimationOptions(), animations: {
            toVC.view.transform = CGAffineTransform(scaleX: 1, y: 1)
            toVC.view.alpha = 1
            self.fromView.alpha = 0
            }) { (_) in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                self.fromView.alpha = 1
        }
    }
}

open class DismissAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    open var toView: UIView!
    
    init(toView: UIView) {
        super.init()
        self.toView = toView
    }
    
    open func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return DismissDuration
    }
    
    open func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let container = transitionContext.containerView
        let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
        let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!

        toVC.view.frame = transitionContext.finalFrame(for: toVC)
        container.addSubview(toVC.view)
        container.addSubview(fromVC.view)
        let toFrame = container.convert(toView.frame, from: toView.superview)
        let scale = CGAffineTransform(scaleX: toFrame.width/fromVC.view.frame.width, y: toFrame.height/fromVC.view.frame.height)
        let translate = CGAffineTransform(translationX: -(fromVC.view.center.x - toFrame.midX), y: -(fromVC.view.center.y - toFrame.midY))
        toView.alpha = 0
        
        UIView.animate(withDuration: DismissDuration, delay: 0, options: .curveEaseOut, animations: {
            fromVC.view.transform = scale.concatenating(translate)
            fromVC.view.alpha = 0
            self.toView.alpha = 1
            }) { (_) in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}

open class DismissImmediatelyAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    
    open func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return DismissDuration/2
    }
    
    open func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
        let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
        
        transitionContext.containerView.addSubview(toVC.view)
        transitionContext.containerView.addSubview(fromVC.view)
        
        UIView.animate(withDuration: DismissDuration/2, animations: { () -> Void in
            fromVC.view.alpha = 0
            }, completion: { (_) -> Void in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }) 
    }
}
