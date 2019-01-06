//
//  ItemSmallTableViewCell.swift
//  Listaid
//
//  Created by Nick Murphy on 12/26/18.
//  Copyright © 2018 Nick Murphy. All rights reserved.
//

import UIKit

class ItemSmallTableViewCell: UITableViewCell {
    @IBOutlet weak var itemNameLabel: UILabel!
    
    let strikeThrough = UIView(frame: CGRect(x: 10, y: 17, width: 8.0, height: 2.4))
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        strikeThrough.backgroundColor = .black
    }

}
