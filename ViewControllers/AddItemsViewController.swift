//
//  AddItemsViewController.swift
//  Listaid
//
//  Created by Nick Murphy on 10/14/18.
//  Copyright © 2018 Nick Murphy. All rights reserved.
//

import UIKit
import CoreData

class AddItemsViewController: UIViewController {

    @IBOutlet weak var navigationView: UIVisualEffectView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var itemsTableView: UITableView!
    
    var editListItemsDelegate: EditListItemsDelegate?
    var selectedListId: NSManagedObjectID!
    
    private var selectedListItems = [Item]()
    private var searchResultItems = [Item]()
    private var editingItemAtIndex: Int?
    
    private let addItemsTitle = "Add Items"
    private let editItemTitle = "Edit Item"
    private let cellIdentifier = "ItemCell"
    private let listStyleMetrics = ListStyleMetric()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        selectedListItems = ModelController.shared.returnAllItemsInList(selectedListId)
        
        itemsTableView.contentInset.top = navigationView.bounds.height
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        backgroundView.roundedCorners(corners: [.topLeft, .topRight], radius: listStyleMetrics.cornerRadius)
        
        navigationView.layer.shadowColor = UIColor.black.cgColor
        navigationView.layer.shadowOpacity = 0.3
        navigationView.layer.shadowRadius = 0
        navigationView.layer.shadowOffset = CGSize(width: 0, height: 0.5)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
}

//MARK: - Search Bar
extension AddItemsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        matchingSearchResults(searchText: searchText)
        
        itemsTableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        var updatedList: [Item]?
        
        guard searchBar.text! != "" else {
            searchBar.resignFirstResponder()
            
            editingItemAtIndex = nil
            
            return
        }
        
        if searchResultItems.count == 0 && editingItemAtIndex == nil {
            updatedList = ModelController.shared.addItemToList(listId: selectedListId, itemName: searchBar.text!)
            
        } else if searchResultItems.count > 0 && editingItemAtIndex == nil {
            var addNewItem = true
            
            for item in searchResultItems {
                if searchBar.text!.lowercased() == item.name.lowercased() {
                    addNewItem = false
                }
            }
            
            if addNewItem {
                updatedList = ModelController.shared.addItemToList(listId: selectedListId, itemName: searchBar.text!)
            }
            
        } else if searchResultItems.count == 0 && editingItemAtIndex != nil {
            updatedList = ModelController.shared.renameItem(editingItemAtIndex!, in: selectedListItems, to: searchBar.text!)
            
            editingItemAtIndex = nil
            
        } else if searchResultItems.count > 0 && editingItemAtIndex != nil {
            var updateItemName = true
            
            for item in searchResultItems {
                if searchBar.text!.lowercased() == item.name.lowercased() && selectedListItems[editingItemAtIndex!].id != item.id {
                    // Item is renamed to an existing item
                    updatedList = ModelController.shared.deleteItem(editingItemAtIndex!, in: updatedList!)
                    
                    updateItemName = false
                } else if searchBar.text!.lowercased() == item.name.lowercased() && selectedListItems[editingItemAtIndex!].id == item.id {
                    // Item name was not changed
                    updateItemName = false
                }
            }
            
            if updateItemName {
                updatedList = ModelController.shared.renameItem(editingItemAtIndex!, in: updatedList!, to: searchBar.text!)
            }
            
            editingItemAtIndex = nil
        }
        
        navigationBar.topItem?.title = addItemsTitle
        searchBar.text = ""
        searchBar.resignFirstResponder()
        
        if let updatedList = updatedList {
            selectedListItems = updatedList
        }
        
        itemsTableView.reloadData()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        navigationBar.topItem?.title = addItemsTitle
        searchBar.text = ""
        editingItemAtIndex = nil
        itemsTableView.reloadData()
    }
    
    func emptySearchBar() -> Bool {
        return searchBar.text?.isEmpty ?? true
    }
    
    func matchingSearchResults(searchText: String) {
        searchResultItems = selectedListItems.filter { $0.name.lowercased().contains(searchText.lowercased()) }
    }
    
    func activeSearch() -> Bool {
        return searchBar.isFirstResponder && !emptySearchBar()
    }
    
}

//MARK: - Tableview Delegate and Datasource
extension AddItemsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if activeSearch() {
            return searchResultItems.count
        }
        
        return selectedListItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? AddItemTableViewCell else {
            fatalError("Could not init a new cell.")
        }
        
        let itemData: Item
        
        if activeSearch() {
            itemData = searchResultItems[indexPath.row]
        } else {
            itemData = selectedListItems[indexPath.row]
        }
        
        cell.itemNameLabel.text = itemData.name
        cell.toggleItemButton.isSelected = itemData.listed
        cell.toggleItemDelegate = self
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return editingItemAtIndex == nil
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { [weak self] (action:UITableViewRowAction, indexPath: IndexPath) in
            guard let weakSelf = self else { return }
            
            weakSelf.selectedListItems = ModelController.shared.deleteItem(indexPath.row, in: weakSelf.selectedListItems)
            
            tableView.reloadData()
        }
        
        let editAction = UITableViewRowAction(style: .normal, title: "Edit") { [weak self] (action: UITableViewRowAction, indexPath: IndexPath) in
            guard let weakSelf = self else { return }
            
            let itemName = weakSelf.selectedListItems[indexPath.row].name
            
            weakSelf.editingItemAtIndex = indexPath.row
            weakSelf.navigationBar.topItem?.title = weakSelf.editItemTitle
            weakSelf.searchBar.text = itemName
            weakSelf.searchBar.becomeFirstResponder()
            
            weakSelf.matchingSearchResults(searchText: itemName)
            
            tableView.reloadData()
        }
        
        return [deleteAction, editAction]
    }
}

//MARK: - Toggle Item Delegate
extension AddItemsViewController: ToggleListedItem {
    func toggleItem(tableCell: AddItemTableViewCell) {
        if let indexPath = itemsTableView.indexPath(for: tableCell) {
            let index = indexPath.row
            
            if activeSearch() {
                // Find item in master list before changing the listed status.
                toggleItemInMasterList(updateItem: searchResultItems[index])
                
                searchResultItems[index].listed.toggle()
            } else {
                selectedListItems[index].listed.toggle()
                
                ModelController.shared.toggleListStatus(itemID: selectedListItems[index].id)
            }
            
            itemsTableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
}

//MARK: - Helper Methods
extension AddItemsViewController {
    func toggleItemInMasterList(updateItem: Item) {
        for (index, item) in selectedListItems.enumerated() {
            if item == updateItem {
                selectedListItems[index].listed.toggle()
                
                ModelController.shared.toggleListStatus(itemID: selectedListItems[index].id)
            }
        }
    }
}

//MARK: - Navigation
extension AddItemsViewController {
    @IBAction func dismissScreen(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func finishAddItems(_ sender: UIBarButtonItem) {
        let listedItems = ModelController.shared.returnSortedItemsInList(selectedListId)
        
        editListItemsDelegate?.editItems(items: listedItems)
        
        dismiss(animated: true, completion: nil)
    }
}
