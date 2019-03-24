//
//  ListCollectionViewCell.swift
//  Listaid
//
//  Created by Nick Murphy on 9/30/18.
//  Copyright © 2018 Nick Murphy. All rights reserved.
//

import UIKit

class ListCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var listNameField: UITextField!
    @IBOutlet weak var textFieldUnderline: UIView!
    @IBOutlet weak var deleteListButton: UIButton!
    @IBOutlet private weak var listTableView: UITableView!
    
    var deleteList: DeleteListDelegate?
    
    let screenDimensions = UIScreen.main.bounds
    let statusBarHeight = UIApplication.shared.statusBarFrame.height
    let listStyleMetrics = ListStyleMetric()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Scale Cell Layers For Zoom Animation
        self.contentView.frame.size.width = screenDimensions.width
        self.contentView.frame.size.height = screenDimensions.height - statusBarHeight
        self.contentView.transform = CGAffineTransform(scaleX: listStyleMetrics.scaleFactor, y: listStyleMetrics.scaleFactor)
        
        listTableView.translatesAutoresizingMaskIntoConstraints = false
        listTableView.rowHeight = hasEdgeToEdgeScreen() ? 43.3333 : 43.6666
        listTableView.layer.cornerRadius = listStyleMetrics.cornerRadius
    }
    
    @IBAction func returnNameField(_ sender: UITextField) {
        listNameField.resignFirstResponder()
    }
    
    @IBAction func deleteListButton(_ sender: UIButton) {
        deleteList?.deleteListContaining(sender)
    }
}

//MARK: - List Name Field Delegate
extension ListCollectionViewCell {
    func setNameFieldDelegate <T: UITextFieldDelegate> (textFieldDelegate: T) {
        listNameField.delegate = textFieldDelegate
    }
}

//MARK: - Delete List Delegate
extension ListCollectionViewCell {
    func setDeleteListDelegate <L: DeleteListDelegate> (deleteListDelegate: L) {
        deleteList = deleteListDelegate
    }
}

//MARK: - Tableview DataSource and Delegate
extension ListCollectionViewCell {
    func setTableViewDataSourceDelegate <D: UITableViewDataSource & UITableViewDelegate> (dataSourceDelegate: D) {
        listTableView.dataSource = dataSourceDelegate
        listTableView.delegate = dataSourceDelegate
    }
    
    func setTableViewIndex(_ index: Int) {
        listTableView.tag = index
    }
    
    func reloadTable(){
        listTableView.reloadData()
    }
}
