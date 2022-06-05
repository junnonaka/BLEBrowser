//
//  BluetoothTableHeaderView.swift
//  BLEBrowser
//
//  Created by 野中淳 on 2022/06/05.
//

import Foundation
import UIKit

protocol BluetoothTableHeaderViewDelegate:AnyObject{
    func BluetoothTableHeaderViewTap(_ header:BluetoothTableHeaderView,section:Int)
    func connectImageViewTap(_ header:BluetoothTableHeaderView,section:Int)
}

class BluetoothTableHeaderView : UITableViewHeaderFooterView{
    
    let topview = UIView()
    let rightView = UIView()
    let localNameLabel = UILabel()
    let uuidLabel = UILabel()
    let RSSIImageView = UIImageView()
    let RSSILabel = UILabel()
    let connectImageView = UIImageView()
    
    static let reuseID = "BluetoothTableHeaderView"
    static let viewHeight:CGFloat = 44
    
    //section情報保持用
    var section = 0
    //tapされた時の処理を設定
    weak var delegate:BluetoothTableHeaderViewDelegate?
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setup()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension BluetoothTableHeaderView{
    private func setup(){
        
        topview.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapTopView)))
        
        //topView
        topview.translatesAutoresizingMaskIntoConstraints = false
        topview.backgroundColor = .systemBackground
        
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
        
        //rightView
        rightView.translatesAutoresizingMaskIntoConstraints = false
        rightView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapconnectImageView)))
        
    }
    
    @objc func tapTopView(_ sender:Any){
        //sectionTap時の処理
        print("tap topview")
        delegate?.BluetoothTableHeaderViewTap(self, section: section)
    }
    
    @objc func tapconnectImageView(_ sender:Any){
        //sectionTap時の処理
        print("tap connected")
        delegate?.connectImageViewTap(self, section: section)
    }
    
    private func layout(){
        addSubview(topview)
        addSubview(connectImageView)
        addSubview(rightView)

        
        topview.addSubview(localNameLabel)
        topview.addSubview(uuidLabel)
        topview.addSubview(connectImageView)
        topview.addSubview(RSSIImageView)
        topview.addSubview(RSSILabel)

        //topView
        NSLayoutConstraint.activate([
            topview.topAnchor.constraint(equalTo: topAnchor),
            topview.leadingAnchor.constraint(equalTo: leadingAnchor),
            topview.trailingAnchor.constraint(equalTo: connectImageView.leadingAnchor),
            topview.bottomAnchor.constraint(equalTo: bottomAnchor),
            topview.heightAnchor.constraint(equalToConstant: 44)
        ])


//        NSLayoutConstraint.activate([
//            topview.heightAnchor.constraint(equalToConstant: 44)
//        ])
        

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
            trailingAnchor.constraint(equalToSystemSpacingAfter: connectImageView.trailingAnchor, multiplier: 1),
            connectImageView.topAnchor.constraint(equalToSystemSpacingBelow: topAnchor, multiplier: 0.2),
            connectImageView.widthAnchor.constraint(equalToConstant: 40),
            connectImageView.heightAnchor.constraint(equalToConstant: 40),

        ])
        //rightView
        NSLayoutConstraint.activate([
            trailingAnchor.constraint(equalToSystemSpacingAfter: rightView.trailingAnchor, multiplier: 1),
            rightView.topAnchor.constraint(equalToSystemSpacingBelow: topAnchor, multiplier: 0.2),
            rightView.widthAnchor.constraint(equalToConstant: 40),
            rightView.heightAnchor.constraint(equalToConstant: 40),

        ])
        
        //RSSIImageView
        NSLayoutConstraint.activate([
            RSSIImageView.topAnchor.constraint(equalTo: topAnchor),
            connectImageView.leadingAnchor.constraint(equalToSystemSpacingAfter: RSSIImageView.trailingAnchor, multiplier: 1),
            RSSIImageView.widthAnchor.constraint(equalToConstant: 30),
            RSSIImageView.heightAnchor.constraint(equalToConstant: 30),

        ])
        
        //RSSILabel
        NSLayoutConstraint.activate([
            RSSILabel.topAnchor.constraint(equalToSystemSpacingBelow: RSSIImageView.bottomAnchor, multiplier: 0),
            connectImageView.leadingAnchor.constraint(equalToSystemSpacingAfter: RSSILabel.trailingAnchor, multiplier: 1),
        ])
        
    }
}
