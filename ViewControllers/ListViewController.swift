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
    @IBOutlet weak var itemsTableView: UITableView!
    
    var editListDelegate: EditListDelegate?
    var zoomInteractionController: ZoomInteractionController?
    
    var selectedList: Int = 0
    var selectedListItems: [Item] = []
    
    private let cellIdentifier = "ItemCell"
    private let addItemsSegue = "PresentAddItems"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let returnedListName = ModelController.shared.returnSavedListName(listIndex: selectedList)
        let returnedListItems = ModelController.shared.returnFilteredItemsInList(atIndex: selectedList)
        
        if returnedListName != nil && returnedListItems != nil {
            listNameLabel.text = returnedListName!
            selectedListItems = returnedListItems!
        } else {
            let listErrorAlert = Alert.newAlert(title: "Error", message: "There was a problem finding your list.", hasCancel: false, buttonLabel: "Close", buttonStyle: .default, completion: nil)
            
            present(listErrorAlert, animated: true)
        }
        
        itemsTableView.bounces = false
        
        zoomInteractionController = ZoomInteractionController(viewController: self, tableView: itemsTableView)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        let itemData = selectedListItems[indexPath.row]
        
        cell.textLabel?.text = itemData.name
        
        if itemData.completed == true {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedListItems[indexPath.row].completed.toggle()
        
        ModelController.shared.toggleItemCompletionStatus(listIndex: selectedList, itemIndex: indexPath.row)
        
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let removeAction = UITableViewRowAction(style: .normal, title: "Remove", handler: { [weak self] (action:UITableViewRowAction, indexPath: IndexPath) -> Void in
            guard let listIndex = self?.selectedList else { return }
            
            self?.selectedListItems.remove(at: indexPath.row)
            
            ModelController.shared.toggleItemListStatus(listIndex: listIndex, itemIndex: indexPath.row)
            
            tableView.reloadData()
        })
        
        removeAction.backgroundColor = UIColor.orange
        
        return [removeAction]
    }
}

// MARK: - Gesture Delegate
extension ListViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

//MARK: - Edit List Delegate
extension ListViewController: EditListItemsDelegate {
    func editItems(items: [Item]) {
        selectedListItems = items
        
        itemsTableView.reloadData()
    }
}

//MARK: - Navigation
extension ListViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case addItemsSegue:
            let destinationNavigationController = segue.destination as! UINavigationController
            let destinationViewController = destinationNavigationController.viewControllers.first as! AddItemsViewController
                destinationViewController.editListItemsDelegate = self

        default:
            return
        }
    }
}
