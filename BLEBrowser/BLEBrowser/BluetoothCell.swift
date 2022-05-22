//
//  BluetoothCell.swift
//  BLEBrowser
//
//  Created by 野中淳 on 2022/05/22.
//

import Foundation
import UIKit

class BluetoothCell : UITableViewCell{
    
    let stackView = UIStackView()
    let topview = UIView()
    let localNameLabel = UILabel()
    let uuidLabel = UILabel()
    let RSSIImageView = UIImageView()
    let RSSILabel = UILabel()
    let connectImageView = UIImageView()
    let dataTextView = UITextView()
    
    static let reuseID = "BluetoothCell"
    static let rowHeight:CGFloat = 44

    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension BluetoothCell{
    private func setup(){
        //stackView
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        
        
        //topView
        topview.translatesAutoresizingMaskIntoConstraints = false
        topview.backgroundColor = .orange
        
        //localNameLabel
        localNameLabel.translatesAutoresizingMaskIntoConstraints = false
        localNameLabel.font = UIFont.preferredFont(forTextStyle: .title2, compatibleWith: nil)
        localNameLabel.textColor = .label
        localNameLabel.text = "846B2177E0BA22A8E9"
        
        //uuidLabel
        uuidLabel.translatesAutoresizingMaskIntoConstraints = false
        uuidLabel.font = UIFont.preferredFont(forTextStyle: .caption2, compatibleWith: nil)
        uuidLabel.textColor = .label
        uuidLabel.text = "UUID:A6FD966-1D40-FADB-8268-5B5C6F8F2868"
        
        //connectImageView
        connectImageView.translatesAutoresizingMaskIntoConstraints = false
        connectImageView.image = UIImage.init(systemName: "play.circle")
        connectImageView.tintColor = .systemBlue
        connectImageView.contentMode = .scaleAspectFit

        
        backgroundColor = .clear
        
    }
    
    private func layout(){
        contentView.addSubview(stackView)
        
        stackView.addArrangedSubview(topview)
        
        topview.addSubview(localNameLabel)
        topview.addSubview(uuidLabel)

        topview.addSubview(connectImageView)
        
        
        //stackView
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
            
        ])
        
        //topView
        
        NSLayoutConstraint.activate([
            topview.heightAnchor.constraint(equalToConstant: 44)
        ])

        //localNamelabel
        NSLayoutConstraint.activate([
            localNameLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: topview.leadingAnchor, multiplier: 1),
            localNameLabel.topAnchor.constraint(equalToSystemSpacingBelow: topview.topAnchor, multiplier: 0)
        ])
        
        //uuidLabel
        NSLayoutConstraint.activate([
            uuidLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: topview.leadingAnchor, multiplier: 1),
            uuidLabel.topAnchor.constraint(equalToSystemSpacingBelow: localNameLabel.bottomAnchor, multiplier: 0)
        ])
        
        //connectImageView
        NSLayoutConstraint.activate([
            topview.trailingAnchor.constraint(equalToSystemSpacingAfter: connectImageView.trailingAnchor, multiplier: 1),
            connectImageView.topAnchor.constraint(equalToSystemSpacingBelow: topview.topAnchor, multiplier: 1),
            connectImageView.widthAnchor.constraint(equalToConstant: 30),
            connectImageView.heightAnchor.constraint(equalToConstant: 30),

        ])
        
    }
}
