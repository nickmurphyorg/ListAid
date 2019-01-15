//
//  AddItemsViewController.swift
//  Listaid
//
//  Created by Nick Murphy on 10/14/18.
//  Copyright © 2018 Nick Murphy. All rights reserved.
//

import UIKit

class AddItemsViewController: UIViewController {

    @IBOutlet weak var navigationView: UIVisualEffectView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var itemsTableView: UITableView!
    
    private var editingItemAtIndex: Int?
    
    var editListItemsDelegate: EditListItemsDelegate?
    var selectedListIndex = Int()
    var selectedListItems = [Item]()
    var searchResultItems = [Item]()
    
    private let addItemsTitle = "Add Items"
    private let editItemTitle = "Edit Item"
    private let cellIdentifier = "ItemCell"
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationView.layer.shadowColor = UIColor.black.cgColor
        navigationView.layer.shadowOpacity = 0.3
        navigationView.layer.shadowRadius = 0
        navigationView.layer.shadowOffset = CGSize(width: 0, height: 0.5)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        selectedListIndex = UserPreferences.shared.returnSavedListIndex()
        
        let savedListItems = ModelController.shared.returnAllItemsInList(atIndex: selectedListIndex)
        
        if let allListItems = savedListItems {
            selectedListItems = allListItems
        }
        
        itemsTableView.contentInset.top = navigationView.bounds.height
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
            updatedList = ModelController.shared.addItemToList(listIndex: selectedListIndex, itemName: searchBar.text!)
            
        } else if searchResultItems.count > 0 && editingItemAtIndex == nil {
            var addNewItem = true
            
            for item in searchResultItems {
                if searchBar.text!.lowercased() == item.name.lowercased() {
                    addNewItem = false
                }
            }
            
            if addNewItem {
                updatedList = ModelController.shared.addItemToList(listIndex: selectedListIndex, itemName: searchBar.text!)
            }
            
        } else if searchResultItems.count == 0 && editingItemAtIndex != nil {
            updatedList = ModelController.shared.renameItemInList(listIndex: selectedListIndex, itemIndex: editingItemAtIndex!, newName: searchBar.text!)
            
            editingItemAtIndex = nil
            
        } else if searchResultItems.count > 0 && editingItemAtIndex != nil {
            var updateItemName = true
            
            for item in searchResultItems {
                if searchBar.text!.lowercased() == item.name.lowercased() && selectedListItems[editingItemAtIndex!].id != item.id {
                    // Item is renamed to an existing item
                    updatedList = ModelController.shared.deleteItemInList(listIndex: selectedListIndex, itemIndex: editingItemAtIndex!)
                    
                    updateItemName = false
                } else if searchBar.text!.lowercased() == item.name.lowercased() && selectedListItems[editingItemAtIndex!].id == item.id {
                    // Item name was not changed
                    updateItemName = false
                }
            }
            
            if updateItemName {
                updatedList = ModelController.shared.renameItemInList(listIndex: selectedListIndex, itemIndex: editingItemAtIndex!, newName: searchBar.text!)
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
            guard let listIndex = self?.selectedListIndex else { return }
            
            let updatedList = ModelController.shared.deleteItemInList(listIndex: listIndex, itemIndex: indexPath.row)
            
            if let updatedList = updatedList {
                self?.selectedListItems = updatedList
            }
            
            tableView.reloadData()
        }
        
        let editAction = UITableViewRowAction(style: .normal, title: "Edit") { [weak self] (action: UITableViewRowAction, indexPath: IndexPath) in
            let itemName = self?.selectedListItems[indexPath.row].name
            
            self?.editingItemAtIndex = indexPath.row
            self?.navigationBar.topItem?.title = self?.editItemTitle
            self?.searchBar.text = itemName ?? ""
            self?.searchBar.becomeFirstResponder()
            
            self?.matchingSearchResults(searchText: itemName ?? "")
            
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
                
                ModelController.shared.toggleItemListStatus(listIndex: selectedListIndex, itemID: selectedListItems[index].id)
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
                
                ModelController.shared.toggleItemListStatus(listIndex: selectedListIndex, itemID: selectedListItems[index].id)
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
        let listedItems = selectedListItems.filter { $0.listed == true }
        
        editListItemsDelegate?.editItems(items: listedItems)
        
        dismiss(animated: true, completion: nil)
    }
}
