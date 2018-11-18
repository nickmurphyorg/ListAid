//
//  ViewController.swift
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
    
    private let listSegueIdentigier = "PresentListView"
    private let listCellIdentifier = "ListCell"
    private let newListCellIdentifier = "NewListCell"
    private let itemCellIdentifier = "ListItemCellSmall"
    private let statusBarHeight = UIApplication.shared.statusBarFrame.height
    let accentColor = UIColor(red: 0.0, green: 0.478, blue: 1.0, alpha: 1.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lists = ModelController.shared.returnAllLists()
        
        listWidth = mainView.frame.width * 0.8
        listHeight = (mainView.frame.height * 0.8) - statusBarHeight
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
        
        cell.setIndex(index: indexPath.item)
        cell.listNameField.text = list.name
        cell.setNameFieldDelegate(textFieldDelegate: self)
        cell.setDeleteListDelegate(deleteListDelegate: self)
        cell.setTableViewDataSourceDelegate(dataSourceDelegate: self)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? ListCollectionViewCell else { return }
        
        cell.setIndex(index: indexPath.item)
        
        if editListsMode {
            cell.listNameField.layer.shadowOpacity = 1.0
            cell.deleteListButton.isHidden = false
        } else if addListMode && indexPath.item + 1 == lists.count {
            cell.listNameField.layer.shadowOpacity = 1.0
            cell.deleteListButton.isHidden = false
        } else {
            cell.listNameField.layer.shadowOpacity = 0.0
            cell.deleteListButton.isHidden = true
        }
        
        cell.reloadTable()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Disable while adding a new list
        guard !addListMode else { return }
        
        // Check if it's new list card
        guard indexPath.section == 0 else {
            addNewList()
            
            return
        }
        
        selectedListIndex = indexPath.item
        
        UserPreferences.shared.saveSelectedList(index: selectedListIndex)
        
        performSegue(withIdentifier: listSegueIdentigier, sender: nil)
    }
}

//MARK: - Collection View Layout
extension ListsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: listWidth, height: listHeight)
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
                cell.listNameField.layer.shadowOpacity = 1.0
                cell.deleteListButton.isHidden = false
            } else if addListMode && indexPath.item + 1 == lists.count {
                cell.listNameField.layer.shadowOpacity = 1.0
                cell.deleteListButton.isHidden = false
            } else {
                cell.listNameField.layer.shadowOpacity = 0.0
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
        guard textField.hasText else {
            let savedName = ModelController.shared.returnSavedListName(listIndex: textField.tag)
            
            if let savedName = savedName {
                textField.text = savedName
            }
            
            return
        }
        
        guard lists.indices.contains(textField.tag) else { return }
        
        addListMode = false
        
        lists[textField.tag].name = textField.text!
        
        listCollectionView.reloadItems(at: [IndexPath(item: lists.count - 1, section: 0)])
        
        ModelController.shared.updateListName(listIndex: textField.tag, newName: textField.text!)
    }
    
}

//MARK: - Delete List Delegate
extension ListsViewController: DeleteListDelegate {
    func deleteList(index: Int) {
        let deleteAlert = Alert.newAlert(title: "Are you sure?", message: "You will not be able to recover the list.", hasCancel: true, buttonLabel: "Delete", buttonStyle: .destructive, completion: { [weak self] action in
            self?.addListMode = false
            
            self?.lists = ModelController.shared.deleteList(listIndex: index)
            
            let itemIndex = IndexPath(item: index, section: 0)
            
            self?.listCollectionView.deleteItems(at: [itemIndex])
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
        let cell = tableView.dequeueReusableCell(withIdentifier: itemCellIdentifier, for: indexPath)
        
        let item = lists[tableView.tag].items[indexPath.row]
        
        cell.textLabel?.text = item.name
        
        if item.completed == true {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
}

//MARK: - Edit List Delegate
extension ListsViewController: EditListDelegate {
    func editList(list: List) {
        lists[selectedListIndex] = list
        
        listCollectionView.reloadItems(at: [IndexPath(item: lists.count - 1, section: 0)])
    }
}

//MARK: - Helper Methods
extension ListsViewController {
    func addNewList() {
        addListMode = true
        
        let newList = List(name: "", items: [])
        
        lists = ModelController.shared.addNewList(newList: newList)
        
        let newIndex = IndexPath(item: lists.count - 1, section: 0)
        
        listCollectionView.insertItems(at: [newIndex])
        
        let addedList = listCollectionView.cellForItem(at: newIndex) as! ListCollectionViewCell
        addedList.listNameField.becomeFirstResponder()
        addedList.listNameField.layer.shadowOpacity = 1.0
        addedList.deleteListButton.isHidden = false
    }
}

//MARK: - Navigation
extension ListsViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case listSegueIdentigier:
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
        let selectedCellAttributes = listCollectionView.layoutAttributesForItem(at: selectedListIndexPath)
        
        guard let cellFrame = selectedCellAttributes?.frame else { return nil }
        
        let selectedCellFrame = listCollectionView.convert(cellFrame, to: listCollectionView.superview)
        
        return ListZoomInAnimationController(listCellFrame: selectedCellFrame)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let originVC = dismissed as? ListViewController else {
            return nil
        }
        
        let selectedListIndexPath = IndexPath(item: selectedListIndex, section: 0)
        let selectedCellAttributes = listCollectionView.layoutAttributesForItem(at: selectedListIndexPath)
        
        guard let cellFrame = selectedCellAttributes?.frame else {
            return nil
        }
        
        let selectedCellFrame = listCollectionView.convert(cellFrame, to: listCollectionView.superview)
        
        return ListZoomOutAnimationController(listCellFrame: selectedCellFrame, intereactionController: originVC.zoomInteractionController)
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
