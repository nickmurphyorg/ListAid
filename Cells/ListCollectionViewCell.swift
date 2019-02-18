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
    var textFieldUnderline: CALayer!
    
    let borderColor = UIColor(ciColor: .clear).cgColor
    
    override func awakeFromNib() {
        super.awakeFromNib()

        textFieldUnderline = createUnderlineFor(listNameField, color: .white)
        listNameField.layer.borderColor = borderColor
        listNameField.layer.addSublayer(textFieldUnderline)
        
        // Causing Auto-Layout Width Bug
        //listTableView.roundedCorners(corners: [.topLeft, .topRight, .bottomRight, .bottomLeft], radius: 4)
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
    
    func reloadTable(){
        listTableView.reloadData()
    }
}
