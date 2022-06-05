//
//  BluetoothCell.swift
//  BLEBrowser
//
//  Created by 野中淳 on 2022/05/22.
//

import Foundation
import UIKit

class BluetoothCell : UITableViewCell{
    
    let topview = UIView()
    let localNameLabel = UILabel()
    let uuidLabel = UILabel()
    let RSSIImageView = UIImageView()
    let RSSILabel = UILabel()
    let connectImageView = UIImageView()
    //let dataTextView = UITextView()
    
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
        
        //RSSIImageView
        RSSIImageView.translatesAutoresizingMaskIntoConstraints = false
        RSSIImageView.image = UIImage.init(systemName: "dot.radiowaves.up.forward")
        RSSIImageView.tintColor = .black
        RSSIImageView.contentMode = .scaleAspectFit

        //RSSILabel
        RSSILabel.translatesAutoresizingMaskIntoConstraints = false
        RSSILabel.font = UIFont.preferredFont(forTextStyle: .caption2, compatibleWith: nil)
        RSSILabel.textColor = .label
        RSSILabel.text = "-62"
        
        //dataTextView
//        dataTextView.translatesAutoresizingMaskIntoConstraints = false
//        dataTextView.font = UIFont.preferredFont(forTextStyle: .caption2, compatibleWith: nil)
//        dataTextView.textColor = .label
//        dataTextView.text.append(contentsOf: "LocalName: no data\n")
//        dataTextView.text.append(contentsOf: "ManufactureData: no data\n")
//        dataTextView.text.append(contentsOf: "Service Data: no data\n")
//        dataTextView.text.append(contentsOf: "Service UUIDs: no data\n")
//        dataTextView.text.append(contentsOf: "Overflow Service UUIDs: no data\n")
//        dataTextView.text.append(contentsOf: "TxPower Level: no data\n")
//        dataTextView.text.append(contentsOf: "Is connectable: no data\n")
//        dataTextView.text.append(contentsOf: "Solicited Service UUIDs: no data\n")

        //初期は決しておく
        //dataTextView.isHidden = true
        
        backgroundColor = .clear
        
    }
    
    private func layout(){
        contentView.addSubview(topview)
                
        topview.addSubview(localNameLabel)
        topview.addSubview(uuidLabel)
        topview.addSubview(connectImageView)
        topview.addSubview(RSSIImageView)
        topview.addSubview(RSSILabel)
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topview.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: topview.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: topview.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: topview.bottomAnchor)
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
            connectImageView.topAnchor.constraint(equalToSystemSpacingBelow: topview.topAnchor, multiplier: 0.2),
            connectImageView.widthAnchor.constraint(equalToConstant: 40),
            connectImageView.heightAnchor.constraint(equalToConstant: 40),

        ])
        
        //RSSIImageView
        NSLayoutConstraint.activate([
            RSSIImageView.topAnchor.constraint(equalTo: topview.topAnchor),
            connectImageView.leadingAnchor.constraint(equalToSystemSpacingAfter: RSSIImageView.trailingAnchor, multiplier: 1),
            RSSIImageView.widthAnchor.constraint(equalToConstant: 30),
            RSSIImageView.heightAnchor.constraint(equalToConstant: 30),

        ])
        
        //RSSILabel
        NSLayoutConstraint.activate([
            RSSILabel.topAnchor.constraint(equalToSystemSpacingBelow: RSSIImageView.bottomAnchor, multiplier: 0),
            connectImageView.leadingAnchor.constraint(equalToSystemSpacingAfter: RSSILabel.trailingAnchor, multiplier: 1),
        ])
        
        //dataTextView
//        NSLayoutConstraint.activate([
//            dataTextView.heightAnchor.constraint(equalToConstant: 100)
//        ])
        
    }
}