//
//  FirstViewController.swift
//  BLEBrowser
//
//  Created by 野中淳 on 2022/05/12.
//

import Foundation
import UIKit

class FirstViewController:UIViewController{
    
    lazy var menuButtonItem:UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(title: "menu", style: .plain, target: self, action: #selector(menuButtonTapped))
        barButtonItem.tintColor = .white
        return barButtonItem
    }()
    
    lazy var leftImageButtonItem:UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(image: UIImage(systemName: "antenna.radiowaves.left.and.right"), style: .plain, target: self, action: nil)
        barButtonItem.tintColor = .white
        return barButtonItem
    }()
    
    let stackView = UIStackView()
    let label = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        style()
        layout()
    }
    
}

extension FirstViewController{
    
    func style(){
        setNavigationBar()
        
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 20
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Welcome"
        label.font = UIFont.preferredFont(forTextStyle: .title1)
    }
    
    func layout(){
        stackView.addArrangedSubview(label)
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo:view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo:view.centerYAnchor)
        ])
        
    }
    
}
extension FirstViewController{
    
    @objc func menuButtonTapped(){
        
    }
    
    //NavigationBar
    func setNavigationBar(){
        //UINavigationBarAppearanceをインスタンス化
        let appearance = UINavigationBarAppearance()
        //configureWithOpaqueBackgroundで以前までの設定を全てリセット
        appearance.configureWithOpaqueBackground()
        //背景色の設定
        appearance.backgroundColor = UIColor.systemBlue
        //titleの装飾：AttributeTextでする必要がある
        appearance.titleTextAttributes = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .title2),
                                          .foregroundColor: UIColor.white]
        //backgroundEffectはブラーとかを選べる。単色であればNone
        appearance.backgroundEffect = .none
        //適用する:ScrollEdgeAppearanceに設定しているが、これは複数ある
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        title = "BLE Browser"
        
        //right bar item
        navigationItem.rightBarButtonItem = menuButtonItem
        //left bar item
        navigationItem.leftBarButtonItem = leftImageButtonItem
    }
    
}
