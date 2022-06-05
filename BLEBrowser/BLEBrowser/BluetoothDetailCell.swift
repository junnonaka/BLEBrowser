//
//  BluetoothDetailCell.swift
//  BLEBrowser
//
//  Created by 野中淳 on 2022/06/05.
//

import Foundation
import UIKit

class BluetoothDetailCell : UITableViewCell{
    let dataTextView = UITextView()
    
    static let reuseID = "BluetoothDetailCell"
    static let rowHeight:CGFloat = 120

    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension BluetoothDetailCell{
    private func setup(){
                
        
        //dataTextView
        dataTextView.translatesAutoresizingMaskIntoConstraints = false
        dataTextView.font = UIFont.preferredFont(forTextStyle: .caption2, compatibleWith: nil)
        dataTextView.textColor = .label
        dataTextView.backgroundColor = .quaternarySystemFill
        //dataTextView.backgroundColor = .brown

        dataTextView.text.append(contentsOf: "LocalName: no data\n")
        dataTextView.text.append(contentsOf: "ManufactureData: no data\n")
        dataTextView.text.append(contentsOf: "Service Data: no data\n")
        dataTextView.text.append(contentsOf: "Service UUIDs: no data\n")
        dataTextView.text.append(contentsOf: "Overflow Service UUIDs: no data\n")
        dataTextView.text.append(contentsOf: "TxPower Level: no data\n")
        dataTextView.text.append(contentsOf: "Is connectable: no data\n")
        dataTextView.text.append(contentsOf: "Solicited Service UUIDs: no data\n")
        dataTextView.isSelectable = false
        //初期は決しておく
        //dataTextView.isHidden = true
        
        backgroundColor = .clear
        
    }
    
    private func layout(){
        contentView.addSubview(dataTextView)

        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: dataTextView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: dataTextView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: dataTextView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: dataTextView.bottomAnchor)
        ])
        
        
    }
    
}
