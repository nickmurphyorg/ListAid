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
    var interactionInProgress = false
    private var startingIndex: IndexPath?
    private var snapShot: UIView?
    private weak var viewController: UIViewController!
    private weak var uiView: UIView!
    
    let notificationCenterName: NSNotification.Name!
    let reorderAxis: ReorderAxis!
    let sections: [Int]!
    
    init(viewController: UIViewController, uiView: UIView, notificationCenterName: NSNotification.Name, reorderAxis: ReorderAxis, sections: [Int]) {
        self.viewController = viewController
        self.uiView = uiView
        self.notificationCenterName = notificationCenterName
        self.reorderAxis = reorderAxis
        self.sections = sections
        
        addGesture(tableView: uiView)
    }
    
    private func addGesture(tableView: UIView) {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(dragCellView(gestureRecognizer:)))
        longPressGesture.delegate = viewController as? UIGestureRecognizerDelegate
        
        self.uiView.addGestureRecognizer(longPressGesture)
    }
    
    @objc func dragCellView(gestureRecognizer: UILongPressGestureRecognizer) {
        let longGesture = gestureRecognizer
        let pressState = gestureRecognizer.state
        let locationInView = longGesture.location(in: uiView)
        
        guard let indexPath = returnIndexPathFor(point: locationInView) else {
            print("DragReorderInteractionController - Index path could not be retrieved.")
            
            return
        }
        
        guard sections.contains(indexPath.section) else {
            print("DragReorderInteractionController - Cell is not in an approved section to be moved.")
            
            return
        }
        
        switch pressState {
            case .began:
                guard let pressedCell = returnCellFor(indexPath: indexPath) else { return }
                
                if let snapShot = pressedCell.snapshotView(afterScreenUpdates: true) {
                    self.snapShot = snapShot
                    interactionInProgress = true
                    
                    var centerPoint = pressedCell.center
                    startingIndex = indexPath
                    
                    snapShot.center = centerPoint
                    snapShot.alpha = 0
                    
                    uiView.addSubview(snapShot)
                    
                    UIView.animate(withDuration: 0.25, animations: {() -> Void in
                        switch self.reorderAxis! {
                        case .x:
                            centerPoint.x = locationInView.x
                        case .y:
                            centerPoint.y = locationInView.y
                        }
                        
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
                
                switch reorderAxis! {
                case .x:
                    updatedCenter.x = locationInView.x
                case .y:
                    updatedCenter.y = locationInView.y
                }
                
                snapShot!.center = updatedCenter
            
                if startingIndex != nil && indexPath != startingIndex {
                    // Prevent Cell From Entering Restricted Section
                    guard sections.contains(indexPath.section) else {
                        print("DragReorderInteractionController - Cell is out of range.")
                        
                        return
                    }
                    
                    let itemIndicies: [AnyHashable: Int] = [
                        AnyHashable.init(ReorderArray.fromIndex) : startingIndex!.row,
                        AnyHashable.init(ReorderArray.toIndex) : indexPath.row
                    ]
                    
                    NotificationCenter.default.post(name: notificationCenterName, object: nil, userInfo: itemIndicies)
                    
                    moveCell(atIndexPath: startingIndex!, toIndexPath: indexPath)
                    
                    startingIndex = indexPath
                }
            
            default:
                guard startingIndex != nil,
                    snapShot != nil,
                    let animateCell = returnCellFor(indexPath: startingIndex!) else {
                    print("DragReorderInteractionController - Cell could not be found at index path.")
                    
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
                    self.interactionInProgress = false
                })
                return
        }
    }
}

//MARK: - Return Index For Point
extension DragReorderInteractionController {
    private func returnIndexPathFor(point: CGPoint) -> IndexPath? {
        if uiView.isMember(of: UITableView.self) {
            let tableView = uiView as! UITableView
            let newIndex = tableView.indexPathForRow(at: point)
        
            return newIndex != nil ? newIndex : startingIndex
        } else if uiView.isMember(of: UICollectionView.self) {
            let collectionView = uiView as! UICollectionView
            let newIndex = collectionView.indexPathForItem(at: point)
        
            return newIndex != nil ? newIndex : startingIndex
        } else {
            print("DragReorderInteractionController - The view is not a member of UITableView or UICollectionView.")
        
            return nil
        }
    }
}

//MARK: - Return Cell for Index Path
extension DragReorderInteractionController {
    func returnCellFor(indexPath: IndexPath) -> UIView? {
        if uiView.isMember(of: UITableView.self) {
            let tableView = uiView as! UITableView
            
            return tableView.cellForRow(at: indexPath)
        } else if uiView.isMember(of: UICollectionView.self) {
            let collectionView = uiView as! UICollectionView
            
            return collectionView.cellForItem(at: indexPath)
        } else {
            print("DragReorderInteractionController - Cell could not be returned for index path.")
            
            return nil
        }
    }
}

//MARK: - Move Cells
extension DragReorderInteractionController {
    func moveCell(atIndexPath: IndexPath, toIndexPath: IndexPath) {
        if uiView.isMember(of: UITableView.self) {
            let tableView = uiView as! UITableView
            
            tableView.moveRow(at: atIndexPath, to: toIndexPath)
        } else if uiView.isMember(of: UICollectionView.self) {
            let collectionView = uiView as! UICollectionView
            
            collectionView.moveItem(at: atIndexPath, to: toIndexPath)
        } else {
            print("DragReorderInteractionController - UIView is not a UITableView or UICollectionView. \n Cannot move cell.")
        }
    }
}
