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
    
    private let listCellViewController: ListViewController
    private let listCellFrame: CGRect
    private let animationDuration = 0.5
    
    init(listCellViewController: ListViewController, listCellFrame: CGRect, intereactionController: ZoomInteractionController?) {
        let originFrame = CGRect(x: listCellFrame.minX, y: listCellFrame.minY, width: listCellFrame.width, height: listCellFrame.height)
        
        self.listCellViewController = listCellViewController
        self.listCellFrame = originFrame
        self.zoomInteractionController = intereactionController
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return animationDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let originVC = transitionContext.viewController(forKey: .from) as? ListViewController,
              let originActionButton = originVC.actionButton else { return }
        
        originActionButton.isHidden = true
        
        guard let snapShot = originVC.view.snapshotView(afterScreenUpdates: true) else { return }
        
        let sudoActionButton = UIImageView.init(frame: originActionButton.frame)
        sudoActionButton.image = originActionButton.currentBackgroundImage
        
        let containerView = transitionContext.containerView
        containerView.addSubview(snapShot)
        containerView.addSubview(sudoActionButton)
        
        originVC.view.isHidden = true
        
        let duration = transitionDuration(using: transitionContext)
        
        UIView.animateKeyframes(withDuration: duration, delay: 0, options: .calculationModeCubic, animations: {
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1.0) {
                snapShot.frame = self.listCellFrame.offsetBy(dx: 0, dy: 0)
                sudoActionButton.alpha = 0
            }
        }, completion: { [weak self] _ in
            guard let self = self else { return }
            self.listCellViewController.setListMode(.Cell)
            snapShot.removeFromSuperview()
            sudoActionButton.removeFromSuperview()
            
            if transitionContext.transitionWasCancelled {
                originActionButton.isHidden = false
            }
            
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}
