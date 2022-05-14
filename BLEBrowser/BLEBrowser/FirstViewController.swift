//
//  FirstViewController.swift
//  BLEBrowser
//
//  Created by 野中淳 on 2022/05/12.
//

import Foundation
import UIKit

class FirstViewController:UIViewController{
    
    
    
//    lazy var menuButtonItem:UIBarButtonItem = {
//        //let barButtonItem = UIBarButtonItem(title: "menu", style: .plain, target: self, action: #selector(menuButtonTapped))
//        let barButtonItem = UIBarButtonItem(title: "menu", image: nil, primaryAction: nil, menu: <#T##UIMenu?#>)
//
//        barButtonItem.tintColor = .white
//        return barButtonItem
//    }()
    
    var menuButtonItem = UIBarButtonItem()
    
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
        configureMenuButton()
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
    
    @objc func menuButtonTapped(_ sender:UIBarButtonItem){
        //sender.
    }
    
    //NavigationBar
    private func setNavigationBar(){
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
    
    private func configureMenuButton(){
        var actions = [UIMenuElement]()
        // Filter
        actions.append(UIAction(title: "Filter", image: nil, state: .off,
                                handler: { (_) in
        }))
        // Sort
        actions.append(UIAction(title: "Sort", image: nil, state: .off,
                                handler: { (_) in
        }))
        //Bluetooth Settings
        actions.append(UIAction(title: "Bluetooth Settings", image: nil, state: .off,
                                handler: { (_) in
            //let url = URL(string: "app-settings:")
            let url = URL(string: UIApplication.openSettingsURLString)!
            UIApplication.shared.open(url)
        }))
        
        //Version information
        actions.append(UIAction(title: "Version Information", image: nil, state: .off,
                                handler: { (_) in
        }))
        // UIButtonにUIMenuを設定
        let menu = UIMenu(title: "", options: .displayInline, children: actions)
        menuButtonItem = UIBarButtonItem(title: "Menu", menu: menu)
        menuButtonItem.tintColor = .white
    }
}
