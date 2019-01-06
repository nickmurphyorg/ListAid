//
//  StrikeInteractionController.swift
//  Listaid
//
//  Created by Nick Murphy on 1/2/19.
//  Copyright © 2019 Nick Murphy. All rights reserved.
//

import Foundation
import UIKit

class StrikeInteractionController {
    
    private var shouldCompleteStrike = false
    private var interactionInProgress = false
    private weak var tableViewCell: UITableViewCell!
    private weak var contentView: UIView!
    private weak var strikeView: UIView!
    private var strikeStandardWidth: CGFloat!
    private var strikeCompleteWidth: CGFloat!
    
    init(tableCell: UITableViewCell, strikeStandardWidth: CGFloat, strikeCompleteWidth: CGFloat) {
        guard let tableCell = tableCell as? ItemTableViewCell else { return }
        
        tableViewCell = tableCell
        contentView = tableCell.contentView
        strikeView = tableCell.strikeThrough
        self.strikeStandardWidth = strikeStandardWidth
        self.strikeCompleteWidth = strikeCompleteWidth
        
        prepareGestureRecognizer(tableViewCell: tableViewCell)
    }
    
    private func prepareGestureRecognizer(tableViewCell: UITableViewCell) {
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleGesture(gestureRecognizer:)))
        gestureRecognizer.delegate = tableViewCell
        
        tableViewCell.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc func handleGesture(gestureRecognizer: UIPanGestureRecognizer) {
        guard strikeView.frame.width < strikeCompleteWidth! else { return }
        
        switch gestureRecognizer.state {
            case .began:
                interactionInProgress = true
            
            case .changed:
                let translation = gestureRecognizer.translation(in: gestureRecognizer.view)
                let beginAnimation = translation.x > 10
                
                if beginAnimation && interactionInProgress {
                    let progress = translation.x / strikeCompleteWidth
                    let strikeWidth = strikeStandardWidth + ((strikeCompleteWidth - strikeStandardWidth) * progress)
                    
                    if strikeWidth <= strikeCompleteWidth {
                        strikeView.frame.size.width = strikeWidth
                    }
                    
                    shouldCompleteStrike = progress > 0.5
                }
            
            case .cancelled:
                interactionInProgress = false
                strikeView.frame.size.width = strikeStandardWidth
            
            case .ended:
                interactionInProgress = false
                
                // Animate the complete strike...
                if shouldCompleteStrike {
                    strikeView.frame.size.width = strikeCompleteWidth
                    
                    guard let tableViewCell = tableViewCell as? ItemTableViewCell else { return }
                    
                    tableViewCell.strikeCompleteDelegate?.completeItem(tableViewCell: tableViewCell)
                } else {
                    strikeView.frame.size.width = strikeStandardWidth
                }
            
            default:
                break;
        }
    }
}
