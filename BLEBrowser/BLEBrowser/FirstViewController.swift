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
    //Sortのセル情報
    var sortCellSettings: [(sortType: String,selected:Bool)] = [
                ("No sort",true),
                ("RSSI sort(Descending)",false),
                ("Name sort(Descending)",false)]

    
    //Alert内に表示するtableView
    var filterAlertlCustumTableView  = UITableView()
    var sortAlertlCustumTableView  = UITableView()
    
    //Mainに表示するtableView
    var bluetoothTableView = UITableView()
    var menuButtonItem = UIBarButtonItem()
    var bluetoothDetailTableView = UITableView()
    
    // 開いているセクション保持
    var expandSectionSet = Set<Int>()
    
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
        
        bluetoothDetailTableView = UITableView(frame: view.frame, style: .grouped)
        
        configureMenuButton()
        setNavigationBar()
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 20
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Welcome"
        label.font = UIFont.preferredFont(forTextStyle: .title1)
        
        bluetoothTableView.translatesAutoresizingMaskIntoConstraints = false
        bluetoothTableView.backgroundColor = .systemBackground
        bluetoothTableView.delegate = self
        bluetoothTableView.dataSource = self
        bluetoothTableView.register(BluetoothCell.self, forCellReuseIdentifier: BluetoothCell.reuseID)

        bluetoothTableView.tag = 2
        

        bluetoothDetailTableView.translatesAutoresizingMaskIntoConstraints = false
        bluetoothDetailTableView.backgroundColor = .systemBackground
        bluetoothDetailTableView.delegate = self
        bluetoothDetailTableView.dataSource = self
        bluetoothDetailTableView.register(BluetoothDetailCell.self, forCellReuseIdentifier: BluetoothDetailCell.reuseID)
        bluetoothDetailTableView.register(BluetoothTableHeaderView.self, forHeaderFooterViewReuseIdentifier: BluetoothTableHeaderView.reuseID)
        bluetoothDetailTableView.tag = 3
        bluetoothDetailTableView.separatorColor = .clear
        
        
    }
    
    func layout(){

        view.addSubview(bluetoothDetailTableView)
        //bluetoothTableView
        NSLayoutConstraint.activate([
            bluetoothDetailTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            //Navigationにレイアウトをかける時はsafeAriaLayoutGuideらしい
            bluetoothDetailTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            bluetoothDetailTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bluetoothDetailTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

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
        //適用する:ScrollEdgeAppearanceに設定しているが、これは複数あるが、navigation全体の背景色の変更はscrollEdgeAppearance
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
            let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel, handler:{
                // ボタンが押された時の処理を書く（クロージャ実装）
                (action: UIAlertAction!) -> Void in
                print("Cancel")
            })
            alert.addAction(cancelAction)
            alert.addAction(defaultAction)
            
            self.filterAlertlCustumTableView.tag = 0
            self.filterAlertlCustumTableView.dataSource = self
            self.filterAlertlCustumTableView.backgroundColor = UIColor.clear
            self.filterAlertlCustumTableView.register(FilterCell.self, forCellReuseIdentifier: FilterCell.reuseID)
            self.filterAlertlCustumTableView.rowHeight = FilterCell.rowHeight
            self.filterAlertlCustumTableView.isScrollEnabled = false
            self.filterAlertlCustumTableView.separatorColor = .clear

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
            
            let alert: UIAlertController = UIAlertController(title: "Select sort type", message: "\n\n\n\n\n\n\n\n", preferredStyle:  .alert)
            
            let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: .default, handler:{
                // ボタンが押された時の処理を書く（クロージャ実装）
                (action: UIAlertAction!) -> Void in
                print("OK")
            })
            let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel, handler:{
                // ボタンが押された時の処理を書く（クロージャ実装）
                (action: UIAlertAction!) -> Void in
                print("Cancel")
            })
            alert.addAction(cancelAction)
            alert.addAction(defaultAction)
            
            self.sortAlertlCustumTableView.tag = 1
            self.sortAlertlCustumTableView.dataSource = self
            self.sortAlertlCustumTableView.backgroundColor = UIColor.clear
            self.sortAlertlCustumTableView.register(SortCell.self, forCellReuseIdentifier: SortCell.reuseID)
            self.sortAlertlCustumTableView.rowHeight = SortCell.rowHeight
            self.sortAlertlCustumTableView.isScrollEnabled = false
            self.sortAlertlCustumTableView.separatorColor = .clear

            alert.view.addSubview(self.sortAlertlCustumTableView)
            self.sortAlertlCustumTableView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                self.sortAlertlCustumTableView.leftAnchor.constraint(equalTo: alert.view.leftAnchor),
                self.sortAlertlCustumTableView.rightAnchor.constraint(equalTo: alert.view.rightAnchor),
                self.sortAlertlCustumTableView.bottomAnchor.constraint(equalTo: alert.view.bottomAnchor, constant: -50),
                self.sortAlertlCustumTableView.heightAnchor.constraint(equalToConstant: SortCell.rowHeight * CGFloat(self.sortCellSettings.count))
            ])
            
            self.present(alert, animated: true, completion: nil)
            
            
            
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
            
            let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
            //alert表示
            let alert: UIAlertController = UIAlertController(title: "Version Information",
                                                             message: "BLE Browser\n Version: \(version!)", preferredStyle:  .alert)
            let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: .default, handler:{
                // ボタンが押された時の処理を書く（クロージャ実装）
                (action: UIAlertAction!) -> Void in
                print("OK")
            })
            alert.addAction(defaultAction)
            self.present(alert, animated: true, completion: nil)

        }))
        // UIButtonにUIMenuを設定
        let menu = UIMenu(title: "", options: .displayInline, children: actions)
        menuButtonItem = UIBarButtonItem(title: "Menu", menu: menu)
        menuButtonItem.tintColor = .white
    }
}
extension FirstViewController:UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableView.tag{
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: FilterCell.reuseID, for: indexPath) as! FilterCell
            cell.selectionStyle = .none
            cell.tag = indexPath.row
            cell.delegate = self
            cell.label.text = filterCellSettings[indexPath.row].filterType
            cell.RSSIImageView.alpha = filterCellSettings[indexPath.row].imageAlpha
            cell.selectedImageView.isHidden = !filterCellSettings[indexPath.row].selected
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: SortCell.reuseID, for: indexPath) as! SortCell
            cell.selectionStyle = .none
            cell.tag = indexPath.row
            cell.delegate = self
            cell.label.text = sortCellSettings[indexPath.row].sortType
            cell.selectedImageView.isHidden = !sortCellSettings[indexPath.row].selected
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: BluetoothCell.reuseID, for: indexPath) as! BluetoothCell
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: BluetoothDetailCell.reuseID, for: indexPath) as! BluetoothDetailCell
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: SortCell.reuseID, for: indexPath) as! SortCell
            return cell
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var count = 0
        switch tableView.tag{
        case 0:
            count = filterCellSettings.count
        case 1:
            count = sortCellSettings.count
        case 2:
            count = 2
        case 3:
            count = expandSectionSet.contains(section) ? 1 : 0
        default:
            count = 2
        }
        
        
        return count
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch tableView.tag{
        case 0:
            print("tap1")
        case 1:
            print("tap2")
        case 2:
            print("tap3")
        case 3:
            print("tap4")

        default:
            print("tap")
            
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.5
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        var view = UIView()
        view.backgroundColor = .label
        return view
    }
    
    
    
}

