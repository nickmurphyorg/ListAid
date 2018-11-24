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
    @IBOutlet weak var itemsTableView: UITableView!
    
    var editListDelegate: EditListDelegate?
    var zoomInteractionController: ZoomInteractionController?
    var selectedList: List?
    var selectedListName: String!
    var selectedListItems = [Item]()
    
    private let cellIdentifier = "ItemCell"
    private let addItemsSegue = "PresentAddItems"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let selectedList = selectedList {
            listNameLabel.text = selectedList.name
            selectedListName = selectedList.name
            selectedListItems = selectedList.items
        }
        
        zoomInteractionController = ZoomInteractionController(viewController: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        guard zoomInteractionController?.interactionInProgress ?? false else {
            return
        }
        
        let listData = List(name: selectedListName, items: selectedListItems)
        
        editListDelegate?.editList(list: listData)
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
        
        tableView.reloadData()
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
