//
//  ItemTableViewCell.swift
//  Listaid
//
//  Created by Nick Murphy on 12/26/18.
//  Copyright © 2018 Nick Murphy. All rights reserved.
//

import UIKit

class ItemTableViewCell: UITableViewCell {
    @IBOutlet weak var itemNameLabel: UILabel!
    
    let strikeThrough = UIView(frame: CGRect(x: 12, y: 21, width: 10, height: 3))
    
    var strikeCompleteDelegate: StrikeCompleteDelegate?
    var strikeInteractionController: StrikeInteractionController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        strikeThrough.backgroundColor = .black
    }
}

//MARK: - Gesture Control
extension ItemTableViewCell {
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let panGesture = gestureRecognizer as? UIPanGestureRecognizer {
            let translation = panGesture.translation(in: contentView)
            
            if translation.x > 0 {
                return true
            }
        }
        
        return false
    }
}
