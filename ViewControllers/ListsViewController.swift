//
//  ViewController.swift
//  Listaid
//
//  Created by Nick Murphy on 9/30/18.
//  Copyright © 2018 Nick Murphy. All rights reserved.
//

import UIKit

class ListsViewController: UIViewController {
    
    @IBOutlet weak var listCollectionView: UICollectionView!
    
    var lists = [List]()
    var selectedListIndex = Int()
    var listWidth: CGFloat = 0
    var listHeight: CGFloat = 0
    
    private let listCellIdentifier = "ListCell"
    private let newListCellIdentifier = "NewListCell"
    private let itemCellIdentifier = "ListItemCellSmall"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lists = ModelController.shared.returnAllLists()
        
        listWidth = listCollectionView.frame.width - 60
        listHeight = listCollectionView.frame.height * 0.8
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
            fatalError("The dequed cell is not an instance.")
        }
        
        let list = lists[indexPath.item]
        
        cell.cellIndex = indexPath.item
        cell.listNameField.text = list.name
        cell.setNameFieldDelegate(textFieldDelegate: self)
        cell.setDeleteListDelegate(deleteListDelegate: self)
        cell.setTableViewDataSourceDelegate(dataSourceDelegate: self)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? ListCollectionViewCell else { return }
        
        cell.cellIndex = indexPath.item
        cell.reloadTable()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.section == 0 else {
            addNewList()
            
            return
        }
        
        selectedListIndex = indexPath.item
        
        UserPreferences.shared.saveSelectedList(index: selectedListIndex)
        
        performSegue(withIdentifier: "PresentListView", sender: nil)
    }
}

//MARK: - Collection View Layout
extension ListsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: listWidth, height: listHeight)
    }
}

//MARK: - Cell Text Field Delegate
extension ListsViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard textField.hasText else {
            textField.text = lists[textField.tag].name
            return
        }
        
        lists[textField.tag].name = textField.text!
        
        ModelController.shared.updateListName(listIndex: textField.tag, newName: textField.text!)
    }
    
}

//MARK: - Delete List Delegate
extension ListsViewController: DeleteListDelegate {
    func deleteList(index: Int) {
        lists = ModelController.shared.deleteList(listIndex: index)
        
        let itemIndex = IndexPath(item: index, section: 0)
        
        listCollectionView.deleteItems(at: [itemIndex])
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

//MARK: - Methods
extension ListsViewController {
    func addNewList() {
        let newList = List(name: "", items: [])
        
        lists = ModelController.shared.addNewList(newList: newList)
        
        let newIndex = IndexPath(item: lists.count - 1, section: 0)
        
        listCollectionView.insertItems(at: [newIndex])
        
        let addedList = listCollectionView.cellForItem(at: newIndex) as! ListCollectionViewCell
            addedList.listNameField.becomeFirstResponder()
    }
}

//MARK: - Navigation
extension ListsViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "PresentListView":
            let destinationViewController = segue.destination as! ListViewController
                destinationViewController.selectedList = lists[selectedListIndex]
                destinationViewController.editListDelegate = self
            
        default:
            return
        }
    }
    
}
