//
//  NewListCollectionViewCell.swift
//  Listaid
//
//  Created by Nick Murphy on 10/3/18.
//  Copyright © 2018 Nick Murphy. All rights reserved.
//

import UIKit

class NewListCollectionViewCell: UICollectionViewCell {
    
    var newListLabel: UILabel!
    var listView: UIView!
    var addListIcon: UIImageView!
    
    let listStyleMetrics = ListStyleMetric()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - Setup Views
extension NewListCollectionViewCell {
    private func setupViews() {
        newListLabel = UILabel()
        newListLabel.translatesAutoresizingMaskIntoConstraints = false
        newListLabel.text = "New List"
        newListLabel.textColor = .white
        newListLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        newListLabel.numberOfLines = 1
        contentView.addSubview(newListLabel)
        
        listView = UIView()
        listView.translatesAutoresizingMaskIntoConstraints = false
        listView.layer.borderWidth = 2
        listView.layer.borderColor = UIColor.white.cgColor
        listView.layer.cornerRadius = listStyleMetrics.cornerRadius
        listView.backgroundColor = .black
        contentView.addSubview(listView)
        
        addListIcon = UIImageView(image: UIImage(named: "AddList"))
        addListIcon.translatesAutoresizingMaskIntoConstraints = false
        addListIcon.contentMode = .scaleAspectFit
        addListIcon.tintColor = .white
        listView.addSubview(addListIcon)
        
        setupConstraints()
    }
}

//MARK: - Setup Constraints
extension NewListCollectionViewCell {
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            newListLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: (10 + listStyleMetrics.statusBarHeight) * listStyleMetrics.scaleFactor),
            contentView.rightAnchor.constraint(equalTo: newListLabel.rightAnchor, constant: 10),
            newListLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 10),
            newListLabel.heightAnchor.constraint(equalToConstant: 28)
        ])
        
        NSLayoutConstraint.activate([
            listView.topAnchor.constraint(equalTo: newListLabel.bottomAnchor, constant: 7),
            contentView.rightAnchor.constraint(equalTo: listView.rightAnchor),
            listView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            listView.leftAnchor.constraint(equalTo: contentView.leftAnchor)
        ])
        
        NSLayoutConstraint.activate([
            addListIcon.centerYAnchor.constraint(equalTo: listView.centerYAnchor),
            addListIcon.centerXAnchor.constraint(equalTo: listView.centerXAnchor),
            // 70 x 70
        ])
    }
}
