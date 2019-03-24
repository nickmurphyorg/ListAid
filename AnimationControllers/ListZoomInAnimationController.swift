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
    private let listNameLabel: UITextField
    private let addItemsButton: UIButton
    private let animationDuration = 0.5
    private let listStyleMetrics = ListStyleMetric()
    private let statusBarHeight: CGFloat!
    
    init(listCellFrame: CGRect, listNameLabel: UITextField, addItemsButton: UIButton) {
        statusBarHeight = UIApplication.shared.statusBarFrame.height * listStyleMetrics.scaleFactor
        
        let originFrame = CGRect(x: listCellFrame.minX, y: listCellFrame.minY, width: listCellFrame.width, height: listCellFrame.height + statusBarHeight)
        
        self.listCellFrame = originFrame
        self.listNameLabel = listNameLabel
        self.addItemsButton = addItemsButton
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return animationDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let destinationVC = transitionContext.viewController(forKey: .to),
            let addItemsButtonImage = addItemsButton.currentBackgroundImage
            else {
                return
        }
        
        addItemsButton.isHidden = true
        
        guard let snapShot = destinationVC.view.snapshotView(afterScreenUpdates: true) else { return }
        
        // Create Sudo Add Items Button
        let sudoAddItemsButton = UIImageView.init(frame: addItemsButton.frame)
        sudoAddItemsButton.image = addItemsButtonImage
        sudoAddItemsButton.alpha = 0
        
        let containerView = transitionContext.containerView
        let destinationFrame = transitionContext.finalFrame(for: destinationVC)
        
        snapShot.frame = listCellFrame.offsetBy(dx: 0, dy: -statusBarHeight)
        
        containerView.addSubview(destinationVC.view)
        containerView.addSubview(snapShot)
        containerView.addSubview(sudoAddItemsButton)
        destinationVC.view.isHidden = true
        
        let duration = transitionDuration(using: transitionContext)
        
        UIView.animateKeyframes(withDuration: duration, delay: 0, options: .calculationModeCubic, animations: {
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.0) {
                self.listNameLabel.alpha = 0
            }
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1.0) {
                sudoAddItemsButton.alpha = 1
                snapShot.frame = destinationFrame
            }
        }, completion: { _ in
            self.addItemsButton.isHidden = false
            destinationVC.view.isHidden = false
            sudoAddItemsButton.removeFromSuperview()
            snapShot.removeFromSuperview()
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
    
}
