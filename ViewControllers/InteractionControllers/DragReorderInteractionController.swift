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
    
    let uiView: UIView!
    let reorderListDelegate: ReorderListDelegate!
    
    init(uiView: UIView, reorderListDelegate: ReorderListDelegate) {
        self.uiView = uiView
        self.reorderListDelegate = reorderListDelegate
        
        addGesture(tableView: uiView)
    }
    
    private func addGesture(tableView: UIView) {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(dragCellView(gestureRecognizer:)))
        
        self.uiView.addGestureRecognizer(longPressGesture)
    }
    
    @objc func dragCellView(gestureRecognizer: UILongPressGestureRecognizer) {
        let longGesture = gestureRecognizer
        let pressState = gestureRecognizer.state
        let locationInTableview = longGesture.location(in: uiView)
        
        guard let indexPath = returnIndexPathFor(point: locationInTableview) else {
            print("Index path could not be retrieved.")
            
            return
        }
        
        switch pressState {
            case .began:
                guard let pressedCell = returnCellFor(indexPath: indexPath) else { return }
                
                if let snapShot = pressedCell.snapshotView(afterScreenUpdates: true) {
                    self.snapShot = snapShot
                    
                    var centerPoint = pressedCell.center
                    startingIndex = indexPath
                    
                    snapShot.center = centerPoint
                    snapShot.alpha = 0
                    
                    uiView.addSubview(snapShot)
                    
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
                    
                    moveCell(atIndexPath: startingIndex!, toIndexPath: indexPath)
                    
                    startingIndex = indexPath
                }
            
            default:
                guard startingIndex != nil,
                    snapShot != nil,
                    let animateCell = returnCellFor(indexPath: startingIndex!) else {
                    print("Table cell could not be found at index path.")
                    
                    return
                }
                animateCell.isHidden = false
                animateCell.alpha = 0
                
                UIView.animate(withDuration: 0.25, animations: {() -> Void in
                    self.snapShot!.center = animateCell.center
                    
                    self.snapShot!.transform = CGAffineTransform.identity
                    self.snapShot!.alpha = 0
                    
                    animateCell.alpha = 1
                }, completion: {(bool) -> Void in
                    self.snapShot!.removeFromSuperview()
                    
                    self.startingIndex = nil
                    self.snapShot = nil
                })
                return
        }
    }
}

extension DragReorderInteractionController {
    private func returnIndexPathFor(point: CGPoint) -> IndexPath? {
        if uiView.isMember(of: UITableView.self) {
            let tableView = uiView as! UITableView
        
            return tableView.indexPathForRow(at: point)
        } else if uiView.isMember(of: UICollectionView.self) {
            let collectionView = uiView as! UICollectionView
        
            return collectionView.indexPathForItem(at: point)
        } else {
            print("The view is not a member of UITableView or UICollectionView.")
        
            return nil
        }
    }
}

extension DragReorderInteractionController {
    func returnCellFor(indexPath: IndexPath) -> UIView? {
        if uiView.isMember(of: UITableView.self) {
            let tableView = uiView as! UITableView
            
            return tableView.cellForRow(at: indexPath)
        } else if uiView.isMember(of: UICollectionView.self) {
            let collectionView = uiView as! UICollectionView
            
            return collectionView.cellForItem(at: indexPath)
        } else {
            print("Cell could not be returned for index path.")
            
            return nil
        }
    }
}

extension DragReorderInteractionController {
    func moveCell(atIndexPath: IndexPath, toIndexPath: IndexPath) {
        if uiView.isMember(of: UITableView.self) {
            let tableView = uiView as! UITableView
            
            tableView.moveRow(at: atIndexPath, to: toIndexPath)
        } else if uiView.isMember(of: UICollectionView.self) {
            let collectionView = uiView as! UICollectionView
            
            collectionView.moveItem(at: atIndexPath, to: toIndexPath)
        } else {
            print("UIView is not a UITableView or UICollectionView. \n Cannot move cell.")
        }
    }
}
