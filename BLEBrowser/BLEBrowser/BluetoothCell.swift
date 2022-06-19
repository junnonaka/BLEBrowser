//
//  BluetoothCell.swift
//  BLEBrowser
//
//  Created by 野中淳 on 2022/05/22.
//

import Foundation
import UIKit
import EMTNeumorphicView

protocol BluetoothCellDelegate:AnyObject{
    func HeaderViewTap(_ cell:BluetoothCell,row:Int)
    func connectImageViewTap(_ cell:BluetoothCell,row:Int)
}

class BluetoothCell : UITableViewCell{
    
    let topview = UIView()
    let localNameLabel = UILabel()
    let uuidLabel = UILabel()
    let RSSIImageView = UIImageView()
    let RSSILabel = UILabel()
    let connectImageView = UIImageView()
    let dataTextView = UITextView()
    let connectView = UIView()
    let mainBackground = EMTNeumorphicView()
    let textViewBackground = EMTNeumorphicView()

    let NumoButton = EMTNeumorphicButton()
    
    static let reuseID = "BluetoothCell"
    static let rowHeight:CGFloat = 69
    static let allRowHeight:CGFloat = 200

    //row情報保持用
    var row = 0
    
    //tapされた時の処理を設定
    weak var delegate:BluetoothCellDelegate?

    
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
        topview.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapTopView)))
        topview.translatesAutoresizingMaskIntoConstraints = false
        topview.backgroundColor = .clear
        
        //localNameLabel
        localNameLabel.translatesAutoresizingMaskIntoConstraints = false
        localNameLabel.font = UIFont.preferredFont(forTextStyle: .title2, compatibleWith: nil)
        
        localNameLabel.textColor = .appColor
        localNameLabel.text = "846B2177E0BA22A8E9"
        localNameLabel.adjustsFontSizeToFitWidth = true

        
        //uuidLabel
        uuidLabel.translatesAutoresizingMaskIntoConstraints = false
        uuidLabel.font = UIFont.preferredFont(forTextStyle: .caption2, compatibleWith: nil)
        uuidLabel.textColor = .appColor
        uuidLabel.text = "UUID:A6FD966-1D40-FADB-8268-5B5C6F8F2868"
        
        //connectImageView
        connectImageView.translatesAutoresizingMaskIntoConstraints = false
        connectImageView.image = UIImage.init(systemName: "play.circle")
        connectImageView.tintColor = .blue
        connectImageView.contentMode = .scaleAspectFit
        
        connectView.translatesAutoresizingMaskIntoConstraints = false
        connectView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapconnectImageView)))
        connectView.backgroundColor = .clear
        
        //RSSIImageView
        RSSIImageView.translatesAutoresizingMaskIntoConstraints = false
        RSSIImageView.image = UIImage.init(systemName: "dot.radiowaves.up.forward")
        RSSIImageView.tintColor = .appColor
        RSSIImageView.contentMode = .scaleAspectFit
        RSSIImageView.backgroundColor = .clear


        //RSSILabel
        RSSILabel.translatesAutoresizingMaskIntoConstraints = false
        RSSILabel.font = UIFont.preferredFont(forTextStyle: .caption2, compatibleWith: nil)
        RSSILabel.textColor = .appColor
        RSSILabel.text = "-62"
        
        //dataTextView
        dataTextView.translatesAutoresizingMaskIntoConstraints = false
        dataTextView.font = UIFont.preferredFont(forTextStyle: .caption2, compatibleWith: nil)
        dataTextView.textColor = .appColor
        //dataTextView.isScrollEnabled = false
        dataTextView.isEditable = false
        dataTextView.backgroundColor = .clear
        dataTextView.layer.cornerRadius = 10

        //初期は決しておく
        dataTextView.isHidden = false
        
        mainBackground.translatesAutoresizingMaskIntoConstraints = false
        mainBackground.backgroundColor = .numoColor
        mainBackground.layer.cornerRadius = 5
        
        mainBackground.neumorphicLayer?.elementBackgroundColor = mainBackground.backgroundColor!.cgColor
        mainBackground.neumorphicLayer?.cornerRadius = 10
        // set convex or concave.
        mainBackground.neumorphicLayer?.depthType = .convex
        // set elementDepth (corresponds to shadowRadius). Default is 5
        mainBackground.neumorphicLayer?.elementDepth = 3
        mainBackground.neumorphicLayer?.edged = true
        
        textViewBackground.translatesAutoresizingMaskIntoConstraints = false
        textViewBackground.backgroundColor = .numoColor
        textViewBackground.layer.cornerRadius = 10
        
        textViewBackground.neumorphicLayer?.elementBackgroundColor = textViewBackground.backgroundColor!.cgColor
        textViewBackground.neumorphicLayer?.cornerRadius = 10
        // set convex or concave.
        textViewBackground.neumorphicLayer?.depthType = .concave
        // set elementDepth (corresponds to shadowRadius). Default is 5
        textViewBackground.neumorphicLayer?.elementDepth = 3
        
        
        
        NumoButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        NumoButton.tintColor = .blue
        
        NumoButton.neumorphicLayer?.elementBackgroundColor = UIColor.numoColor.cgColor
        NumoButton.translatesAutoresizingMaskIntoConstraints = false
        NumoButton.layer.cornerRadius = 20
        
        backgroundColor = .numoColor
        
    }
    
    @objc func tapTopView(_ sender:Any){
        //sectionTap時の処理
        print("tap topview")
        delegate?.HeaderViewTap(self, row: row)
    }
    
    @objc func tapconnectImageView(_ sender:Any){
        //sectionTap時の処理
        print("tap connected")
        delegate?.connectImageViewTap(self, row: row)
    }
    
    private func layout(){
        
        contentView.addSubview(mainBackground)
        mainBackground.addSubview(topview)
        mainBackground.addSubview(textViewBackground)
        mainBackground.addSubview(NumoButton)
        mainBackground.addSubview(connectView)
        textViewBackground.addSubview(dataTextView)
            
        topview.addSubview(localNameLabel)
        topview.addSubview(uuidLabel)
        topview.addSubview(RSSIImageView)
        topview.addSubview(RSSILabel)
       
        NSLayoutConstraint.activate([
            mainBackground.topAnchor.constraint(equalToSystemSpacingBelow: contentView.topAnchor, multiplier: 2),
            mainBackground.leadingAnchor.constraint(equalToSystemSpacingAfter: contentView.leadingAnchor,multiplier: 1 ),
            contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: mainBackground.trailingAnchor, multiplier: 1),
            mainBackground.bottomAnchor.constraint(equalToSystemSpacingBelow: contentView.bottomAnchor, multiplier: -2)
        ])
        
        
        NSLayoutConstraint.activate([
            topview.topAnchor.constraint(equalTo: mainBackground.topAnchor),
            topview.leadingAnchor.constraint(equalTo: mainBackground.leadingAnchor),
            topview.trailingAnchor.constraint(equalTo: mainBackground.trailingAnchor),
            //contentView.bottomAnchor.constraint(equalTo: topview.bottomAnchor)
        ])
        
        
        //topView
        
        NSLayoutConstraint.activate([
            topview.heightAnchor.constraint(equalToConstant: 55)
        ])

        //localNamelabel
        NSLayoutConstraint.activate([
            localNameLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: topview.leadingAnchor, multiplier: 1),
            localNameLabel.topAnchor.constraint(equalToSystemSpacingBelow: topview.topAnchor, multiplier: 0.5),
            localNameLabel.trailingAnchor.constraint(equalToSystemSpacingAfter: RSSIImageView.leadingAnchor, multiplier: -1)
            
        ])
        
        //uuidLabel
        NSLayoutConstraint.activate([
            uuidLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: topview.leadingAnchor, multiplier: 1),
            uuidLabel.topAnchor.constraint(equalToSystemSpacingBelow: localNameLabel.bottomAnchor, multiplier: 0)
        ])
        
        
        NSLayoutConstraint.activate([
            topview.trailingAnchor.constraint(equalToSystemSpacingAfter: NumoButton.trailingAnchor, multiplier: 1),
            NumoButton.topAnchor.constraint(equalToSystemSpacingBelow: topview.topAnchor, multiplier: 1),
            NumoButton.widthAnchor.constraint(equalToConstant: 40),
            NumoButton.heightAnchor.constraint(equalToConstant: 40),

        ])
        
        
        
        //connectImageView
        NSLayoutConstraint.activate([
            topview.trailingAnchor.constraint(equalToSystemSpacingAfter: connectView.trailingAnchor, multiplier: 1),
            connectView.topAnchor.constraint(equalToSystemSpacingBelow: topview.topAnchor, multiplier: 0),
            connectView.widthAnchor.constraint(equalToConstant: 50),
            connectView.heightAnchor.constraint(equalToConstant: 50),

        ])
        
        //RSSIImageView
        NSLayoutConstraint.activate([
            RSSIImageView.topAnchor.constraint(equalToSystemSpacingBelow: topview.topAnchor, multiplier: 0.5),
            NumoButton.leadingAnchor.constraint(equalToSystemSpacingAfter: RSSIImageView.trailingAnchor, multiplier: 1),
            RSSIImageView.widthAnchor.constraint(equalToConstant: 30),
            RSSIImageView.heightAnchor.constraint(equalToConstant: 30),

        ])
        
        //RSSILabel
        NSLayoutConstraint.activate([
            RSSILabel.topAnchor.constraint(equalToSystemSpacingBelow: RSSIImageView.bottomAnchor, multiplier: 0),
            NumoButton.leadingAnchor.constraint(equalToSystemSpacingAfter: RSSILabel.trailingAnchor, multiplier: 1),
        ])
        
        
        //textViewBackground
        NSLayoutConstraint.activate([
            textViewBackground.topAnchor.constraint(equalTo: topview.bottomAnchor),
            textViewBackground.leadingAnchor.constraint(equalToSystemSpacingAfter: topview.leadingAnchor, multiplier: 1),
            topview.trailingAnchor.constraint(equalToSystemSpacingAfter: textViewBackground.trailingAnchor, multiplier: 1),
            mainBackground.bottomAnchor.constraint(equalToSystemSpacingBelow: textViewBackground.bottomAnchor, multiplier: 1)
        ])
        
        //dataTextView
        NSLayoutConstraint.activate([
            dataTextView.topAnchor.constraint(equalTo: textViewBackground.topAnchor),
            dataTextView.leadingAnchor.constraint(equalToSystemSpacingAfter: textViewBackground.leadingAnchor, multiplier: 1),
            textViewBackground.trailingAnchor.constraint(equalToSystemSpacingAfter: dataTextView.trailingAnchor, multiplier: 1),
            dataTextView.bottomAnchor.constraint(equalTo: textViewBackground.bottomAnchor)
        ])
        
        
    }
}
