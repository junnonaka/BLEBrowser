//
//  SortCell.swift
//  BLEBrowser
//
//  Created by 野中淳 on 2022/05/15.
//

import Foundation
import UIKit

//buttonTupを返す用
protocol SortCelllDelegate:AnyObject {
    func didTapButton(cell: SortCell)
}

class SortCell : UITableViewCell{
    
    weak var delegate:SortCelllDelegate?
    
    let label = UILabel()
    let radioButton = UIButton()
    let selectedImageView = UIImageView()
    
    static let reuseID = "SortCell"
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

extension SortCell{
    private func setup(){
        contentView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .body)
        label.textColor = .label
        label.text = "No sort"
        
        
        contentView.addSubview(radioButton)
        radioButton.translatesAutoresizingMaskIntoConstraints = false
        radioButton.setImage(UIImage.init(systemName: "circle"), for: .normal)
        radioButton.imageView?.contentMode = .scaleAspectFit
        radioButton.contentHorizontalAlignment = .fill // オリジナルの画像サイズを超えて拡大（水平）
        radioButton.contentVerticalAlignment = .fill // オリジナルの画像サイズを超えて拡大(垂直)
        
        radioButton.tintColor = .label
        radioButton.addTarget(self, action: #selector(didTupRadioButton), for: .primaryActionTriggered)
        
        contentView.addSubview(selectedImageView)
        selectedImageView.translatesAutoresizingMaskIntoConstraints = false
        selectedImageView.image = UIImage.init(systemName: "circle.fill")
        selectedImageView.tintColor = .systemBlue
        
        backgroundColor = .clear
        
    }
    
    private func layout(){
        
        //label
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalToSystemSpacingAfter: contentView.leadingAnchor, multiplier: 2),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
                
        //radioButton
        NSLayoutConstraint.activate([
            contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: radioButton.trailingAnchor, multiplier: 2),
            radioButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            radioButton.widthAnchor.constraint(equalToConstant: 30),
            radioButton.heightAnchor.constraint(equalToConstant: 30),
        ])
        
        //selectedImageView
        NSLayoutConstraint.activate([
            selectedImageView.centerXAnchor.constraint(equalTo: radioButton.centerXAnchor),
            selectedImageView.centerYAnchor.constraint(equalTo: radioButton.centerYAnchor)
        ])
        
    }
}

extension SortCell{
    @objc func didTupRadioButton(sender:UIButton){
        delegate?.didTapButton(cell: self)
    }
}