extension FirstViewController:UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height = 0.0
        switch tableView.tag{
        case 0:
            height = FilterCell.rowHeight
        case 1:
            height = SortCell.rowHeight
        case 2:
            height = BluetoothCell.rowHeight
        case 3:
            height = BluetoothDetailCell.rowHeight

        default:
            height = 44
        }
        return height
    }
    
    
    // UITableViewDelegate
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var headerview:UIView? = nil
        switch tableView.tag{
        case 0:
            print("tap1")
        case 1:
            print("tap2")
        case 2:
            print("tap3")
        case 3:
            var view = tableView.dequeueReusableHeaderFooterView(withIdentifier: BluetoothTableHeaderView.reuseID) as! BluetoothTableHeaderView
            view.section = section
            view.delegate = self
            headerview = view
            print("tap4")

        default:
            print("tap")
        }
        
        return headerview
    }
    

    
    func numberOfSections(in tableView: UITableView) -> Int {
        var num = 1
        switch tableView.tag{
        case 0:
            print("1")
        case 1:
            print("2")
        case 2:
            print("3")
        case 3:
            num = 4
        default:
            print("tap")
        }
        
        return num
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

extension FirstViewController:SortCelllDelegate{
    func didTapButton(cell: SortCell) {
        print("did tup cell \(cell.tag)")
        
        for num in 0...sortCellSettings.count - 1{
            if num == cell.tag{
                sortCellSettings[num].selected = true
            }else{
                sortCellSettings[num].selected = false
            }
        }
        sortAlertlCustumTableView.reloadData()
    }
    
}
extension FirstViewController:BluetoothTableHeaderViewDelegate{

    //HeaderViewTap
    func BluetoothTableHeaderViewTap(_ header: BluetoothTableHeaderView, section: Int) {
        print("headerview tap section \(section)")
        
        if expandSectionSet.contains(section) {
            expandSectionSet.remove(section)
        } else {
            expandSectionSet.insert(section)
        }
        // section reload
        bluetoothDetailTableView.reloadSections([section], with: .automatic)
    }
    //ConnectImageViewTap
    func connectImageViewTap(_ header: BluetoothTableHeaderView, section: Int) {
        print("ImageViewTap section\(section)")
    }
    
}
