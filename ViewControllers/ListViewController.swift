//
//  ListViewController.swift
//  Listaid
//
//  Created by Nick Murphy on 10/7/18.
//  Copyright © 2018 Nick Murphy. All rights reserved.
//

import UIKit

class ListViewController: UIViewController {
    
    @IBOutlet weak var listNameLabel: UILabel!
    @IBOutlet weak var addItemsButton: UIButton!
    @IBOutlet weak var listBackground: UIView!
    @IBOutlet weak var itemsTableView: UITableView!
    
    var editListDelegate: EditListDelegate?
    var zoomInteractionController: ZoomInteractionController?
    var dragReorderInteractionController: DragReorderInteractionController?
    
    var selectedListIndex = Int()
    var selectedListItems = [Item]()
    
    private let cellIdentifier = "ItemCell"
    private let addItemsSegue = "PresentAddItems"
    private let reorderItemsNotificationName = NSNotification.Name("reorderItems")
    private let listStyleMetrics = ListStyleMetric()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        selectedListItems = ModelController.shared.returnFilteredItemsInList(atIndex: selectedListIndex)
        listNameLabel.text = ModelController.shared.returnSavedListName(listIndex: selectedListIndex) ?? ""
        
        listBackground.layer.cornerRadius = listStyleMetrics.cornerRadius
        itemsTableView.bounces = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(moveItem(notification:)), name: reorderItemsNotificationName, object: nil)
        
        zoomInteractionController = ZoomInteractionController(viewController: self, tableView: itemsTableView)
        dragReorderInteractionController = DragReorderInteractionController(uiView: itemsTableView, notificationCenterName: reorderItemsNotificationName, reorderAxis: ReorderAxis.y, sections: [0])
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // Verify User Is Closing List
        guard zoomInteractionController?.interactionInProgress ?? false else { return }
        
        editListDelegate?.editList(listItems: selectedListItems)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
}

//MARK: - Tableview Datasource and Delegate
extension ListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedListItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ItemTableViewCell else {
            fatalError("Could not initalize a new Item Table View Cell.")
        }
        
        let itemData = selectedListItems[indexPath.row]
        
        cell.itemNameLabel.text = itemData.name
        
        let completeStrikeWidth = cell.itemNameLabel.intrinsicContentSize.width + 28
        
        if itemData.completed {
            cell.strikeThroughWidthConstraint.constant = completeStrikeWidth
        }
        
        cell.strikeCompleteDelegate = self
        cell.strikeInteractionController = StrikeInteractionController.init(tableCell: cell, strikeStandardWidth: listStyleMetrics.strikeWidth, strikeCompleteWidth: completeStrikeWidth)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        var cellOptions: [UITableViewRowAction] = []
        
        let removeAction = UITableViewRowAction(style: .normal, title: "Remove", handler: { [weak self] (action:UITableViewRowAction, indexPath: IndexPath) -> Void in
            guard let listIndex = self?.selectedListIndex else { return }
            guard let weakSelf = self else { return }
            
            ModelController.shared.toggleItemListStatus(listIndex: listIndex, itemID: weakSelf.selectedListItems[indexPath.row].id)
            
            weakSelf.selectedListItems.remove(at: indexPath.row)
            
            tableView.reloadData()
        })
        
        removeAction.backgroundColor = UIColor.orange
        cellOptions.append(removeAction)
        
        let relistAction = UITableViewRowAction(style: .normal, title: "Relist", handler: { [weak self] (action: UITableViewRowAction, indexPath: IndexPath) -> Void in
            guard let weakSelf = self else { return }
            guard let editingCell = tableView.cellForRow(at: indexPath) as? ItemTableViewCell else { return }
            
            let listIndex = weakSelf.selectedListIndex
            
            UIView.animate(withDuration: 1) {
                editingCell.strikeThrough.frame.size.width = weakSelf.listStyleMetrics.strikeWidth
            }
            
            weakSelf.selectedListItems[indexPath.row].completed.toggle()
            
            ModelController.shared.toggleItemCompletionStatus(listIndex: listIndex, itemID: weakSelf.selectedListItems[indexPath.row].id)
        })
        
        if selectedListItems[indexPath.row].completed {
            cellOptions.append(relistAction)
        }
        
        return cellOptions
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}

// MARK: - Gesture Delegate
extension ListViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // Prevent pull down to close when reordering items.
        if dragReorderInteractionController?.interactionInProgress ?? false {
            return false
        }
        
        return true
    }
}

// MARK: - Strike Complete Delegate
extension ListViewController: StrikeCompleteDelegate {
    func completeItem(tableViewCell: UITableViewCell) {
        guard let cellPath = itemsTableView.indexPath(for: tableViewCell) else { return }
        
        selectedListItems[cellPath.row].completed.toggle()
        
        ModelController.shared.toggleItemCompletionStatus(listIndex: selectedListIndex, itemID: selectedListItems[cellPath.row].id)
        
        itemsTableView.reloadRows(at: [cellPath], with: .automatic)
    }
}

//MARK: - Edit List Delegate
extension ListViewController: EditListItemsDelegate {
    func editItems(items: [Item]) {
        selectedListItems = items
        
        itemsTableView.reloadData()
    }
}

//MARK: - Reorder List Items
extension ListViewController {
    @objc func moveItem(notification: NSNotification) {
        guard let fromIndex = notification.userInfo?[ReorderArray.fromIndex] as? Int,
            let toIndex = notification.userInfo?[ReorderArray.toIndex] as? Int else {
                print("Could not capture indicies for item to move.")
                
                return
        }
        
        selectedListItems = ModelController.shared.reorderItemIn(list: selectedListIndex, fromIndex, toIndex)
    }
}

//MARK: - Shake To Purge
extension ListViewController {
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            let purgedList = ModelController.shared.purgeCompletedItems(listIndex: selectedListIndex)
            
            if let purgedList = purgedList {
                selectedListItems = purgedList.items
                
                itemsTableView.reloadSections(IndexSet.init(integer: 0), with: .automatic)
            }
        }
    }
}

//MARK: - Navigation
extension ListViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case addItemsSegue:
            let destinationNavigationController = segue.destination as! UINavigationController
            let destinationViewController = destinationNavigationController.viewControllers.first as! AddItemsViewController
            destinationViewController.selectedListIndex = selectedListIndex
            destinationViewController.editListItemsDelegate = self

        default:
            return
        }
    }
}
