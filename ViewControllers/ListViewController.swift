//
//  ListViewController.swift
//  Listaid
//
//  Created by Nick Murphy on 10/7/18.
//  Copyright © 2018 Nick Murphy. All rights reserved.
//

import UIKit

class ListViewController: UIViewController {
    
    var listNameTextField: UITextField!
    var textFieldUnderline: CALayer!
    var actionButton: UIButton!
    var listBackground: UIView!
    var itemsTableView: UITableView!
    
    var editListDelegate: EditListDelegate?
    var zoomInteractionController: ZoomInteractionController?
    var dragReorderInteractionController: DragReorderInteractionController?
    var strikeInteractionController: StrikeInteractionController?
    
    var selectedList: List!
    
    private var listMode: ListMode = .Presented
    private var deleteList: DeleteListDelegate?
    private let cellIdentifier = "ItemCell"
    private let addItemsSegue = "PresentAddItems"
    private let reorderItemsNotificationName = NSNotification.Name("reorderItems")
    private let listStyleMetrics = ListStyleMetric()
    
    init(list: List, mode: ListMode) {
        super.init(nibName: nil, bundle: nil)
        
        selectedList = list
        listMode = mode
        
        setupViews()
        
        zoomInteractionController = ZoomInteractionController(viewController: self, tableView: itemsTableView)
        dragReorderInteractionController = DragReorderInteractionController(viewController: self, uiView: itemsTableView, notificationCenterName: reorderItemsNotificationName, reorderAxis: ReorderAxis.y, sections: [0])
        strikeInteractionController = StrikeInteractionController(viewController: self, tableView: itemsTableView)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(moveItem(notification:)), name: reorderItemsNotificationName, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // Verify User Is Closing List
        guard zoomInteractionController?.interactionInProgress ?? false else { return }
        
        editListDelegate?.editList(listItems: selectedList.items)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
}

//MARK: - Setup Views
extension ListViewController {
    private func setupViews() {
        listNameTextField = UITextField()
        listNameTextField.translatesAutoresizingMaskIntoConstraints = false
        listNameTextField.text = "Test" // selectedList.name
        listNameTextField.borderStyle = .none
        listNameTextField.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        listNameTextField.textColor = .white
        listNameTextField.layer.shadowColor = CGColor(gray: 0.5, alpha: 1.0)
        listNameTextField.layer.shadowOffset = CGSize(width: listNameTextField.frame.width, height: 1)
        listNameTextField.layer.shadowOpacity = 0
        view.addSubview(listNameTextField)
        
        textFieldUnderline = listNameTextField.createUnderline(color: UIColor.red)
        listNameTextField.layer.addSublayer(textFieldUnderline)
        
        actionButton = UIButton()
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.setBackgroundImage(UIImage(named: "AddItems"), for: .normal)
        actionButton.addTarget(self, action: #selector(actionButtonAction(sender:)), for: .touchUpInside)
        view.addSubview(actionButton)
        
        listBackground = UIView()
        listBackground.translatesAutoresizingMaskIntoConstraints = false
        listBackground.backgroundColor = .white
        listBackground.clipsToBounds = true
        listBackground.layer.cornerRadius = listStyleMetrics.cornerRadius
        view.addSubview(listBackground)
        
        itemsTableView = UITableView()
        itemsTableView.translatesAutoresizingMaskIntoConstraints = false
        itemsTableView.dataSource = self
        itemsTableView.delegate = self
        itemsTableView.separatorStyle = .none
        itemsTableView.rowHeight = 44
        itemsTableView.bounces = false
        itemsTableView.register(ItemTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        listBackground.addSubview(itemsTableView)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            listNameTextField.topAnchor.constraint(equalTo: view.topAnchor, constant: 10 + listStyleMetrics.statusBarHeight),
            actionButton.leftAnchor.constraint(equalTo: listNameTextField.rightAnchor, constant: 12),
            listNameTextField.heightAnchor.constraint(equalToConstant: 35),
            listNameTextField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 12)
        ])
        
