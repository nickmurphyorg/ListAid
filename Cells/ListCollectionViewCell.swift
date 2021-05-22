//
//  ListCollectionViewCell.swift
//  Listaid
//
//  Created by Nick Murphy on 9/30/18.
//  Copyright © 2018 Nick Murphy. All rights reserved.
//

import UIKit

class ListCollectionViewCell: UICollectionViewCell {
    private var viewControllerView: UIView?
    
    let listStyleMetrics = ListStyleMetric()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        viewControllerView?.removeFromSuperview()
        viewControllerView = nil
    }
}

//MARK: - Setup Cell
extension ListCollectionViewCell {
    func setViewControllerView(_ view: UIView) {
        view.transform = CGAffineTransform.init(scaleX: listStyleMetrics.scaleFactor, y: listStyleMetrics.scaleFactor)
        view.center = CGPoint(x: contentView.frame.width / 2, y: contentView.frame.height / 2)
        viewControllerView = view
        
        contentView.addSubview(viewControllerView!)
    }
}

////MARK: - List Name Field Delegate
//extension ListCollectionViewCell {
//    func setNameFieldDelegate <T: UITextFieldDelegate> (textFieldDelegate: T) {
////        listNameField.delegate = textFieldDelegate
//    }
//}
//
