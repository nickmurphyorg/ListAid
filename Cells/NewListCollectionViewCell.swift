//
//  NewListCollectionViewCell.swift
//  Listaid
//
//  Created by Nick Murphy on 10/3/18.
//  Copyright © 2018 Nick Murphy. All rights reserved.
//

import UIKit

class NewListCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var listView: UIView!
    
    let listStyleMetrics = ListStyleMetric()
    
    override func awakeFromNib() {
        listView.layer.borderWidth = 2
        listView.layer.borderColor = UIColor.white.cgColor
        listView.layer.cornerRadius = listStyleMetrics.cornerRadius
    }
}
