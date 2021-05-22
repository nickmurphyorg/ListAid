//
//  ItemTableViewCell.swift
//  Listaid
//
//  Created by Nick Murphy on 12/26/18.
//  Copyright © 2018 Nick Murphy. All rights reserved.
//

import UIKit

class ItemTableViewCell: UITableViewCell {
    var itemNameLabel: UILabel!
    var strikeThrough: UIView!
    var strikeThroughWidthConstraint: NSLayoutConstraint!
    
    let listStyleMetrics = ListStyleMetric()
    
    weak var strikeCompleteDelegate: StrikeCompleteDelegate?
    var strikeInteractionController: StrikeInteractionController?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - Setup Views
extension ItemTableViewCell {
    private func setupViews() {
        self.selectionStyle = .none
        
        itemNameLabel = UILabel()
        itemNameLabel.translatesAutoresizingMaskIntoConstraints = false
        itemNameLabel.font = UIFont.systemFont(ofSize: 18)
        itemNameLabel.numberOfLines = 1
        contentView.addSubview(itemNameLabel)
        
        strikeThrough = UIView()
        strikeThrough.translatesAutoresizingMaskIntoConstraints = false
        strikeThrough.backgroundColor = .black
        strikeThrough.layer.cornerRadius = listStyleMetrics.strikeCornerRadius
        contentView.addSubview(strikeThrough)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        strikeThroughWidthConstraint = NSLayoutConstraint(item: strikeThrough!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: listStyleMetrics.strikeWidth)
        
        NSLayoutConstraint.activate([
            strikeThroughWidthConstraint,
            strikeThrough.heightAnchor.constraint(equalToConstant: listStyleMetrics.strikeHeight),
            strikeThrough.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 12),
            strikeThrough.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            itemNameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            itemNameLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 30),
            itemNameLabel.rightAnchor.constraint(lessThanOrEqualTo: contentView.rightAnchor, constant: 15)
        ])
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
