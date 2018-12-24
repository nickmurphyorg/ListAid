//
//  AddItemTableViewCell.swift
//  Listaid
//
//  Created by Nick Murphy on 12/24/18.
//  Copyright © 2018 Nick Murphy. All rights reserved.
//

import UIKit

class AddItemTableViewCell: UITableViewCell {
    
    @IBOutlet weak var toggleItemButton: UIButton!
    @IBOutlet weak var itemNameLabel: UILabel!
    
    var toggleItemDelegate: ToggleListedItem?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    @IBAction func tappedToggleButton(_ sender: UIButton) {
        toggleItemDelegate?.toggleItem(tableCell: self)
    }
}
