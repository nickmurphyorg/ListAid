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
    var listViewControllers = [ListViewController]()
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
    private let accentColor = UIColor(red: 0.0, green: 0.478, blue: 1.0, alpha: 1.0)
    private let reorderListsNotificationName = NSNotification.Name.init("reorderLists")
    private let listsSectionInsets = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 30)
    private let newListSectionInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 30)
    private let listStyleMetrics = ListStyleMetric()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lists = ModelController.shared.returnAllLists()
        listViewControllers = lists.map{
            let list = ListViewController(list: $0, mode: .Cell)
            list.setDeleteListDelegate(deleteListDelegate: self)
            
            return list
        }
        listWidth = mainView.frame.width * listStyleMetrics.scaleFactor
        listHeight = mainView.frame.height * listStyleMetrics.scaleFactor
        
        listCollectionView.register(ListCollectionViewCell.self, forCellWithReuseIdentifier: listCellIdentifier)
        listCollectionView.register(NewListCollectionViewCell.self, forCellWithReuseIdentifier: newListCellIdentifier)
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
        
        cell.setViewControllerView(listViewControllers[indexPath.item].view)
        
        return cell
    }
    
    private func setListModeForList(_ index: Int) {
        if editListsMode {
            // Editing Lists
            listViewControllers[index].setListMode(.Edit)
        } else if addListMode && index + 1 == lists.count {
            // Adding New List
            listViewControllers[index].setListMode(.New)
        } else {
            // Finished Editing Lists
            listViewControllers[index].setListMode(.Cell)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        setListModeForList(indexPath.item)
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
        
        let destinationViewController = ListViewController(list: lists[selectedListIndex], mode: .Presented)
        destinationViewController.editListDelegate = self
        destinationViewController.transitioningDelegate = self
        destinationViewController.modalPresentationStyle = .overCurrentContext
        
        self.navigationController?.present(destinationViewController, animated: true, completion: nil)
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
            setListModeForList(indexPath.item)
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
            
            weakSelf.listViewControllers.remove(at: index)
            weakSelf.listCollectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
        })
        
        present(deleteAlert, animated: true, completion: nil)
    }
}

//MARK: - Edit List Delegate
extension ListsViewController: EditListDelegate {
    func editList(listItems: [Item]) {
//        lists[selectedListIndex].items = listItems
        
//        guard let cellToReload = listCollectionView.cellForItem(at: IndexPath(item: selectedListIndex, section: 0)) as? ListCollectionViewCell else { return }
        
//        cellToReload.reloadTable()
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
        listViewControllers.append(ListViewController(list: lists[lists.count - 1], mode: .New))
        
        let newIndex = IndexPath(item: lists.count - 1, section: 0)
        
        listCollectionView.insertItems(at: [newIndex])
        
//        addedList.listNameField.layer.shadowOpacity = 1.0
//        addedList.deleteListButton.isHidden = false
    }
}

//MARK: - Navigation Transition Delegate
extension ListsViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let selectedListIndexPath = IndexPath(item: selectedListIndex, section: 0)
        
        guard let _ = presented as? ListViewController,
            let selectedCell = listCollectionView.cellForItem(at: selectedListIndexPath) as? ListCollectionViewCell
            else {
                return nil
        }
        
        let cellFrame = selectedCell.frame
        let selectedCellFrame = listCollectionView.convert(cellFrame, to: listCollectionView.superview)
        
        return ListZoomInAnimationController(listCellViewController: listViewControllers[selectedListIndex], listCellFrame: selectedCellFrame)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let selectedListIndexPath = IndexPath(item: selectedListIndex, section: 0)
        
        guard let originVC = dismissed as? ListViewController,
            let selectedCell = listCollectionView.cellForItem(at: selectedListIndexPath) as? ListCollectionViewCell
            else {
                return nil
        }
        
        let cellFrame = selectedCell.frame
        let selectedCellFrame = listCollectionView.convert(cellFrame, to: listCollectionView.superview)
        
        return ListZoomOutAnimationController(listCellViewController: listViewControllers[selectedListIndex], listCellFrame: selectedCellFrame, intereactionController: originVC.zoomInteractionController)
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
