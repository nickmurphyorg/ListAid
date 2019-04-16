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
    
    private let listStyleMetrics = ListStyleMetric()
    
    var interactionInProgress = false
    
    private var shouldCompleteStrike = false
    private weak var viewController: UIViewController!
    private weak var tableView: UITableView!
    private var cellIndex: IndexPath?
    private weak var tableViewCell: UITableViewCell?
    private weak var strikeView: UIView?
    private var strikeStandardWidth: CGFloat!
    private var strikeCompleteWidth: CGFloat?
    
    init(viewController: UIViewController, tableView: UITableView) {
        self.viewController = viewController
        self.tableView = tableView
        self.strikeStandardWidth = listStyleMetrics.strikeWidth
        
        prepareGestureRecognizer(tableView: tableView)
    }
    
    private func prepareGestureRecognizer(tableView: UITableView) {
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleGesture(gestureRecognizer:)))
        gestureRecognizer.delegate = viewController as? UIGestureRecognizerDelegate
        
        tableView.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc func handleGesture(gestureRecognizer: UIPanGestureRecognizer) {
        let locationInView = gestureRecognizer.location(in: gestureRecognizer.view)
        let translation = gestureRecognizer.translation(in: gestureRecognizer.view)
        
        switch gestureRecognizer.state {
            case .began:
                guard let cellIndex = tableView.indexPathForRow(at: locationInView),
                    let tableViewCell = tableView.cellForRow(at: cellIndex) as? ItemTableViewCell,
                    let strikeView = tableViewCell.strikeThrough else { return }
                
                self.cellIndex = cellIndex
                self.tableViewCell = tableViewCell
                self.strikeView = strikeView
                strikeCompleteWidth = tableViewCell.itemNameLabel.intrinsicContentSize.width + listStyleMetrics.strikeCompleteMargin
                
                // If item is complete do not animate
                interactionInProgress = strikeView.frame.width.rounded() < strikeCompleteWidth!.rounded()
            
            case .changed:
                guard strikeCompleteWidth != nil,
                    strikeView != nil else { return }
                
                let beginAnimation = translation.x > 10
                
                if interactionInProgress && beginAnimation {
                    let progress = translation.x / strikeCompleteWidth!
                    let strikeWidth = strikeStandardWidth + ((strikeCompleteWidth! - strikeStandardWidth) * progress)
                    
                    if strikeWidth <= strikeCompleteWidth! {
                        strikeView!.frame.size.width = strikeWidth
                    }
                    
                    shouldCompleteStrike = progress > 0.5
                }
            
            default:
                guard strikeCompleteWidth != nil,
                    strikeView != nil,
                    tableViewCell != nil,
                    interactionInProgress == true else { return }
                
                // Animate the strike...
                if shouldCompleteStrike {
                    strikeView!.frame.size.width = strikeCompleteWidth!
                    
                    if let tableViewCell = tableViewCell as? ItemTableViewCell {
                        tableViewCell.strikeCompleteDelegate?.completeItem(tableViewCell: tableViewCell)
                    }
                    
                    shouldCompleteStrike = false
                } else {
                    strikeView!.frame.size.width = strikeStandardWidth
                }
            
                cellIndex = nil
                tableViewCell = nil
                strikeView = nil
                strikeCompleteWidth = nil
                interactionInProgress = false
        }
    }
}
