//
//  PresentAnimation.swift
//  PhotoBrowser
//
//  Created by WangWei on 16/3/14.
//  Copyright © 2016年 Teambition. All rights reserved.
//

import UIKit

let TransitionDuration = 0.3

extension UIViewController {
    public func showPhotoBrowser(photoBrowser: PhotoBrowser, fromView: UIImageView, inNavigationController: Bool = false) {
        photoBrowser.transitionDelegate = TransitionDelegate(photoBrowser: photoBrowser, fromView: fromView)
        if inNavigationController {
            let navigationController = UINavigationController(rootViewController: photoBrowser)
            navigationController.transitioningDelegate = photoBrowser.transitionDelegate
            navigationController.setNavigationBarHidden(true, animated: false)
            presentViewController(navigationController, animated: true, completion: nil)
        } else {
            presentViewController(photoBrowser, animated: true, completion: nil)
        }
    }
    
    public func dismissPhotoBrowser(photoBrowser: PhotoBrowser, toView: UIView? = nil) {
        photoBrowser.transitionDelegate?.toView = toView
        dismissViewControllerAnimated(true, completion: nil)
    }
}

public class TransitionDelegate: NSObject, UIViewControllerTransitioningDelegate {
    var startIndex: Int!
    public var fromView: UIImageView!
    public var toView: UIView?
    public weak var photoBrowser: PhotoBrowser!
    
    init(photoBrowser: PhotoBrowser, fromView: UIImageView) {
        super.init()
        self.fromView = fromView
        self.photoBrowser = photoBrowser
        startIndex = photoBrowser.currentIndex
    }
    
    public func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PresentAnimation(photoBrowser: photoBrowser, fromView: fromView)
    }
    
    public func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if let destView = toView {
            return DismissAnimation(photoBrowser: photoBrowser, toView: destView)
        } else {
            return DismissImmediatelyAnimation()
        }
    }
}

public class PresentAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    
    public var fromView: UIImageView!
    public weak var photoBrowser: PhotoBrowser!
    
    public init(photoBrowser: PhotoBrowser, fromView: UIImageView) {
        super.init()
        self.fromView = fromView
        self.photoBrowser = photoBrowser
        
    }
    
    public func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return TransitionDuration
    }
    
    public func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        let container = transitionContext.containerView()!
        
        let snapshotView = UIImageView(image: fromView.image)
        snapshotView.contentMode = fromView.contentMode
        snapshotView.clipsToBounds = fromView.clipsToBounds
        snapshotView.frame = container.convertRect(fromView.frame, fromView: fromView.superview)
        
        toVC.view.alpha = 0
        photoBrowser.currentImageView()?.alpha = 0
        fromView.hidden = true
        
        let imageSize = photoBrowser.currentPhoto?.originalImageSize ?? self.fromView.image?.size
        
        container.addSubview(toVC.view)
        container.addSubview(snapshotView)
        
        UIView.animateWithDuration(TransitionDuration, animations: { () -> Void in
            let finalFrame = self.finalFrameForImageWithSize(imageSize, inTransitionContext: transitionContext)
            snapshotView.frame = finalFrame
            toVC.view.alpha = 1
            }) { (finished) -> Void in
                self.fromView.hidden = false
                self.photoBrowser.currentImageView()?.alpha = 1
                snapshotView.removeFromSuperview()
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        }
    }
    
    func finalFrameForImageWithSize(imageSize: CGSize?, inTransitionContext transitionContext: UIViewControllerContextTransitioning) -> CGRect {
        let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)
        guard let destVC = toVC, let imageSize = imageSize else {
            return CGRectZero
        }
        
        let viewSize = transitionContext.finalFrameForViewController(destVC).size
        
        let xScale = imageSize.width / viewSize.width
        let yScale = imageSize.height / viewSize.height
        
        let finalScale = max(max(xScale, yScale), 1.0)
        let finalSize = CGSizeMake(imageSize.width / finalScale, imageSize.height / finalScale)
        
        let center = destVC.view.center
        return CGRectMake(center.x - finalSize.width/2, center.y-finalSize.height/2, finalSize.width, finalSize.height)
    }
}

public class DismissAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    
    public weak var photoBrowser: PhotoBrowser!
    public var toView: UIView!
    
    init(photoBrowser: PhotoBrowser, toView: UIView) {
        super.init()
        self.photoBrowser = photoBrowser
        self.toView = toView
    }
    
    public func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return TransitionDuration
    }
    
    public func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        guard let currentPhoto = photoBrowser.currentPhoto, let currentImageView = photoBrowser.currentImageView() else {
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
            return
        }
        let image = currentPhoto.localOriginalPhoto() ?? currentPhoto.localThumbnailPhoto()
        let snapshotView = UIImageView(image: image)
        snapshotView.frame = currentImageView.frame
        snapshotView.clipsToBounds = toView.clipsToBounds
        snapshotView.contentMode = toView.contentMode
        
        let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        toVC.view.frame = transitionContext.finalFrameForViewController(toVC)
        let container = transitionContext.containerView()!
        container.addSubview(toVC.view)
        container.addSubview(snapshotView)
        toView.alpha = 0
        currentImageView.hidden = true
        
        let finalFrame = container.convertRect(toView.frame, fromView: toView.superview)
        
        UIView.animateWithDuration(TransitionDuration, animations: { () -> Void in
            snapshotView.frame = finalFrame
            }) { (_) -> Void in
                self.toView.alpha = 1
                currentImageView.hidden = false
                snapshotView.removeFromSuperview()
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        }
    }
    
}

public class DismissImmediatelyAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    
    public func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return TransitionDuration/2
    }
    
    public func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        
        transitionContext.containerView()?.addSubview(toVC.view)
        transitionContext.containerView()?.addSubview(fromVC.view)
        
        UIView.animateWithDuration(TransitionDuration/2, animations: { () -> Void in
            fromVC.view.alpha = 0
            }) { (_) -> Void in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        }
    }
}
























