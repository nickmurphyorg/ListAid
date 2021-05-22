//
//  ListZoomInAnimationController.swift
//  Listaid
//
//  Created by Nick Murphy on 11/3/18.
//  Copyright © 2018 Nick Murphy. All rights reserved.
//

import UIKit

class ListZoomInAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    private let listCellViewController: ListViewController
    private let listCellFrame: CGRect
    private let animationDuration = 0.5
    private let listStyleMetrics = ListStyleMetric()
    private let statusBarHeight: CGFloat!
    
    init(listCellViewController: ListViewController, listCellFrame: CGRect) {
        statusBarHeight = UIApplication.shared.statusBarFrame.height * listStyleMetrics.scaleFactor
        
        let originFrame = CGRect(x: listCellFrame.minX, y: listCellFrame.minY, width: listCellFrame.width, height: listCellFrame.height)
        
        self.listCellViewController = listCellViewController
        self.listCellFrame = originFrame
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return animationDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let destinationVC = transitionContext.viewController(forKey: .to) as? ListViewController,
              let destinationActionButton = destinationVC.actionButton
            else {
                return
        }
        
        destinationActionButton.isHidden = true
        
        guard let snapShot = destinationVC.view.snapshotView(afterScreenUpdates: true) else { return }
        snapShot.frame = listCellFrame.offsetBy(dx: 0, dy: 0)
        
        let sudoActionButton = UIImageView.init(frame: destinationActionButton.frame)
        sudoActionButton.image = destinationActionButton.currentBackgroundImage
        sudoActionButton.alpha = 0
        
        let containerView = transitionContext.containerView
        containerView.addSubview(destinationVC.view)
        containerView.addSubview(snapShot)
        containerView.addSubview(sudoActionButton)
        destinationVC.view.isHidden = true
        
        let duration = transitionDuration(using: transitionContext)
        let destinationFrame = transitionContext.finalFrame(for: destinationVC)
        
        UIView.animateKeyframes(withDuration: duration, delay: 0, options: .calculationModeCubic, animations: {
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.0) { [weak self] in
                guard let self = self else { return }
                self.listCellViewController.setListMode(.Selected)
            }
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1.0) {
                sudoActionButton.alpha = 1
                snapShot.frame = destinationFrame
            }
        }, completion: { _ in
            destinationActionButton.isHidden = false
            destinationVC.view.isHidden = false
            sudoActionButton.removeFromSuperview()
            snapShot.removeFromSuperview()
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}
