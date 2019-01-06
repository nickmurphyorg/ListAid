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
    @IBOutlet weak var deleteListButton: UIButton!
    @IBOutlet private weak var listTableView: UITableView!
    
    var deleteList: DeleteListDelegate?
    
    let underlineColor = UIColor(red: 0.51, green: 0.51, blue: 0.51, alpha: 1.0).cgColor
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        listNameField.layer.shadowColor = underlineColor
        listNameField.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        listNameField.layer.shadowRadius = 0.0
        
        // Causing Auto-Layout Width Bug
        //listTableView.roundedCorners(corners: [.topLeft, .topRight, .bottomRight, .bottomLeft], radius: 4)
    }
    
    func setIndex(index: Int) {
        listNameField.tag = index
        deleteListButton.tag = index
        listTableView.tag = index
    }
    
    @IBAction func returnNameField(_ sender: UITextField) {
        listNameField.resignFirstResponder()
    }
    
    @IBAction func deleteListButton(_ sender: UIButton) {
        deleteList?.deleteList(index: deleteListButton.tag)
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
    
    func reloadTable(){
        listTableView.reloadData()
    }
}
