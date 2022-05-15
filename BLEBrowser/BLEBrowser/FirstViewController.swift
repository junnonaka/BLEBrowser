//
//  FirstViewController.swift
//  BLEBrowser
//
//  Created by 野中淳 on 2022/05/12.
//

import Foundation
import UIKit

class FirstViewController:UIViewController{
    
    //Filterのセル情報
    var filterCellSettings: [(filterType: String, imageAlpha: Double,selected:Bool)] = [
                ("No filter",0,true),
                ("RSSI > -62",1,false),
                ("RSSI > -74",0.7,false),
                ("RSSI > -86",0.5,false)]
    
    //Alert内に表示するtableView
    var filterAlertlCustumTableView  = UITableView()
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
    
    //MenuBottnにUIMenuをセット
    private func configureMenuButton(){
        var actions = [UIMenuElement]()
        // Filter
        actions.append(UIAction(title: "Filter", image: nil, state: .off,
                                handler: { (_) in
            let alert: UIAlertController = UIAlertController(title: "Select filter type", message: "\n\n\n\n\n\n\n\n\n\n\n", preferredStyle:  .alert)
            
            let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: .default, handler:{
                // ボタンが押された時の処理を書く（クロージャ実装）
                (action: UIAlertAction!) -> Void in
                print("OK")
            })
            let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: .cancel, handler:{
                // ボタンが押された時の処理を書く（クロージャ実装）
                (action: UIAlertAction!) -> Void in
                print("Cancel")
            })
            alert.addAction(cancelAction)
            alert.addAction(defaultAction)
            
            //let customView = UITableView()
            //custumView.delegate = self
            self.filterAlertlCustumTableView.dataSource = self
            self.filterAlertlCustumTableView.backgroundColor = UIColor.clear
            self.filterAlertlCustumTableView.register(FilterCell.self, forCellReuseIdentifier: FilterCell.reuseID)
            self.filterAlertlCustumTableView.rowHeight = FilterCell.rowHeight
            self.filterAlertlCustumTableView

            alert.view.addSubview(self.filterAlertlCustumTableView)
            self.filterAlertlCustumTableView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                self.filterAlertlCustumTableView.leftAnchor.constraint(equalTo: alert.view.leftAnchor),
                self.filterAlertlCustumTableView.rightAnchor.constraint(equalTo: alert.view.rightAnchor),
                self.filterAlertlCustumTableView.bottomAnchor.constraint(equalTo: alert.view.bottomAnchor, constant: -50),
                self.filterAlertlCustumTableView.heightAnchor.constraint(equalToConstant: FilterCell.rowHeight * CGFloat(self.filterCellSettings.count))
            ])
            
            self.present(alert, animated: true, completion: nil)
            
        }))
        // Sort
        actions.append(UIAction(title: "Sort", image: nil, state: .off,
                                handler: { (_) in
            
            
            
            
        }))
        
        //Bluetooth Settings
        //設定アプリを開く
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
extension FirstViewController:UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FilterCell.reuseID, for: indexPath) as! FilterCell
        cell.selectionStyle = .none
        cell.tag = indexPath.row
        cell.delegate = self
        cell.label.text = filterCellSettings[indexPath.row].filterType
        cell.RSSIImageView.alpha = filterCellSettings[indexPath.row].imageAlpha
        cell.selectedImageView.isHidden = !filterCellSettings[indexPath.row].selected
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterCellSettings.count
    }

    
}
extension FirstViewController:FilterCellDelegate{
    func didTapButton(cell: FilterCell) {
        print("did tup cell \(cell.tag)")
        
        for num in 0...filterCellSettings.count - 1{
            if num == cell.tag{
                filterCellSettings[num].selected = true
            }else{
                filterCellSettings[num].selected = false
            }
        }
        filterAlertlCustumTableView.reloadData()
    }
}
