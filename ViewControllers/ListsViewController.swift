//
//  ListsViewController.swift
//  Listaid
//
//  Created by Nick Murphy on 9/30/18.
//  Copyright © 2018 Nick Murphy. All rights reserved.
//

import UIKit

class ListsViewController: UIViewController {
    
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var listsView: UIView!
    @IBOutlet weak var listCollectionView: UICollectionView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    var lists = [List]()
    var selectedListIndex = Int()
    var listWidth: CGFloat = 0
    var listHeight: CGFloat = 0
    var editListsMode = false
    var addListMode = false
    
    var dragReorderInteractionController: DragReorderInteractionController?
    
    private let listSegueIdentifier = "PresentListView"
    private let listCellIdentifier = "ListCell"
    private let newListCellIdentifier = "NewListCell"
    private let itemCellIdentifier = "ItemCell"
    private let statusBarHeight = UIApplication.shared.statusBarFrame.height
    private let accentColor = UIColor(red: 0.0, green: 0.478, blue: 1.0, alpha: 1.0)
    private let reorderListsNotificationName = NSNotification.Name.init("reorderLists")
    private let listsSectionInsets = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 30)
    private let newListSectionInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 30)
    private let listStyleMetrics = ListStyleMetric()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lists = ModelController.shared.returnAllLists()
        
        listWidth = mainView.frame.width * listStyleMetrics.scaleFactor
        listHeight = (mainView.frame.height * listStyleMetrics.scaleFactor) - statusBarHeight
        
        NotificationCenter.default.addObserver(self, selector: #selector(reorderLists(notification:)), name: reorderListsNotificationName, object: nil)
        
        dragReorderInteractionController = DragReorderInteractionController.init(viewController: self, uiView: listCollectionView, notificationCenterName: reorderListsNotificationName, reorderAxis: ReorderAxis.x, sections: [0])
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }

}

//MARK: - Collection View Delegate and Data Source
extension ListsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? lists.count : 1 ;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard indexPath.section == 0 else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: newListCellIdentifier, for: indexPath) as? NewListCollectionViewCell else {
                fatalError("The new list cell could not be created.")
            }
            
            return cell
        }
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: listCellIdentifier, for: indexPath) as? ListCollectionViewCell else {
            fatalError("The list cell could not be created.")
        }
        
        let list = lists[indexPath.item]
        
        cell.listNameField.text = list.name
        cell.setTableViewIndex(indexPath.item)
        cell.setNameFieldDelegate(textFieldDelegate: self)
        cell.setDeleteListDelegate(deleteListDelegate: self)
        cell.setTableViewDataSourceDelegate(dataSourceDelegate: self)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? ListCollectionViewCell else { return }
        
        if editListsMode {
            // Editing Lists
            cell.textFieldUnderline.isHidden = false
            cell.deleteListButton.isHidden = false
        } else if addListMode && indexPath.item + 1 == lists.count {
            // Adding New List
            cell.textFieldUnderline.isHidden = false
            cell.deleteListButton.isHidden = false
        } else {
            // Finished Editing Lists
            cell.textFieldUnderline.isHidden = true
            cell.deleteListButton.isHidden = true
        }
        
        cell.setTableViewIndex(indexPath.item)
        cell.reloadTable()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Disable while adding a new list
        guard !addListMode && !editListsMode else { return }
        
        // Check if it's new list card
        guard indexPath.section == 0 else {
            addNewList()
            
            return
        }
        
        selectedListIndex = indexPath.item
        
        UserPreferences.shared.saveSelectedList(index: selectedListIndex)
        
        performSegue(withIdentifier: listSegueIdentifier, sender: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 0 ? true : false
    }
}

//MARK: - Collection View Layout
extension ListsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: listWidth, height: listHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return section == 0 ? listsSectionInsets : newListSectionInsets
    }
}

//MARK: - Toggle Cell Edit Mode
extension ListsViewController {
    @IBAction func editListsButton(_ sender: Any) {
        if editListsMode {
            editListsMode = false
            editButton.title = "Edit"
            editButton.style = .plain
            editButton.tintColor = UIColor.white
        } else {
            editListsMode = true
            editButton.title = "Done"
            editButton.style = .done
            editButton.tintColor = accentColor
        }
        
        let visibleCellIndexPaths = listCollectionView.indexPathsForVisibleItems
        
        for indexPath in visibleCellIndexPaths {
            guard let cell = listCollectionView.cellForItem(at: indexPath) as? ListCollectionViewCell else {
                return
            }
            
            if editListsMode {
                // Editing Lists
                cell.textFieldUnderline.isHidden = false
                cell.deleteListButton.isHidden = false
            } else if addListMode && indexPath.item + 1 == lists.count {
                // Adding List
                cell.textFieldUnderline.isHidden = false
                cell.deleteListButton.isHidden = false
            } else {
                // Finished Editing Lists
                cell.textFieldUnderline.isHidden = true
                cell.deleteListButton.isHidden = true
            }
        }
    }
}

//MARK: - Cell Text Field Delegate
extension ListsViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return editListsMode || addListMode ? true : false ;
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let listIndex = listCollectionView.indexOf(textField) else {
            print("ListsViewController - Could not return index for text field.")
            
            return
        }
        
        guard textField.hasText else {
            let savedName = ModelController.shared.returnSavedListName(listId: lists[listIndex].id)
            
            if let savedName = savedName {
                textField.text = savedName
            }
            
            return
        }
        
        guard lists.indices.contains(listIndex) else { return }
        
        addListMode = false
        
        lists[listIndex].name = textField.text!
        
        //TODO - Refactor this method to be more specific.
        listCollectionView.reloadItems(at: [IndexPath(item: listIndex, section: 0)])
        
        ModelController.shared.updateListName(listId: lists[listIndex].id, newName: textField.text!)
    }
    
}

