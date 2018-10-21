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

extension ListsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return lists.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: listCellIdentifier, for: indexPath) as? ListCollectionViewCell else {
            fatalError("The dequed cell is not an instance.")
        }
        
        let list = lists[indexPath.row]
        
        cell.listNameField.text = list.name
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? ListCollectionViewCell else { return }
        
        cell.setTableViewDataSourceDelegate(dataSourceDelegate: self, row: indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedListIndex = indexPath.item
        
        UserPreferences.shared.saveSelectedList(index: selectedListIndex)
        
        performSegue(withIdentifier: "PresentListView", sender: nil)
    }
}

extension ListsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: listWidth, height: listHeight)
    }
}

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
        
        // Update to just reload the cell...
        listCollectionView.reloadData()
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
