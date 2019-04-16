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
    @IBOutlet weak var strikeThrough: UIView!
    @IBOutlet weak var strikeThroughWidthConstraint: NSLayoutConstraint!
    
    let listStyleMetrics = ListStyleMetric()
    
    weak var strikeCompleteDelegate: StrikeCompleteDelegate?
    var strikeInteractionController: StrikeInteractionController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        strikeThrough.layer.cornerRadius = listStyleMetrics.strikeCornerRadius
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
