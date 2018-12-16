//
//  AddItemsViewController.swift
//  Listaid
//
//  Created by Nick Murphy on 10/14/18.
//  Copyright © 2018 Nick Murphy. All rights reserved.
//

import UIKit

class AddItemsViewController: UIViewController {

    @IBOutlet weak var navigationView: UIView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var itemsTableView: UITableView!
    
    var editListItemsDelegate: EditListItemsDelegate?
    var selectedListIndex = Int()
    var selectedListItems = [Item]()
    var searchResultItems = [Item]()
    
    private let cellIdentifier = "ItemCell"
    
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
        if searchResultItems.count == 0 {
            let updatedList = ModelController.shared.addItemToList(listIndex: selectedListIndex, itemName: searchBar.text!)
            
            if let updatedList = updatedList {
                selectedListItems = updatedList
            }
            
            searchBar.text = ""
            searchBar.resignFirstResponder()
            
            itemsTableView.reloadData()
        }
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
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        let itemData: Item
        
        if activeSearch() {
            itemData = searchResultItems[indexPath.row]
        } else {
            itemData = selectedListItems[indexPath.row]
        }
        
        cell.textLabel?.text = itemData.name
        
        if itemData.listed == true {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        selectItem(index: indexPath.row)
        
        tableView.reloadData()
    }
}

//MARK: - Helper Methods
extension AddItemsViewController {
    func selectItem(index: Int) {
        if activeSearch() {
            // Find item in master list before changing the listed status.
            toggleItemInMasterList(updateItem: searchResultItems[index])
            
            searchResultItems[index].listed.toggle()
        } else {
            selectedListItems[index].listed.toggle()
            
            ModelController.shared.toggleItemListStatus(listIndex: selectedListIndex, itemIndex: index)
        }
    }
    
    func toggleItemInMasterList(updateItem: Item) {
        for (index, item) in selectedListItems.enumerated() {
            if item == updateItem {
                selectedListItems[index].listed.toggle()
                
                ModelController.shared.toggleItemListStatus(listIndex: selectedListIndex, itemIndex: index)
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