        NSLayoutConstraint.activate([
            actionButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 13 + listStyleMetrics.statusBarHeight),
            view.rightAnchor.constraint(equalTo: actionButton.rightAnchor, constant: 10),
            actionButton.heightAnchor.constraint(equalToConstant: 30),
            actionButton.widthAnchor.constraint(equalToConstant: 30)
        ])
        
        NSLayoutConstraint.activate([
            listBackground.topAnchor.constraint(equalTo: listNameTextField.bottomAnchor, constant: 10),
            listBackground.rightAnchor.constraint(equalTo: view.rightAnchor),
            listBackground.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            listBackground.leftAnchor.constraint(equalTo: view.leftAnchor)
        ])
        
        NSLayoutConstraint.activate([
            itemsTableView.topAnchor.constraint(equalTo: listBackground.topAnchor),
            itemsTableView.rightAnchor.constraint(equalTo: listBackground.rightAnchor),
            itemsTableView.bottomAnchor.constraint(equalTo: listBackground.bottomAnchor),
            itemsTableView.leftAnchor.constraint(equalTo: listBackground.leftAnchor)
        ])
    }
}

//MARK: - List Modes
extension ListViewController {
    func setListMode(_ mode: ListMode) {
        listMode = mode
        
        switch mode {
        case .Edit:
            view.isUserInteractionEnabled = true
            itemsTableView.isUserInteractionEnabled = false
            textFieldUnderline.isHidden = false
            actionButton.isHidden = false
            listNameTextField.isHidden = false
            // underline
            
            actionButton.setBackgroundImage(UIImage(named: "DeleteList"), for: .normal)
            actionButton.tintColor = UIColor(red: 1.0, green: 0.23, blue: 0.19, alpha: 1.0)
        case .New:
            view.isUserInteractionEnabled = true
            itemsTableView.isUserInteractionEnabled = false
            textFieldUnderline.isHidden = false
            actionButton.isHidden = false
            listNameTextField.isHidden = false
            listNameTextField.becomeFirstResponder()
            // underline
            
            actionButton.setBackgroundImage(UIImage(named: "DeleteList"), for: .normal)
            actionButton.tintColor = UIColor(red: 1.0, green: 0.23, blue: 0.19, alpha: 1.0)
        case .Cell:
            view.isUserInteractionEnabled = false
            textFieldUnderline.isHidden = true
            actionButton.isHidden = true
            listNameTextField.isHidden = false
            // underline
            
        case .Presented:
            view.isUserInteractionEnabled = true
            itemsTableView.isUserInteractionEnabled = true
            textFieldUnderline.isHidden = true
            actionButton.isHidden = false
            listNameTextField.isHidden = false
        case .Selected:
            view.isUserInteractionEnabled = false
            textFieldUnderline.isHidden = true
            actionButton.isHidden = true
            listNameTextField.isHidden = true
        }
    }
}

