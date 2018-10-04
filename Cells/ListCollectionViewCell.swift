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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Causing Auto-Layout Width Bug
        //listTableView.roundedCorners(corners: [.topLeft, .topRight, .bottomRight, .bottomLeft], radius: 4)
    }
    
    func setTableViewDataSourceDelegate <D: UITableViewDataSource & UITableViewDelegate> (dataSourceDelegate: D, row: Int) {
        listTableView.dataSource = dataSourceDelegate
        listTableView.delegate = dataSourceDelegate
        listTableView.tag = row
    }
    
}
