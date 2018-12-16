//
//  ListZoomOutAnimationController.swift
//  Listaid
//
//  Created by Nick Murphy on 11/4/18.
//  Copyright © 2018 Nick Murphy. All rights reserved.
//

import UIKit

class ListZoomOutAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    let zoomInteractionController: ZoomInteractionController?
    
    private let listCellFrame: CGRect
    private let animationDuration = 0.5
    private let statusBarHeight = UIApplication.shared.statusBarFrame.height * 0.8
    
    init(listCellFrame: CGRect, intereactionController: ZoomInteractionController?) {
        let originFrame = CGRect(x: listCellFrame.minX, y: listCellFrame.minY, width: listCellFrame.width, height: listCellFrame.height + statusBarHeight)
        
        self.zoomInteractionController = intereactionController
        self.listCellFrame = originFrame
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return animationDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let originVC = transitionContext.viewController(forKey: .from),
            let destinationVC = transitionContext.viewController(forKey: .to),
            let snapShot = originVC.view.snapshotView(afterScreenUpdates: false)
            else {
                return
        }
        
        let containerView = transitionContext.containerView
        containerView.insertSubview(destinationVC.view, at: 0)
        containerView.addSubview(snapShot)
        originVC.view.isHidden = true
        
        let duration = transitionDuration(using: transitionContext)
        
        UIView.animateKeyframes(withDuration: duration, delay: 0, options: .calculationModeCubic, animations: {
            // Update with weak self
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1.0) {
                snapShot.frame = self.listCellFrame.offsetBy(dx: 0, dy: -self.statusBarHeight)
            }
        }, completion: { _ in
            originVC.view.isHidden = false
            snapShot.removeFromSuperview()
            
            if transitionContext.transitionWasCancelled {
                destinationVC.view.removeFromSuperview()
            }
            
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }

}