//MARK: - Tableview Datasource and Delegate
extension ListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedList.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ItemTableViewCell else {
            fatalError("Could not initalize a new Item Table View Cell.")
        }
        
        let itemData = selectedList.items[indexPath.row]
        
        cell.itemNameLabel.text = itemData.name
        
        let completeStrikeWidth = cell.itemNameLabel.intrinsicContentSize.width + listStyleMetrics.strikeCompleteMargin
        
        if itemData.completed {
            cell.strikeThroughWidthConstraint.constant = completeStrikeWidth
        } else {
            cell.strikeThroughWidthConstraint.constant = listStyleMetrics.strikeWidth
        }
        
        cell.strikeCompleteDelegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        var cellOptions: [UITableViewRowAction] = []
        
        let removeAction = UITableViewRowAction(style: .normal, title: "Remove", handler: { [weak self] (action:UITableViewRowAction, indexPath: IndexPath) -> Void in
            guard let weakSelf = self else { return }
            
            ModelController.shared.toggleListStatus(itemID: weakSelf.selectedList.items[indexPath.row].id)
            
            weakSelf.selectedList.items.remove(at: indexPath.row)
            
            tableView.reloadData()
        })
        
        removeAction.backgroundColor = UIColor.orange
        cellOptions.append(removeAction)
        
        let relistAction = UITableViewRowAction(style: .normal, title: "Relist", handler: { [weak self] (action: UITableViewRowAction, indexPath: IndexPath) -> Void in
            guard let weakSelf = self,
                let editingCell = tableView.cellForRow(at: indexPath) as? ItemTableViewCell else {
                    return
            }
            
            UIView.animate(withDuration: 1) {
                editingCell.strikeThrough.frame.size.width = weakSelf.listStyleMetrics.strikeWidth
            }
            
            weakSelf.selectedList.items[indexPath.row].completed.toggle()
            
            ModelController.shared.toggleCompletionStatus(itemID: weakSelf.selectedList.items[indexPath.row].id)
        })
        
        if selectedList.items[indexPath.row].completed {
            cellOptions.append(relistAction)
        }
        
        return cellOptions
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}

//MARK: - Delete List Delegate
extension ListViewController {
    func setDeleteListDelegate <L: DeleteListDelegate> (deleteListDelegate: L) {
        deleteList = deleteListDelegate
    }
}

// MARK: - Gesture Delegate
extension ListViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let gesture = gestureRecognizer as? UIPanGestureRecognizer {
            let translation = gesture.translation(in: itemsTableView)

            // Prevent completing item when editing item
            if translation.x > 0 && translation.x > translation.y {
                if itemsTableView.isEditing {
                    return false
                }
            }
            
            // Prevent Pull Down When Reordering Items
            if dragReorderInteractionController?.interactionInProgress ?? false {
                return false
            }
        }

        return true
    }
}

// MARK: - Strike Complete Delegate
extension ListViewController: StrikeCompleteDelegate {
    func completeItem(tableViewCell: UITableViewCell) {
        guard let cellPath = itemsTableView.indexPath(for: tableViewCell) else { return }
        
        selectedList.items[cellPath.row].completed.toggle()
        
        ModelController.shared.toggleCompletionStatus(itemID: selectedList.items[cellPath.row].id)
        
        itemsTableView.reloadRows(at: [cellPath], with: .automatic)
    }
}

//MARK: - Edit List Delegate
extension ListViewController: EditListItemsDelegate {
    func editItems(items: [Item]) {
        selectedList.items = items
        
        itemsTableView.reloadData()
    }
}

//MARK: - Action Button
extension ListViewController {
    @objc func actionButtonAction(sender: UIButton!) {
        switch listMode {
        case .Edit:
            deleteList?.deleteListContaining(sender)
        default:
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let addItemsViewController = storyboard.instantiateViewController(withIdentifier: "addItemsViewController") as! AddItemsViewController
            addItemsViewController.selectedListId = selectedList?.id
            addItemsViewController.editListItemsDelegate = self
            
            self.present(addItemsViewController, animated: true, completion: nil)
        }
    }
}

//MARK: - Reorder List Items
extension ListViewController {
    @objc func moveItem(notification: NSNotification) {
        guard let fromIndex = notification.userInfo?[ReorderArray.fromIndex] as? Int,
            let toIndex = notification.userInfo?[ReorderArray.toIndex] as? Int else {
                print("Could not capture indicies for item to move.")
                
                return
        }
        
        selectedList.items = ModelController.shared.reorder(items: selectedList.items, fromIndex, toIndex)
    }
}

//MARK: - Shake To Purge
extension ListViewController {
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            selectedList.items = ModelController.shared.purgeCompleted(items: selectedList.items)
            
            itemsTableView.reloadSections(IndexSet.init(integer: 0), with: .automatic)
        }
    }
}
