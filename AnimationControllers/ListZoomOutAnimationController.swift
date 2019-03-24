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
    private let listNameLabel: UITextField
    private let addItemsButton: UIButton
    private let animationDuration = 0.5
    private let listStyleMetrics = ListStyleMetric()
    private let statusBarHeight: CGFloat!
    
    init(listCellFrame: CGRect, listNameLabel: UITextField, addItemsButton: UIButton, intereactionController: ZoomInteractionController?) {
        statusBarHeight = UIApplication.shared.statusBarFrame.height * listStyleMetrics.scaleFactor
        
        let originFrame = CGRect(x: listCellFrame.minX, y: listCellFrame.minY, width: listCellFrame.width, height: listCellFrame.height + statusBarHeight)
        
        self.zoomInteractionController = intereactionController
        self.listCellFrame = originFrame
        self.listNameLabel = listNameLabel
        self.addItemsButton = addItemsButton
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return animationDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let originVC = transitionContext.viewController(forKey: .from),
            let destinationVC = transitionContext.viewController(forKey: .to),
            let addItemsButtonImage = addItemsButton.currentBackgroundImage
            else {
                return
        }
        
        addItemsButton.isHidden = true
        
        guard let snapShot = originVC.view.snapshotView(afterScreenUpdates: true) else { return }
        
        // Create Sudo Add Items Button
        let sudoAddItemsButton = UIImageView.init(frame: addItemsButton.frame)
        sudoAddItemsButton.image = addItemsButtonImage
        
        let containerView = transitionContext.containerView
        containerView.insertSubview(destinationVC.view, at: 0)
        containerView.addSubview(snapShot)
        containerView.addSubview(sudoAddItemsButton)
        originVC.view.isHidden = true
        
        let duration = transitionDuration(using: transitionContext)
        
        UIView.animateKeyframes(withDuration: duration, delay: 0, options: .calculationModeCubic, animations: {
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1.0) {
                sudoAddItemsButton.alpha = 0
                snapShot.frame = self.listCellFrame.offsetBy(dx: 0, dy: -self.statusBarHeight)
            }
            UIView.addKeyframe(withRelativeStartTime: 1.0, relativeDuration: 0.0) {
                self.listNameLabel.alpha = 1
            }
        }, completion: { _ in
            originVC.view.isHidden = false
            snapShot.removeFromSuperview()
            sudoAddItemsButton.removeFromSuperview()
            
            if transitionContext.transitionWasCancelled {
                destinationVC.view.removeFromSuperview()
                self.addItemsButton.isHidden = false
                self.listNameLabel.alpha = 0
            }
            
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }

}
