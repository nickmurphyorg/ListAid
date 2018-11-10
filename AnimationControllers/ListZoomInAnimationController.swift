//
//  ListZoomInAnimationController.swift
//  Listaid
//
//  Created by Nick Murphy on 11/3/18.
//  Copyright © 2018 Nick Murphy. All rights reserved.
//

import UIKit

class ListZoomInAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    private let listCellFrame: CGRect
    private let animationDuration = 0.5
    private let statusBarHeight = UIApplication.shared.statusBarFrame.height * 0.8
    
    init(listCellFrame: CGRect) {
        let originFrame = CGRect(x: listCellFrame.minX, y: listCellFrame.minY, width: listCellFrame.width, height: listCellFrame.height + statusBarHeight)
        
        self.listCellFrame = originFrame
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return animationDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let destinationVC = transitionContext.viewController(forKey: .to),
            let snapShot = destinationVC.view.snapshotView(afterScreenUpdates: true)
            else {
                return
        }
        
        let containerView = transitionContext.containerView
        let destinationFrame = transitionContext.finalFrame(for: destinationVC)
        
        snapShot.frame = listCellFrame.offsetBy(dx: 0, dy: -statusBarHeight)
        
        containerView.addSubview(destinationVC.view)
        containerView.addSubview(snapShot)
        destinationVC.view.isHidden = true
        
        let duration = transitionDuration(using: transitionContext)
        
        UIView.animateKeyframes(withDuration: duration, delay: 0, options: .calculationModeCubic, animations: {
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1.0) {
                snapShot.frame = destinationFrame
            }
        }, completion: { _ in
            destinationVC.view.isHidden = false
            snapShot.removeFromSuperview()
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
    
}
