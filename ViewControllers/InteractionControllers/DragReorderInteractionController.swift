//
//  DragReorderInteractionController.swift
//  Listaid
//
//  Created by Nick Murphy on 1/21/19.
//  Copyright © 2019 Nick Murphy. All rights reserved.
//

import Foundation
import UIKit

class DragReorderInteractionController {
    
    var startingIndex: IndexPath?
    var snapShot: UIView?
    
    let tableView: UITableView!
    let reorderListDelegate: ReorderListDelegate!
    
    init(tableView: UITableView, reorderListDelegate: ReorderListDelegate) {
        self.tableView = tableView
        self.reorderListDelegate = reorderListDelegate
        
        addGesture(tableView: tableView)
    }
    
    private func addGesture(tableView: UITableView) {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(dragTableViewCell(gestureRecognizer:)))
        
        self.tableView.addGestureRecognizer(longPressGesture)
    }
    
    @objc func dragTableViewCell(gestureRecognizer: UILongPressGestureRecognizer) {
        let longGesture = gestureRecognizer
        let pressState = gestureRecognizer.state
        let locationInTableview = longGesture.location(in: tableView)
        
        guard let indexPath = tableView.indexPathForRow(at: locationInTableview) else {
            print("Index path could not be retrieved.")
            
            return
        }
        
        switch pressState {
            case .began:
                guard let pressedCell = tableView.cellForRow(at: indexPath) else { return }
                
                if let snapShot = pressedCell.snapshotView(afterScreenUpdates: true) {
                    self.snapShot = snapShot
                    
                    var centerPoint = pressedCell.center
                    startingIndex = indexPath
                    
                    snapShot.center = centerPoint
                    snapShot.alpha = 0
                    
                    tableView.addSubview(snapShot)
                    
                    UIView.animate(withDuration: 0.25, animations: {() -> Void in
                        centerPoint.y = locationInTableview.y
                        snapShot.center = centerPoint
                        snapShot.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                        snapShot.alpha = 1
                        
                    }, completion: {(bool) -> Void in
                        pressedCell.isHidden = true
                    })
                }
            
            case .changed:
                guard snapShot != nil else { return }
                
                var updatedCenter = snapShot!.center
                updatedCenter.y = locationInTableview.y
                snapShot!.center = updatedCenter
            
                if startingIndex != nil && indexPath != startingIndex {
                    reorderListDelegate.moveItem(at: startingIndex!.row, to: indexPath.row)
                    tableView.moveRow(at: startingIndex!, to: indexPath)
                    startingIndex = indexPath
                }
            
            default:
                guard startingIndex != nil,
                    snapShot != nil,
                    let tableCell = tableView.cellForRow(at: startingIndex!) else {
                    print("Table cell could not be found at index path.")
                    
                    return
                }
                tableCell.isHidden = false
                tableCell.alpha = 0
                
                UIView.animate(withDuration: 0.25, animations: {() -> Void in
                    self.snapShot!.center = tableCell.center
                    
                    self.snapShot!.transform = CGAffineTransform.identity
                    self.snapShot!.alpha = 0
                    
                    tableCell.alpha = 1
                }, completion: {(bool) -> Void in
                    self.snapShot!.removeFromSuperview()
                    
                    self.startingIndex = nil
                    self.snapShot = nil
                })
                return
        }
    }
}