//MARK: - Delete List Delegate
extension ListsViewController: DeleteListDelegate {
    func deleteListContaining(_ button: UIButton) {
        guard let index = listCollectionView.indexOf(button) else {
            print("ListsViewController - Could not return index for delete button.")
            
            return
        }
        
        let deleteAlert = Alert.newAlert(title: "Are you sure?", message: "You will not be able to recover the list.", hasCancel: true, buttonLabel: "Delete", buttonStyle: .destructive, completion: { [weak self] action in
            guard let weakSelf = self else { return }
            
            weakSelf.addListMode = false
            
            weakSelf.lists = ModelController.shared.deleteList(listId: weakSelf.lists[index].id)
            
            let itemIndex = IndexPath(item: index, section: 0)
            
            weakSelf.listCollectionView.deleteItems(at: [itemIndex])
        })
        
        present(deleteAlert, animated: true, completion: nil)
    }
}

//MARK: - Cell Table View Delegate and Datasource
extension ListsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lists[tableView.tag].items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: itemCellIdentifier, for: indexPath) as? ItemTableViewCell else {
            fatalError("ListsViewController - Could not initalize an Item Small Tableview Cell.")
        }

        let item = lists[tableView.tag].items[indexPath.row]
        
        cell.itemNameLabel.text = item.name
        
        let completeStrikeWidth = cell.itemNameLabel.intrinsicContentSize.width + 28
        
        if item.completed {
            cell.strikeThroughWidthConstraint.constant = completeStrikeWidth
        } else {
            cell.strikeThroughWidthConstraint.constant = listStyleMetrics.strikeWidth
        }
        
        return cell
    }
}

//MARK: - Edit List Delegate
extension ListsViewController: EditListDelegate {
    func editList(listItems: [Item]) {
        lists[selectedListIndex].items = listItems
        
        guard let cellToReload = listCollectionView.cellForItem(at: IndexPath(item: selectedListIndex, section: 0)) as? ListCollectionViewCell else { return }
        
        cellToReload.reloadTable()
    }
}

//MARK: - Reorder Lists
extension ListsViewController {
    @objc func reorderLists(notification: NSNotification) {
        guard let fromIndex = notification.userInfo?[ReorderArray.fromIndex] as? Int,
            let toIndex = notification.userInfo?[ReorderArray.toIndex] as? Int else {
                print("Could not capture indicies from notfication response.")
                
                return
        }
        
        lists = ModelController.shared.reorder(lists: lists, fromIndex, toIndex)
    }
}

//MARK: - Helper Methods
extension ListsViewController {
    func addNewList() {
        addListMode = true
        
        lists = ModelController.shared.addNewList()
        
        let newIndex = IndexPath(item: lists.count - 1, section: 0)
        
        listCollectionView.insertItems(at: [newIndex])
        
        let addedList = listCollectionView.cellForItem(at: newIndex) as! ListCollectionViewCell
        addedList.setTableViewIndex(newIndex.item)
        addedList.reloadTable()
        addedList.listNameField.becomeFirstResponder()
        addedList.listNameField.layer.shadowOpacity = 1.0
        addedList.deleteListButton.isHidden = false
    }
}

//MARK: - Navigation
extension ListsViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case listSegueIdentifier:
            let destinationViewController = segue.destination as! ListViewController
                destinationViewController.selectedList = lists[selectedListIndex]
                destinationViewController.editListDelegate = self
                destinationViewController.transitioningDelegate = self
            
        default:
            return
        }
    }
    
}

//MARK: - Navigation Transition Delegate
extension ListsViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let selectedListIndexPath = IndexPath(item: selectedListIndex, section: 0)
        
        guard let destinationVC = presented as? ListViewController,
            let addItemsButton = destinationVC.addItemsButton,
            let selectedCell = listCollectionView.cellForItem(at: selectedListIndexPath) as? ListCollectionViewCell,
            let listNameLabel = selectedCell.listNameField
            else {
                return nil
        }
        
        let cellFrame = selectedCell.frame
        let selectedCellFrame = listCollectionView.convert(cellFrame, to: listCollectionView.superview)
        
        return ListZoomInAnimationController(listCellFrame: selectedCellFrame, listNameLabel: listNameLabel, addItemsButton: addItemsButton)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let selectedListIndexPath = IndexPath(item: selectedListIndex, section: 0)
        
        guard let originVC = dismissed as? ListViewController,
            let addItemsButton = originVC.addItemsButton,
            let selectedCell = listCollectionView.cellForItem(at: selectedListIndexPath) as? ListCollectionViewCell,
            let listNameLabel = selectedCell.listNameField
            else {
                return nil
        }
        
        let cellFrame = selectedCell.frame
        let selectedCellFrame = listCollectionView.convert(cellFrame, to: listCollectionView.superview)
        
        return ListZoomOutAnimationController(listCellFrame: selectedCellFrame, listNameLabel: listNameLabel, addItemsButton: addItemsButton, intereactionController: originVC.zoomInteractionController)
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        guard let animator = animator as? ListZoomOutAnimationController,
            let interactionController = animator.zoomInteractionController,
            interactionController.interactionInProgress
            else {
                return nil
        }
        
        return interactionController
    }
}
