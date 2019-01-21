//
//  ZoomInteractionController.swift
//  Listaid
//
//  Created by Nick Murphy on 11/10/18.
//  Copyright © 2018 Nick Murphy. All rights reserved.
//

import UIKit

class ZoomInteractionController: UIPercentDrivenInteractiveTransition {
    
    var interactionInProgress = false
    
    private var shouldCompleteTransition = false
    private weak var viewController: UIViewController!
    private weak var tableView: UITableView!
    
    init(viewController: UIViewController, tableView: UITableView) {
        super.init()
        
        self.viewController = viewController
        self.tableView = tableView
        
        prepareGestureRecognizer(in: tableView)
    }
    
    private func prepareGestureRecognizer(in view: UIView) {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleGesture(_:)))
        panGesture.delegate = viewController as? UIGestureRecognizerDelegate
        
        view.addGestureRecognizer(panGesture)
    }
    
    @objc func handleGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        let translation = gestureRecognizer.translation(in: gestureRecognizer.view)
        
        switch gestureRecognizer.state {
            case .began:
                if tableView.contentOffset.y == 0 && translation.y > translation.x {
                    interactionInProgress = true
                }
            case .changed:
                
                let beginZoomAnimation = translation.y > 10
                
                var progress = (translation.y / 200)
                progress = CGFloat(fminf(fmaxf(Float(progress), 0.0), 1.0))
                
                if beginZoomAnimation && interactionInProgress {
                    if !viewController.isBeingDismissed {
                        viewController.dismiss(animated: true, completion: nil)
                    }
                    
                    shouldCompleteTransition = progress > 0.5 && viewController.isBeingDismissed
                    update(progress)
                }
                
            case .cancelled:
                interactionInProgress = false
                cancel()
                
            case .ended:
                interactionInProgress = false
                shouldCompleteTransition ? finish() : cancel() ;
                
            default:
                break
        }
    }
}
